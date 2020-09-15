`timescale 1 ps / 1 ps
`include "./struct_s.sv"
// `define DUMMY_PG

module port_group (
    input   logic           clk,
    input   logic           rst,
    input   logic           in_match_sop,
    input   logic           in_match_eop,
    input   logic [127:0]   in_match_data,
    input   logic [5:0]     in_match_empty,
    input   logic           in_match_valid,
    output  logic           in_match_ready,
    input   logic           in_meta_valid,
    input   metadata_t      in_meta_data,
    output  logic           in_meta_ready,
    output  logic           out_match_sop,
    output  logic           out_match_eop,
    output  logic [511:0]   out_match_data,
    output  logic [5:0]     out_match_empty,
    output  logic           out_match_valid,
    input   logic           out_match_ready,
    input   logic           out_match_almost_full,
    output  logic           out_meta_valid,
    output  metadata_t      out_meta_data,
    input   logic           out_meta_ready,
    output  logic [31:0]    no_pg_rule_cnt,
    output  logic [31:0]    pg_rule_cnt
);

`ifdef DUMMY_PG
    assign out_match_sop   = in_match_sop;
    assign out_match_eop   = in_match_eop;
    assign out_match_valid = in_match_valid;
    assign out_match_data  = in_match_data;
    assign out_match_empty = in_match_empty;
    assign in_match_ready  = out_match_ready;
    assign out_meta_valid  = in_meta_valid;
    assign out_meta_data   = in_meta_data;
    assign in_meta_ready   = out_meta_ready;
`else

// This should be 1 bigger than the NUM_PIPE in rule_unit
localparam NUM_PIPES = 16;

typedef enum {
    IDLE,
    RULE
} state_t;
state_t state;

logic                   tcp;
logic [15:0]            src_port;
logic [15:0]            dst_port;
logic                   rule_valid;
logic                   reg_rule_valid;
logic                   rule_last;
logic                   reg_rule_last;

logic                   int_eop;
logic [127:0]           int_data;
logic                   int_valid;
logic [31:0]            int_csr_readdata;
logic                   int_almost_full;
logic [1:0]             int_cnt;

logic                   int_out_eop;
logic [127:0]           int_out_data;
logic                   int_out_valid;
logic                   int_out_ready;

logic [RULE_AWIDTH-1:0] in_rule_data_0;
logic [RULE_AWIDTH-1:0] out_rule_data_0;
logic                   rule_pg_match_0;
logic [RULE_AWIDTH-1:0] rule_pg_addr_0;
rule_pg_t               rule_pg_data_0;

logic [RULE_AWIDTH-1:0] in_rule_data_1;
logic [RULE_AWIDTH-1:0] out_rule_data_1;
logic                   rule_pg_match_1;
logic [RULE_AWIDTH-1:0] rule_pg_addr_1;
rule_pg_t               rule_pg_data_1;

logic [RULE_AWIDTH-1:0] in_rule_data_2;
logic [RULE_AWIDTH-1:0] out_rule_data_2;
logic                   rule_pg_match_2;
logic [RULE_AWIDTH-1:0] rule_pg_addr_2;
rule_pg_t               rule_pg_data_2;

logic [RULE_AWIDTH-1:0] in_rule_data_3;
logic [RULE_AWIDTH-1:0] out_rule_data_3;
logic                   rule_pg_match_3;
logic [RULE_AWIDTH-1:0] rule_pg_addr_3;
rule_pg_t               rule_pg_data_3;

logic [RULE_AWIDTH-1:0] in_rule_data_4;
logic [RULE_AWIDTH-1:0] out_rule_data_4;
logic                   rule_pg_match_4;
logic [RULE_AWIDTH-1:0] rule_pg_addr_4;
rule_pg_t               rule_pg_data_4;

logic [RULE_AWIDTH-1:0] in_rule_data_5;
logic [RULE_AWIDTH-1:0] out_rule_data_5;
logic                   rule_pg_match_5;
logic [RULE_AWIDTH-1:0] rule_pg_addr_5;
rule_pg_t               rule_pg_data_5;

logic [RULE_AWIDTH-1:0] in_rule_data_6;
logic [RULE_AWIDTH-1:0] out_rule_data_6;
logic                   rule_pg_match_6;
logic [RULE_AWIDTH-1:0] rule_pg_addr_6;
rule_pg_t               rule_pg_data_6;

logic [RULE_AWIDTH-1:0] in_rule_data_7;
logic [RULE_AWIDTH-1:0] out_rule_data_7;
logic                   rule_pg_match_7;
logic [RULE_AWIDTH-1:0] rule_pg_addr_7;
rule_pg_t               rule_pg_data_7;

assign in_match_ready = (state == RULE);

always @(posedge clk) begin
    if (rst) begin
        tcp <= 0;
        state <= IDLE;
        rule_valid <= 0;
        rule_last  <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                rule_last <= 0;
                rule_valid <= 0;
                in_meta_ready <= 0;
                if (in_meta_valid & !in_meta_ready & !int_almost_full) begin
                    state <= RULE;
                    src_port <= in_meta_data.tuple.sPort;
                    dst_port <= in_meta_data.tuple.dPort;
                    tcp <= (in_meta_data.prot == PROT_TCP);
                end
            end
            RULE: begin
                if (in_match_valid) begin
                    in_rule_data_0 <= in_match_data[RULE_AWIDTH-1:0];
                    in_rule_data_1 <= in_match_data[16*1+RULE_AWIDTH-1:16*1];
                    in_rule_data_2 <= in_match_data[16*2+RULE_AWIDTH-1:16*2];
                    in_rule_data_3 <= in_match_data[16*3+RULE_AWIDTH-1:16*3];
                    in_rule_data_4 <= in_match_data[16*4+RULE_AWIDTH-1:16*4];
                    in_rule_data_5 <= in_match_data[16*5+RULE_AWIDTH-1:16*5];
                    in_rule_data_6 <= in_match_data[16*6+RULE_AWIDTH-1:16*6];
                    in_rule_data_7 <= in_match_data[16*7+RULE_AWIDTH-1:16*7];

                    rule_valid <= 1;
                    if (in_match_eop) begin
                        state <= IDLE;
                        rule_last <= 1;
                        in_meta_ready <= 1;
                    end
                end
                else begin
                    rule_valid <= 0;
                end
            end
        endcase
    end
end

// Using almost full to ensure the out_fifo is always ready
always @(posedge clk) begin
    if (rst) begin
        int_eop <= 0;
        int_valid <= 0;
    end
    else begin
        int_valid <= 0;
        int_eop <= 0;
        if (reg_rule_valid) begin
            int_eop <= reg_rule_last;
            int_valid <= (reg_rule_last | rule_pg_match_0 | rule_pg_match_1     |
                          rule_pg_match_2 | rule_pg_match_3 | rule_pg_match_4   |
                          rule_pg_match_5 | rule_pg_match_6 | rule_pg_match_7   );
        end
    end
    int_data <= {3'b0, out_rule_data_7, 3'b0, out_rule_data_6,
                 3'b0, out_rule_data_5, 3'b0, out_rule_data_4,
                 3'b0, out_rule_data_3, 3'b0, out_rule_data_2,
                 3'b0, out_rule_data_1, 3'b0, out_rule_data_0};
end


// Convert to 512 bit for PCIe.
always @(posedge clk) begin
    if (rst) begin
        int_cnt <= 0;
        out_match_eop <= 0;
        out_match_data <= 0;
        out_match_valid <= 0;
    end
    else begin
        out_match_eop <= 0;
        out_match_valid <= 0;
        if (int_out_valid & !out_match_almost_full) begin
            if (int_out_eop) begin
                // Fetch, write, clear the output
                if (int_cnt == 0) begin
                    out_match_valid <= 1;
                    out_match_data <= 0;
                    out_match_eop <= 1;
                end
                // Forward the valid data first. Clear the
                // cnt, then forward the last. Wait, write
                // whatever is there.
                else begin
                    int_cnt <= 0;
                    out_match_valid <= 1;
                end
            end
            else begin
                // Fetch and write
                if (int_cnt == 3) begin
                    int_cnt <= 0;
                    out_match_valid <= 1;
                end
                // Fetch, do not write,
                else begin
                    int_cnt <= int_cnt + 1;
                end
            end
        end
    end

    // Clear the data
    if (int_out_valid) begin
        if (int_out_eop) begin
            if (int_cnt == 0) begin
                out_match_data <= 0;
            end
        end
        else begin
            case (int_cnt)
                2'd0: out_match_data[127:0]   <= int_out_data;
                2'd1: out_match_data[255:128] <= int_out_data;
                2'd2: out_match_data[383:256] <= int_out_data;
                2'd3: out_match_data[511:384] <= int_out_data;
                default: out_match_data <= 0;
            endcase
        end
    end
end

assign int_out_ready = !(int_out_eop & int_cnt != 0) & !out_match_almost_full;

assign out_match_sop = 0;
assign out_match_empty = 0;

// Output metadata
always @(posedge clk) begin
    if (rst) begin
        out_meta_valid <= 0;
    end
    else begin
        if (in_meta_valid & in_meta_ready) begin
            out_meta_valid <= 1;
        end
        else begin
            out_meta_valid <= 0;
        end
    end
    out_meta_data <= in_meta_data;
end

always @(posedge clk) begin
    if (rst) begin
        no_pg_rule_cnt <= 0;
        pg_rule_cnt <= 0;
    end
    else begin
        if (reg_rule_valid & !reg_rule_last) begin
            no_pg_rule_cnt <= no_pg_rule_cnt + 1;
        end
        if (int_valid & !int_eop) begin
            pg_rule_cnt <= pg_rule_cnt + 1;
        end
    end
end

hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_rule_valid (
    .clk(clk),
    .rst(rst),
    .din(rule_valid),
    .dout(reg_rule_valid)
);

hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_rule_last (
    .clk(clk),
    .rst(rst),
    .din(rule_last),
    .dout(reg_rule_last)
);

rule_unit rule_unit_0 (
    .clk            (clk),
    .rst            (rst),
    .src_port       (src_port),
    .dst_port       (dst_port),
    .tcp            (tcp),
    .in_rule_data   (in_rule_data_0),
    .in_rule_valid  (rule_valid),
    .out_rule_data  (out_rule_data_0),
    .rule_pg_match  (rule_pg_match_0),
    .rule_pg_addr   (rule_pg_addr_0),
    .rule_pg_data   (rule_pg_data_0)
);

rule_unit rule_unit_1 (
    .clk            (clk),
    .rst            (rst),
    .src_port       (src_port),
    .dst_port       (dst_port),
    .tcp            (tcp),
    .in_rule_data   (in_rule_data_1),
    .in_rule_valid  (rule_valid),
    .out_rule_data  (out_rule_data_1),
    .rule_pg_match  (rule_pg_match_1),
    .rule_pg_addr   (rule_pg_addr_1),
    .rule_pg_data   (rule_pg_data_1)
);

rule_unit rule_unit_2 (
    .clk            (clk),
    .rst            (rst),
    .src_port       (src_port),
    .dst_port       (dst_port),
    .tcp            (tcp),
    .in_rule_data   (in_rule_data_2),
    .in_rule_valid  (rule_valid),
    .out_rule_data  (out_rule_data_2),
    .rule_pg_match  (rule_pg_match_2),
    .rule_pg_addr   (rule_pg_addr_2),
    .rule_pg_data   (rule_pg_data_2)
);

rule_unit rule_unit_3 (
    .clk            (clk),
    .rst            (rst),
    .src_port       (src_port),
    .dst_port       (dst_port),
    .tcp            (tcp),
    .in_rule_data   (in_rule_data_3),
    .in_rule_valid  (rule_valid),
    .out_rule_data  (out_rule_data_3),
    .rule_pg_match  (rule_pg_match_3),
    .rule_pg_addr   (rule_pg_addr_3),
    .rule_pg_data   (rule_pg_data_3)
);

rule_unit rule_unit_4 (
    .clk            (clk),
    .rst            (rst),
    .src_port       (src_port),
    .dst_port       (dst_port),
    .tcp            (tcp),
    .in_rule_data   (in_rule_data_4),
    .in_rule_valid  (rule_valid),
    .out_rule_data  (out_rule_data_4),
    .rule_pg_match  (rule_pg_match_4),
    .rule_pg_addr   (rule_pg_addr_4),
    .rule_pg_data   (rule_pg_data_4)
);

rule_unit rule_unit_5 (
    .clk            (clk),
    .rst            (rst),
    .src_port       (src_port),
    .dst_port       (dst_port),
    .tcp            (tcp),
    .in_rule_data   (in_rule_data_5),
    .in_rule_valid  (rule_valid),
    .out_rule_data  (out_rule_data_5),
    .rule_pg_match  (rule_pg_match_5),
    .rule_pg_addr   (rule_pg_addr_5),
    .rule_pg_data   (rule_pg_data_5)
);

rule_unit rule_unit_6 (
    .clk            (clk),
    .rst            (rst),
    .src_port       (src_port),
    .dst_port       (dst_port),
    .tcp            (tcp),
    .in_rule_data   (in_rule_data_6),
    .in_rule_valid  (rule_valid),
    .out_rule_data  (out_rule_data_6),
    .rule_pg_match  (rule_pg_match_6),
    .rule_pg_addr   (rule_pg_addr_6),
    .rule_pg_data   (rule_pg_data_6)
);

rule_unit rule_unit_7 (
    .clk            (clk),
    .rst            (rst),
    .src_port       (src_port),
    .dst_port       (dst_port),
    .tcp            (tcp),
    .in_rule_data   (in_rule_data_7),
    .in_rule_valid  (rule_valid),
    .out_rule_data  (out_rule_data_7),
    .rule_pg_match  (rule_pg_match_7),
    .rule_pg_addr   (rule_pg_addr_7),
    .rule_pg_data   (rule_pg_data_7)
);

rom_2port #(
    .DWIDTH(RULE_PG_WIDTH),
    .AWIDTH(RULE_AWIDTH),
    .MEM_SIZE(RULE_DEPTH),
    .INIT_FILE("./mspm/rule_2_pg.mif")
)
rule2pg_table_0_1 (
    .q_a       (rule_pg_data_0),
    .q_b       (rule_pg_data_1),
    .address_a (rule_pg_addr_0),
    .address_b (rule_pg_addr_1),
    .clock     (clk)
);

rom_2port #(
    .DWIDTH(RULE_PG_WIDTH),
    .AWIDTH(RULE_AWIDTH),
    .MEM_SIZE(RULE_DEPTH),
    .INIT_FILE("./mspm/rule_2_pg.mif")
)
rule2pg_table_2_3 (
    .q_a       (rule_pg_data_2),
    .q_b       (rule_pg_data_3),
    .address_a (rule_pg_addr_2),
    .address_b (rule_pg_addr_3),
    .clock     (clk)
);

rom_2port #(
    .DWIDTH(RULE_PG_WIDTH),
    .AWIDTH(RULE_AWIDTH),
    .MEM_SIZE(RULE_DEPTH),
    .INIT_FILE("./mspm/rule_2_pg.mif")
)
rule2pg_table_4_5 (
    .q_a       (rule_pg_data_4),
    .q_b       (rule_pg_data_5),
    .address_a (rule_pg_addr_4),
    .address_b (rule_pg_addr_5),
    .clock     (clk)
);

rom_2port #(
    .DWIDTH(RULE_PG_WIDTH),
    .AWIDTH(RULE_AWIDTH),
    .MEM_SIZE(RULE_DEPTH),
    .INIT_FILE("./mspm/rule_2_pg.mif")
)
rule2pg_table_6_7 (
    .q_a       (rule_pg_data_6),
    .q_b       (rule_pg_data_7),
    .address_a (rule_pg_addr_6),
    .address_b (rule_pg_addr_7),
    .clock     (clk)
);

fifo_pkt_wrapper_infill_mlab #(
    .SYMBOLS_PER_BEAT(16),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(64),
    .USE_PACKETS(1)
)
out_fifo (
    .clk               (clk),
    .reset             (rst),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (int_csr_readdata),
    .csr_writedata     (0),
    .in_data           (int_data),
    .in_valid          (int_valid),
    .in_ready          (), //use almost full
    .in_startofpacket  (1'b0),
    .in_endofpacket    (int_eop),
    .in_empty          (4'b0),
    .out_data          (int_out_data),
    .out_valid         (int_out_valid),
    .out_ready         (int_out_ready),
    .out_startofpacket (),
    .out_endofpacket   (int_out_eop),
    .out_empty         ()
);

dc_back_pressure #(
    .FULL_LEVEL(32)
)
bp_out_fifo (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (int_csr_readdata),
    .csr_writedata  (),
    .almost_full    (int_almost_full)
);

`endif

endmodule
