`include "./struct_s.sv"
`timescale 1 ps / 1 ps

module port_unit(
    input   logic                   clk,
    input   logic                   rst,
    input   logic [PG_AWIDTH-1:0]   in_pg,
    input   logic                   in_pg_valid,
    input   logic [15:0]            src_port,
    input   logic [15:0]            dst_port,
    input   logic                   tcp,
    output  logic [PG_AWIDTH-1:0]   pg_entry_addr,
    input   pg_entry_t              pg_entry_data,
    output  logic [PG_AWIDTH-1:0]   single_addr,
    input   logic [15:0]            single_data,
    output  logic [4:0]             range_addr,
    input   pg_range_t              range_data,
    output  logic [4:0]             list_addr,
    input   pg_list_t               list_data,
    output  logic [10:0]            http_src_addr,
    input   logic [31:0]            http_src_data,
    output  logic [10:0]            http_dst_addr,
    input   logic [31:0]            http_dst_data,
    output  logic                   port_match
);

logic rd_pg;
logic rd_pg_r;
logic rd_pg_valid;
logic rd_pg_valid_r;

logic reg_tcp;
logic [15:0] reg_src_port;
logic [15:0] reg_dst_port;

logic any;
logic any_r1;
logic any_r2;
logic any_r3;
logic any_r4;
logic any_r5;
logic any_r6;

logic [PG_AWIDTH-1:0] pg_r1;
logic [PG_AWIDTH-1:0] pg_r2;
logic [PG_AWIDTH-1:0] pg_r3;
logic [PG_AWIDTH-1:0] pg_r4;
logic [PG_AWIDTH-1:0] pg_r5;
pg_entry_t pg_entry_data_r1;

logic single_rd;
logic single_rd_r;
logic single_rd_valid;
logic [15:0] check_port;
logic [15:0] check_port_r1;
logic [15:0] check_port_r2;
logic [15:0] check_port_r3;
logic [15:0] check_port_r4;
logic [15:0] check_port_r5;
logic single_match;
logic single_match_r1;
logic single_match_r2;
logic single_match_r3;

logic range_rd;
logic range_rd_r;
logic range_rd_valid;
logic range_match;
logic range_match_r1;
logic range_match_r2;
logic range_match_r3;

logic list_rd;
logic list_rd_r1;
logic list_rd_r2;
logic list_rd_r3;
logic list_rd_r;
logic list_rd_valid;

logic [4:0] list_index;
logic [4:0] list_index_r1;
logic [4:0] list_index_r2;
logic [4:0] list_index_r3;

logic [6:0] list_bm;
logic list_bm_match;
logic list_match;

logic http_src_rd;
logic http_src_rd_r;
logic http_src_rd_valid;
logic http_src_match;
logic http_src_match_r1;
logic http_src_match_r2;
logic http_src_match_r3;

logic http_dst_rd;
logic http_dst_rd_r;
logic http_dst_rd_valid;
logic http_dst_match;
logic http_dst_match_r1;
logic http_dst_match_r2;
logic http_dst_match_r3;

assign pg_entry_addr = pg_r1;
assign single_addr = pg_r5;
assign list_addr = list_index_r3;

// First stage: index rule2pg table
always @(posedge clk) begin

    // CYCLE 1
    // Read pg entry table based on rule_rd_valid
    rd_pg <= in_pg_valid;
    pg_r1 <= in_pg;

    // CYCLE 2
    // pg entry table read delay 1
    rd_pg_r <= rd_pg;
    pg_r2   <= pg_r1;

    // CYCLE 3
    // pg entry table read delay 2
    rd_pg_valid <= rd_pg_r;
    pg_r3       <= pg_r2;

    // CYCLE 4
    // Pass the output pg_entry
    pg_entry_data_r1 <= pg_entry_data;
    rd_pg_valid_r <= rd_pg_valid;
    pg_r4 <= pg_r3;

    // CYCLE 5
    // Parse the meta data bits
    pg_r5           <= pg_r4;
    any             <= 0;
    single_rd       <= 0;
    range_rd        <= 0;
    range_addr      <= 0;
    list_rd         <= 0;
    list_index      <= 0;
    check_port      <= 0;
    http_src_rd     <= 0;
    http_dst_rd     <= 0;
    http_src_addr   <= 0;
    http_dst_addr   <= 0;

    // Read single value table
    if ((rd_pg_valid_r) & (reg_tcp == pg_entry_data_r1.tcp)) begin
        if (pg_entry_data_r1.any) begin
            any <= 1;
        end
        else begin
            if (pg_entry_data_r1.single) begin
                single_rd <= 1;
            end
            // Range has higher priority than list
            else if (pg_entry_data_r1.range) begin
                range_rd <= 1;
                range_addr <= pg_entry_data_r1.table_index;
            end
            else if (pg_entry_data_r1.list) begin
                list_rd <= 1;
                list_index <= pg_entry_data_r1.table_index;
            end
            else begin
                if (pg_entry_data_r1.src) begin
                    http_src_rd <= 1;
                    http_src_addr <= reg_src_port >> 5;
                end
                else begin
                    http_dst_rd <= 1;
                    http_dst_addr <= reg_dst_port >> 5;
                end
            end
        end
        if (pg_entry_data_r1.src) begin
            check_port <= reg_src_port;
        end
        else begin
            check_port <= reg_dst_port;
        end
    end

    // CYCLE 6
    // Table read delay 1, forward other signals
    any_r1              <= any;
    single_rd_r         <= single_rd;
    range_rd_r          <= range_rd;
    list_rd_r1          <= list_rd;
    list_index_r1       <= list_index;
    http_src_rd_r       <= http_src_rd;
    http_dst_rd_r       <= http_dst_rd;
    check_port_r1       <= check_port;

    // CYCLE 7
    // Table read delay 2, forward other signals, read the Range
    // Table at the same cycle
    any_r2              <= any_r1;
    single_rd_valid     <= single_rd_r;
    range_rd_valid      <= range_rd_r;
    list_rd_r2          <= list_rd_r1;
    list_index_r2       <= list_index_r1;
    http_src_rd_valid   <= http_src_rd_r;
    http_dst_rd_valid   <= http_dst_rd_r;
    check_port_r2       <= check_port_r1;

    // CYCLE 8
    // Forward other signals
    any_r3              <= any_r2;
    list_rd_r3          <= list_rd_r2;
    list_index_r3       <= list_index_r2;
    check_port_r3       <= check_port_r2;

    // Decide signals based on Table output
    single_match <= 0;
    if (single_rd_valid & (single_data == check_port_r2)) begin
        single_match <= 1;
    end

    range_match <= 0;
    if (range_rd_valid) begin
        if (((check_port_r2 >= range_data.range_start0) & (check_port_r2 <= range_data.range_end0)) |
            ((check_port_r2 >= range_data.range_start1) & (check_port_r2 <= range_data.range_end1)) |
            ((check_port_r2 >= range_data.range_start2) & (check_port_r2 <= range_data.range_end2)) ) begin
            range_match <= 1;
        end
        // Trigger the list check even if there is no range match. It is
        // safe to do so as one port group can be either range or list.
        if (range_data.list) begin
            list_rd_r3 <= 1;
            list_index_r3 <= range_data.list_index;
        end
    end

    http_src_match <= 0;
    if (http_src_rd_valid) begin
        if ((http_src_data >> check_port_r2[4:0]) & 1) begin
            http_src_match <= 1;
        end
    end

    http_dst_match <= 0;
    if (http_dst_rd_valid) begin
        if ((http_dst_data >> check_port_r2[4:0]) & 1) begin
            http_dst_match <= 1;
        end
    end

    // CYCLE 9
    // Read List Table delay 1
    any_r4              <= any_r3;
    single_match_r1     <= single_match;
    range_match_r1      <= range_match;
    http_src_match_r1   <= http_src_match;
    http_dst_match_r1   <= http_dst_match;
    check_port_r4       <= check_port_r3;
    list_rd_r           <= list_rd_r3;


    // CYCLE 10
    // Read List Table delay 2
    any_r5              <= any_r4;
    single_match_r2     <= single_match_r1;
    range_match_r2      <= range_match_r1;
    http_src_match_r2   <= http_src_match_r1;
    http_dst_match_r2   <= http_dst_match_r1;
    check_port_r5       <= check_port_r4;
    list_rd_valid       <= list_rd_r;


    // CYCLE 11
    // Compare the List Table output with check_port
    any_r6              <= any_r5;
    single_match_r3     <= single_match_r2;
    range_match_r3      <= range_match_r2;
    http_src_match_r3   <= http_src_match_r2;
    http_dst_match_r3   <= http_dst_match_r2;
    list_match          <= 0;

    if (list_rd_valid) begin
        list_match <= list_bm_match;
    end

    // CYCLE 12
    port_match <= (any_r6 | single_match_r3 | range_match_r3 |
                   http_src_match_r3 | http_dst_match_r3 | list_match);
end

assign list_bm[0] = (check_port_r5 == list_data.value0);
assign list_bm[1] = (check_port_r5 == list_data.value1);
assign list_bm[2] = (check_port_r5 == list_data.value2);
assign list_bm[3] = (check_port_r5 == list_data.value3);
assign list_bm[4] = (check_port_r5 == list_data.value4);
assign list_bm[5] = (check_port_r5 == list_data.value5);
assign list_bm[6] = (check_port_r5 == list_data.value6);
assign list_bm_match = (list_bm[0] | list_bm[1] | list_bm[2] | list_bm[3] |
                        list_bm[4] | list_bm[5] | list_bm[6]);

hyper_pipe #(
    .WIDTH (1),
    .NUM_PIPES(4)
) hp_tcp (
    .clk(clk),
    .din(tcp),
    .dout(reg_tcp)
);

hyper_pipe #(
    .WIDTH (16),
    .NUM_PIPES(4)
) hp_src_port (
    .clk(clk),
    .din(src_port),
    .dout(reg_src_port)
);

hyper_pipe #(
    .WIDTH (16),
    .NUM_PIPES(6)
) hp_dst_port (
    .clk(clk),
    .din(dst_port),
    .dout(reg_dst_port)
);

endmodule
