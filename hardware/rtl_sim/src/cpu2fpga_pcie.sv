`include "./src/struct_s.sv"
module cpu2fpga_pcie (
    input clk,
    input rst,

    // PDU meta out signals
    output  pdu_metadata_t              pdumeta_cpu_data,
    output  logic                       pdumeta_cpu_valid,
    input   logic [9:0]                 pdumeta_cnt,

    // CPU ring buffer signals
    output  logic [C2F_RB_AWIDTH-1:0]   head,
    input   logic [C2F_RB_AWIDTH-1:0]   tail,
    input   logic [63:0]                kmem_addr,
    input   logic [63:0]                cpu_c2f_head_addr,

    // Write to Write prio for done
    input   logic                       wrdm_prio_ready,
    output  logic                       wrdm_prio_valid,
    output  logic [173:0]               wrdm_prio_data,

    // Write to Read data-mover
    input   logic                       rddm_desc_ready,
    output  logic                       rddm_desc_valid,
    output  logic [173:0]               rddm_desc_data,

    // Read data-mover write data
    input   logic [511:0]               c2f_writedata,
    input   logic                       c2f_write,
    input   logic [C2F_RB_AWIDTH-1:0]   c2f_address
);

localparam EP_BASE_ADDR = 32'h0004_0000;
localparam DONE_ID = 8'hFD;
localparam PDUMETA_FIFO_OCCUP = 480;

logic [173:0]                   data_desc;
logic [173:0]                   data_desc_low;
logic [173:0]                   data_desc_high;
logic [173:0]                   done_desc;
logic [63:0]                    cpu_data_addr;

logic [C2F_RB_AWIDTH-1:0]       new_head;

logic [C2F_RB_AWIDTH-1:0]       dma_size; // In 512 bits, or 16 DWORD
logic [C2F_RB_AWIDTH-1:0]       dma_size_low; // In 512 bits, or 16 DWORD
logic [C2F_RB_AWIDTH-1:0]       dma_size_high; // In 512 bits, or 16 DWORD
logic [31-C2F_RB_AWIDTH-4:0]    desc_padding; // 4 is for 16 DWORD
logic [31-C2F_RB_AWIDTH:0]      head_padding;
logic [C2F_RB_AWIDTH-1:0]       wr_cnt;

// Pdumeta fifo
pdu_hdr_t pdu_hdr;
typedef enum {
    IDLE,
    DESC,
    DESC_LOW,
    DESC_HIGH,
    DONE,
    WAIT
} state_t;
state_t state;

// CPU side addr
assign cpu_data_addr = kmem_addr + 64*head;

assign desc_padding = 0;
assign data_desc = {14'h0, desc_padding,dma_size, 4'b0,
                    32'h0, EP_BASE_ADDR, cpu_data_addr};

// First 16 DWORD is for registers
// 14'h function number,
// 8'h descriptor ID,
// 3'b application specific,
// 1'b single destion,
// 1'b immediate,
// 18'd number of dwords up to 1MB,
// 64'b destionation PCIe address,
// 64'b src Avalon-MM address or immediate data
assign done_desc = {14'h0, DONE_ID, 3'b0, 1'b0, 1'b0, 1'b1, 18'd1,
                    cpu_c2f_head_addr, 32'h0, head_padding, new_head};
// Rounding case
assign data_desc_low = {14'h0, desc_padding, dma_size_low,
                        4'b0, 32'h0, EP_BASE_ADDR, cpu_data_addr};

assign data_desc_high = {14'h0, desc_padding, dma_size_high,
                         4'b0, 32'h0, EP_BASE_ADDR, kmem_addr};

// Count number of writes
always @(posedge clk) begin
    if (rst) begin
        wr_cnt <= 0;
    end
    else begin
        if (state == IDLE) begin
            wr_cnt <= 0;
        end
        else begin
            if (c2f_write) begin
                wr_cnt <= wr_cnt + 1;
            end
        end
    end
end

// FSM
always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        head <= 0;
        dma_size <= 0;
        dma_size_low <= 0;
        dma_size_high <= 0;
        rddm_desc_valid <= 0;
        wrdm_prio_valid <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                rddm_desc_valid <= 0;
                wrdm_prio_valid <= 0;
                // CPU side ring buffer is not empty
                if (head != tail) begin
                    if (head < tail) begin
                        state <= DESC;
                        dma_size <= tail - head;
                        new_head <= tail;
                    end
                    else begin
                        // Special case: only need one transfer
                        if (tail == 0) begin
                            state <= DESC;
                        end
                        else begin
                            state <= DESC_LOW;
                            dma_size_low <= C2F_RB_DEPTH - head;
                            dma_size_high <= tail;
                        end
                        dma_size <= tail + C2F_RB_DEPTH - head;
                        new_head <= tail;
                    end
                end
            end
            DESC: begin
                if (dma_size + pdumeta_cnt < PDUMETA_FIFO_OCCUP) begin
                    rddm_desc_data <= data_desc;
                    rddm_desc_valid <= 1;
                    state <= DONE;
                end
            end
            DESC_LOW: begin
                if (dma_size + pdumeta_cnt < PDUMETA_FIFO_OCCUP) begin
                    rddm_desc_data <= data_desc_low;
                    rddm_desc_valid <= 1;
                    state <= DESC_HIGH;
                end
            end
            DESC_HIGH: begin
                if (rddm_desc_ready) begin
                    rddm_desc_data <= data_desc_high;
                    rddm_desc_valid <= 1;
                    state <= DONE;
                end
            end
            DONE: begin
                if (rddm_desc_ready) begin
                    wrdm_prio_data <= done_desc;
                    rddm_desc_valid <= 0;
                    wrdm_prio_valid <= 1;
                    state <= WAIT;

                    // Update head
                    head <= new_head;
                end
            end
            WAIT: begin
                // The previous request is consumed
                if (wrdm_prio_ready) begin
                    wrdm_prio_valid <= 0;
                end
                // The last data is fetched
                if (wr_cnt == dma_size) begin
                    state <= IDLE;
                end
            end
            default: state <= IDLE;
        endcase
    end
end

// Transfer c2f_write to pdumeta_data
assign pdu_hdr = c2f_writedata;
always @(posedge clk) begin
    if (rst) begin
        pdumeta_cpu_valid <= 0;
    end
    else begin
        pdumeta_cpu_valid <= c2f_write;
    end
    pdumeta_cpu_data.action <= pdu_hdr.action[ACTION_WIDTH-1:0];
    pdumeta_cpu_data.pdu_id <= pdu_hdr.pdu_id[PDUID_WIDTH-1:0];
    pdumeta_cpu_data.flits <= pdu_hdr.pdu_flit[4:0];
    pdumeta_cpu_data.pdu_size <= pdu_hdr.pdu_size;
end

endmodule
