`include "./src/struct_s.sv"
module ring_buffer #(
    parameter PDU_DEPTH = 512,
    parameter PDU_AWIDTH = ($clog2(PDU_DEPTH))
) (
    input   logic                   clk,
    input   logic                   rst,

    //write side
    input   flit_lite_t             wr_data,
    input   logic [PDU_AWIDTH-1:0]  wr_addr,
    input   logic                   wr_en,
    output  logic [PDU_AWIDTH-1:0]  wr_base_addr,
    output  logic                   almost_full,
    input   logic                   update_valid,
    input   logic [PDU_AWIDTH-1:0]  update_size,

    //fetch side
    input   logic [PDU_AWIDTH-1:0]  rd_addr,
    input   logic                   rd_en,
    output  logic                   rd_valid,
    output  logic [511:0]           rd_data,

    //dma signals
    output  logic                   dma_start,
    output  logic [PDU_AWIDTH-1:0]  dma_size,
    output  logic [PDU_AWIDTH-1:0]  dma_base_addr,
    input   logic                   dma_done
);

localparam THRESHOLD = 64;
localparam MAX_SLOT = PDU_DEPTH - THRESHOLD;

typedef enum {
    IDLE,
    WAIT
} state_t;
state_t state;

logic [PDU_AWIDTH-1:0]  head;
logic [PDU_AWIDTH-1:0]  tail;
logic [PDU_AWIDTH-1:0]  free_slot;
logic [PDU_AWIDTH-1:0]  occupied_slot;
logic                   rd_en_r;
flit_lite_t             rd_flit_lite;
logic [PDU_AWIDTH-1:0]  rd_addr_r1;
logic [PDU_AWIDTH-1:0]  rd_addr_r2;
logic [PDU_AWIDTH-1:0]  last_tail;
logic                   wrap;
logic [PDU_AWIDTH-1:0]  send_slot;

assign occupied_slot    = wrap ? (last_tail - head + tail) : (tail - head);
assign send_slot        = wrap ? (last_tail - head) : (tail - head);
assign free_slot        = PDU_DEPTH - occupied_slot - 1;
assign wrap             = (tail < head);
assign wr_base_addr     = tail;

// Update tail
always @(posedge clk) begin
    if (rst) begin
        tail        <= 0;
        last_tail   <= 0;
        almost_full <= 0;
    end
    else begin
        if (update_valid) begin
            if (tail + update_size < MAX_SLOT) begin
                tail <= tail + update_size;
            end
            else begin
                tail <= 0;
                last_tail <= tail + update_size;
            end
        end

        if (free_slot >= (2 * THRESHOLD)) begin
            almost_full <= 0;
        end
        else begin
            almost_full <= 1;
        end
    end
end

// Udpate head
always @(posedge clk) begin
    if (rst) begin
        head <= 0;
    end
    else begin
        // One block has been read
        if (rd_valid & rd_flit_lite.eop) begin
            if (rd_addr_r2 + 1 >= MAX_SLOT) begin
                head <= 0;
            end
            else begin
                head <= rd_addr_r2 + 1;
            end
        end
    end
end

// DMA state machine
always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        dma_size <= 0;
        dma_start <= 0;
        dma_base_addr <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                // We have data to send
                if (occupied_slot > 0) begin
                    state <= WAIT;
                    dma_start <= 1;
                    dma_size <= send_slot;
                    dma_base_addr <= head;
                end
            end
            WAIT: begin
                dma_start <= 0;
                if (dma_done) begin
                    state <= IDLE;
                end
           end
           default: state <= IDLE;
        endcase
    end
end

// Two cycles delay
always @(posedge clk) begin
    rd_en_r <= rd_en;
    rd_valid <= rd_en_r;
    rd_addr_r1 <= rd_addr;
    rd_addr_r2 <= rd_addr_r1;
end

assign rd_data = rd_flit_lite.data;

bram_simple2port #(
    .AWIDTH(PDU_AWIDTH),
    .DWIDTH(514),
    .DEPTH(PDU_DEPTH)
)
pdu_buffer (
    .clock      (clk),
    .data       (wr_data),
    .rdaddress  (rd_addr),
    .rden       (rd_en),
    .wraddress  (wr_addr),
    .wren       (wr_en),
    .q          (rd_flit_lite)
);

endmodule
