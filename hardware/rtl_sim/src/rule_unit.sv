`include "./src/struct_s.sv"
`timescale 1 ps / 1 ps

module rule_unit(
    input   logic                   clk,
    input   logic                   rst,
    input   logic [15:0]            src_port,
    input   logic [15:0]            dst_port,
    input   logic                   tcp,
    input   logic [RULE_AWIDTH-1:0] in_rule_data,
    input   logic                   in_rule_valid,
    output  logic [RULE_AWIDTH-1:0] out_rule_data,
    output  logic                   rule_pg_match,
    output  logic [RULE_AWIDTH-1:0] rule_pg_addr,
    input   rule_pg_t               rule_pg_data
);

localparam NUM_PIPES = 15;

// Stats
`ifdef DEBUG
logic [15:0] port_match_cnt;
logic [15:0] no_port_cnt;
logic [15:0] error_cnt;
`endif

logic                   tcp_r1;
logic                   tcp_r2;
logic                   tcp_r3;
logic [15:0]            src_port_r1;
logic [15:0]            src_port_r2;
logic [15:0]            src_port_r3;
logic [15:0]            dst_port_r1;
logic [15:0]            dst_port_r2;
logic [15:0]            dst_port_r3;
logic [RULE_AWIDTH-1:0] reg_rule_data;
logic                   rule_rd;
logic                   rule_pg_valid;

logic [PG_AWIDTH-1:0]   in_pg_0;
logic [PG_AWIDTH-1:0]   in_pg_1;
logic [PG_AWIDTH-1:0]   in_pg_2;
logic [PG_AWIDTH-1:0]   in_pg_3;
logic                   in_pg_valid_0;
logic                   in_pg_valid_1;
logic                   in_pg_valid_2;
logic                   in_pg_valid_3;

logic                   port_match;
logic                   port_match_0;
logic                   port_match_1;
logic                   port_match_2;
logic                   port_match_3;

logic [PG_AWIDTH-1:0]   pg_entry_addr_0;
pg_entry_t              pg_entry_data_0;
logic [PG_AWIDTH-1:0]   single_addr_0;
logic [15:0]            single_data_0;
logic [4:0]             range_addr_0;
pg_range_t              range_data_0;
logic [4:0]             list_addr_0;
pg_list_t               list_data_0;
logic [10:0]            http_src_addr_0;
logic [31:0]            http_src_data_0;
logic [10:0]            http_dst_addr_0;
logic [31:0]            http_dst_data_0;

logic [PG_AWIDTH-1:0]   pg_entry_addr_1;
pg_entry_t              pg_entry_data_1;
logic [PG_AWIDTH-1:0]   single_addr_1;
logic [15:0]            single_data_1;
logic [4:0]             range_addr_1;
pg_range_t              range_data_1;
logic [4:0]             list_addr_1;
pg_list_t               list_data_1;
logic [10:0]            http_src_addr_1;
logic [31:0]            http_src_data_1;
logic [10:0]            http_dst_addr_1;
logic [31:0]            http_dst_data_1;

logic [PG_AWIDTH-1:0]   pg_entry_addr_2;
pg_entry_t              pg_entry_data_2;
logic [PG_AWIDTH-1:0]   single_addr_2;
logic [15:0]            single_data_2;
logic [4:0]             range_addr_2;
pg_range_t              range_data_2;
logic [4:0]             list_addr_2;
pg_list_t               list_data_2;
logic [10:0]            http_src_addr_2;
logic [31:0]            http_src_data_2;
logic [10:0]            http_dst_addr_2;
logic [31:0]            http_dst_data_2;

logic [PG_AWIDTH-1:0]   pg_entry_addr_3;
pg_entry_t              pg_entry_data_3;
logic [PG_AWIDTH-1:0]   single_addr_3;
logic [15:0]            single_data_3;
logic [4:0]             range_addr_3;
pg_range_t              range_data_3;
logic [4:0]             list_addr_3;
pg_list_t               list_data_3;
logic [10:0]            http_src_addr_3;
logic [31:0]            http_src_data_3;
logic [10:0]            http_dst_addr_3;
logic [31:0]            http_dst_data_3;

assign rule_pg_addr = in_rule_data - 1;

// First stage: index rule2pg table
always @(posedge clk) begin
    if (rst) begin
        rule_rd <= 0;
    end
    else begin
        // CYCLE 1
        // rule2pg table read delay 1
        tcp_r1          <= tcp;
        src_port_r1     <= src_port;
        dst_port_r1     <= dst_port;
        rule_rd         <= (in_rule_data != 0) & in_rule_valid;

        // CYCLE 2
        // rule2pg table read delay 2
        rule_pg_valid   <= rule_rd;
        tcp_r2          <= tcp_r1;
        src_port_r2     <= src_port_r1;
        dst_port_r2     <= dst_port_r1;

        // CYCLE 3
        // Assign each port group
        // pg = 0 is treated as invalid pg
        tcp_r3          <= tcp_r2;
        src_port_r3     <= src_port_r2;
        dst_port_r3     <= dst_port_r2;
        in_pg_0         <= rule_pg_data.pg0 - 1;
        in_pg_1         <= rule_pg_data.pg1 - 1;
        in_pg_2         <= rule_pg_data.pg2 - 1;
        in_pg_3         <= rule_pg_data.pg3 - 1;
        in_pg_valid_0   <= rule_pg_valid & (rule_pg_data.pg0 != 0);
        in_pg_valid_1   <= rule_pg_valid & (rule_pg_data.pg1 != 0);
        in_pg_valid_2   <= rule_pg_valid & (rule_pg_data.pg2 != 0);
        in_pg_valid_3   <= rule_pg_valid & (rule_pg_data.pg3 != 0);
    end
end

assign port_match = (port_match_0 | port_match_1 |
                     port_match_2 | port_match_3);

always @(posedge clk) begin
    if (rst) begin
        rule_pg_match <= 0;
    end
    else begin
        rule_pg_match <= port_match;
    end

    out_rule_data <= 0;
    if (port_match) begin
        out_rule_data <= reg_rule_data;
    end
end

`ifdef DEBUG
always @(posedge clk) begin
    if (rst) begin
        port_match_cnt <= 0;
        no_port_cnt <= 0;
    end
    else begin
        if (port_match) begin
            port_match_cnt <= port_match_cnt + 1;
        end

        if (reg_rule_data != 0) begin
            no_port_cnt <= no_port_cnt + 1;
        end
    end
end
`endif

hyper_pipe #(
    .WIDTH (RULE_AWIDTH),
    .NUM_PIPES(NUM_PIPES)
) hp_rule (
    .clk(clk),
    .din(in_rule_data),
    .dout(reg_rule_data)
);

port_unit pg_0 (
    .clk           (clk),
    .rst           (rst),
    .in_pg         (in_pg_0),
    .in_pg_valid   (in_pg_valid_0),
    .src_port      (src_port_r3),
    .dst_port      (dst_port_r3),
    .tcp           (tcp_r3),
    .pg_entry_addr (pg_entry_addr_0),
    .pg_entry_data (pg_entry_data_0),
    .single_addr   (single_addr_0),
    .single_data   (single_data_0),
    .range_addr    (range_addr_0),
    .range_data    (range_data_0),
    .list_addr     (list_addr_0),
    .list_data     (list_data_0),
    .http_src_addr (http_src_addr_0),
    .http_src_data (http_src_data_0),
    .http_dst_addr (http_dst_addr_0),
    .http_dst_data (http_dst_data_0),
    .port_match    (port_match_0)
);
port_unit pg_1 (
    .clk           (clk),
    .rst           (rst),
    .in_pg         (in_pg_1),
    .in_pg_valid   (in_pg_valid_1),
    .src_port      (src_port_r3),
    .dst_port      (dst_port_r3),
    .tcp           (tcp_r3),
    .pg_entry_addr (pg_entry_addr_1),
    .pg_entry_data (pg_entry_data_1),
    .single_addr   (single_addr_1),
    .single_data   (single_data_1),
    .range_addr    (range_addr_1),
    .range_data    (range_data_1),
    .list_addr     (list_addr_1),
    .list_data     (list_data_1),
    .http_src_addr (http_src_addr_1),
    .http_src_data (http_src_data_1),
    .http_dst_addr (http_dst_addr_1),
    .http_dst_data (http_dst_data_1),
    .port_match    (port_match_1)
);
port_unit pg_2 (
    .clk           (clk),
    .rst           (rst),
    .in_pg         (in_pg_2),
    .in_pg_valid   (in_pg_valid_2),
    .src_port      (src_port_r3),
    .dst_port      (dst_port_r3),
    .tcp           (tcp_r3),
    .pg_entry_addr (pg_entry_addr_2),
    .pg_entry_data (pg_entry_data_2),
    .single_addr   (single_addr_2),
    .single_data   (single_data_2),
    .range_addr    (range_addr_2),
    .range_data    (range_data_2),
    .list_addr     (list_addr_2),
    .list_data     (list_data_2),
    .http_src_addr (http_src_addr_2),
    .http_src_data (http_src_data_2),
    .http_dst_addr (http_dst_addr_2),
    .http_dst_data (http_dst_data_2),
    .port_match    (port_match_2)
);
port_unit pg_3 (
    .clk           (clk),
    .rst           (rst),
    .in_pg         (in_pg_3),
    .in_pg_valid   (in_pg_valid_3),
    .src_port      (src_port_r3),
    .dst_port      (dst_port_r3),
    .tcp           (tcp_r3),
    .pg_entry_addr (pg_entry_addr_3),
    .pg_entry_data (pg_entry_data_3),
    .single_addr   (single_addr_3),
    .single_data   (single_data_3),
    .range_addr    (range_addr_3),
    .range_data    (range_data_3),
    .list_addr     (list_addr_3),
    .list_data     (list_data_3),
    .http_src_addr (http_src_addr_3),
    .http_src_data (http_src_data_3),
    .http_dst_addr (http_dst_addr_3),
    .http_dst_data (http_dst_data_3),
    .port_match    (port_match_3)
);

rom_2port #(
    .DWIDTH(PG_ENTRY_WIDTH),
    .AWIDTH(PG_AWIDTH),
    .MEM_SIZE(PG_DEPTH),
    .INIT_FILE("./src/memory_init/pg_meta.mif")
)
pg_entry_table_0_1 (
    .q_a       (pg_entry_data_0),
    .q_b       (pg_entry_data_1),
    .address_a (pg_entry_addr_0),
    .address_b (pg_entry_addr_1),
    .clock     (clk)
);
rom_2port #(
    .DWIDTH(PG_ENTRY_WIDTH),
    .AWIDTH(PG_AWIDTH),
    .MEM_SIZE(PG_DEPTH),
    .INIT_FILE("./src/memory_init/pg_meta.mif")
)
pg_entry_table_2_3 (
    .q_a       (pg_entry_data_2),
    .q_b       (pg_entry_data_3),
    .address_a (pg_entry_addr_2),
    .address_b (pg_entry_addr_3),
    .clock     (clk)
);

rom_2port #(
    .DWIDTH(16),
    .AWIDTH(PG_AWIDTH),
    .MEM_SIZE(PG_DEPTH),
    .INIT_FILE("./src/memory_init/pg_single_value.mif")
)
single_table_0_1 (
    .q_a       (single_data_0),
    .q_b       (single_data_1),
    .address_a (single_addr_0),
    .address_b (single_addr_1),
    .clock     (clk)
);
rom_2port #(
    .DWIDTH(16),
    .AWIDTH(PG_AWIDTH),
    .MEM_SIZE(PG_DEPTH),
    .INIT_FILE("./src/memory_init/pg_single_value.mif")
)
single_table_2_3 (
    .q_a       (single_data_2),
    .q_b       (single_data_3),
    .address_a (single_addr_2),
    .address_b (single_addr_3),
    .clock     (clk)
);

rom_1port_mlab #(
    .DWIDTH(PG_RANGE_DWIDTH),
    .AWIDTH(PG_RANGE_AWIDTH),
    .MEM_SIZE(PG_RANGE_DEPTH),
    .INIT_FILE("./src/memory_init/pg_range.mif")
)
range_table_0 (
    .address   (range_addr_0),
    .clock     (clk),
    .q         (range_data_0)
);

rom_1port_mlab #(
    .DWIDTH(PG_RANGE_DWIDTH),
    .AWIDTH(PG_RANGE_AWIDTH),
    .MEM_SIZE(PG_RANGE_DEPTH),
    .INIT_FILE("./src/memory_init/pg_range.mif")
)
range_table_1 (
    .address   (range_addr_1),
    .clock     (clk),
    .q         (range_data_1)
);

rom_1port_mlab #(
    .DWIDTH(PG_RANGE_DWIDTH),
    .AWIDTH(PG_RANGE_AWIDTH),
    .MEM_SIZE(PG_RANGE_DEPTH),
    .INIT_FILE("./src/memory_init/pg_range.mif")
)
range_table_2 (
    .address   (range_addr_2),
    .clock     (clk),
    .q         (range_data_2)
);


rom_1port_mlab #(
    .DWIDTH(PG_RANGE_DWIDTH),
    .AWIDTH(PG_RANGE_AWIDTH),
    .MEM_SIZE(PG_RANGE_DEPTH),
    .INIT_FILE("./src/memory_init/pg_range.mif")
)
range_table_3 (
    .address   (range_addr_3),
    .clock     (clk),
    .q         (range_data_3)
);

rom_1port_mlab #(
    .DWIDTH  (PG_LIST_DWIDTH),
    .AWIDTH  (PG_LIST_AWIDTH),
    .MEM_SIZE(PG_LIST_DEPTH),
    .INIT_FILE("./src/memory_init/pg_list.mif")
)
list_table_0 (
    .address   (list_addr_0),
    .clock     (clk),
    .q         (list_data_0)
);

rom_1port_mlab #(
    .DWIDTH  (PG_LIST_DWIDTH),
    .AWIDTH  (PG_LIST_AWIDTH),
    .MEM_SIZE(PG_LIST_DEPTH),
    .INIT_FILE("./src/memory_init/pg_list.mif")
)
list_table_1 (
    .address   (list_addr_1),
    .clock     (clk),
    .q         (list_data_1)
);

rom_1port_mlab #(
    .DWIDTH  (PG_LIST_DWIDTH),
    .AWIDTH  (PG_LIST_AWIDTH),
    .MEM_SIZE(PG_LIST_DEPTH),
    .INIT_FILE("./src/memory_init/pg_list.mif")
)
list_table_2 (
    .address   (list_addr_2),
    .clock     (clk),
    .q         (list_data_2)
);

rom_1port_mlab #(
    .DWIDTH  (PG_LIST_DWIDTH),
    .AWIDTH  (PG_LIST_AWIDTH),
    .MEM_SIZE(PG_LIST_DEPTH),
    .INIT_FILE("./src/memory_init/pg_list.mif")
)
list_table_3 (
    .address   (list_addr_3),
    .clock     (clk),
    .q         (list_data_3)
);

rom_2port #(
    .DWIDTH  (PG_HTTP_DWIDTH),
    .AWIDTH  (PG_HTTP_AWIDTH),
    .MEM_SIZE(PG_HTTP_DEPTH),
    .INIT_FILE("./src/memory_init/pg_http_src.mif")
)
http_src_table_0_1 (
    .q_a       (http_src_data_0),
    .q_b       (http_src_data_1),
    .address_a (http_src_addr_0),
    .address_b (http_src_addr_1),
    .clock     (clk)
);
rom_2port #(
    .DWIDTH  (PG_HTTP_DWIDTH),
    .AWIDTH  (PG_HTTP_AWIDTH),
    .MEM_SIZE(PG_HTTP_DEPTH),
    .INIT_FILE("./src/memory_init/pg_http_src.mif")
)
http_src_table_2_3 (
    .q_a       (http_src_data_2),
    .q_b       (http_src_data_3),
    .address_a (http_src_addr_2),
    .address_b (http_src_addr_3),
    .clock     (clk)
);

rom_2port #(
    .DWIDTH  (PG_HTTP_DWIDTH),
    .AWIDTH  (PG_HTTP_AWIDTH),
    .MEM_SIZE(PG_HTTP_DEPTH),
    .INIT_FILE("./src/memory_init/pg_http_dst.mif")
)
http_dst_table_0_1 (
    .q_a       (http_dst_data_0),
    .q_b       (http_dst_data_1),
    .address_a (http_dst_addr_0),
    .address_b (http_dst_addr_1),
    .clock     (clk)
);
rom_2port #(
    .DWIDTH  (PG_HTTP_DWIDTH),
    .AWIDTH  (PG_HTTP_AWIDTH),
    .MEM_SIZE(PG_HTTP_DEPTH),
    .INIT_FILE("./src/memory_init/pg_http_dst.mif")
)
http_dst_table_2_3 (
    .q_a       (http_dst_data_2),
    .q_b       (http_dst_data_3),
    .address_a (http_dst_addr_2),
    .address_b (http_dst_addr_3),
    .clock     (clk)
);

endmodule
