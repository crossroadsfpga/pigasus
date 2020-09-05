`include "./struct_s.sv"

module ruleID (
    input   logic           clk,
    input   logic           rst,
    input   logic [511:0]   in_data,
    input   logic           in_valid,
    output  logic           in_ready,
    // Status register bus
    input   logic           clk_status,
    input   logic   [29:0]  status_addr,
    input   logic           status_read,
    input   logic           status_write,
    input   logic   [31:0]  status_writedata,
    output  logic   [31:0]  status_readdata,
    output  logic           status_readdata_valid
);

logic [511:0]           data;
logic [12:0]            rdaddress;
logic                   rden;
logic [8:0]             wraddress;
logic                   wren;
logic [31:0]            q;

logic [29:0]            status_addr_r;
logic [STAT_AWIDTH-1:0] status_addr_sel_r;
logic                   status_read_r;
logic                   status_write_r;
logic [31:0]            status_writedata_r;

logic                   read_valid;
logic                   rden_r;
logic [511:0]           in_data_r1;
logic [511:0]           in_data_r2;
logic                   in_valid_r1;
logic                   in_valid_r2;

// Never stall
assign in_ready = 1'b1;

always @(posedge clk_status) begin
    rden_r <= rden;
    read_valid <= rden_r;
end

//////////////////////////////
// Read and Write registers //
//////////////////////////////
always @(posedge clk_status) begin
    status_addr_sel_r       <= status_addr[29:30-STAT_AWIDTH];

    status_read_r           <= status_read;
    status_write_r          <= status_write;
    status_writedata_r      <= status_writedata;
    status_readdata_valid   <= 1'b0;
    status_readdata         <= status_readdata;

    rden <= status_read_r & (status_addr_sel_r == RULEID);

    if (status_read_r) begin
        if (status_addr_sel_r == RULEID) begin
            rdaddress <= status_addr[12:0];
        end
    end

    if (read_valid) begin
        status_readdata <= q;
        status_readdata_valid <= 1;
    end
end

always @(posedge clk) begin
    in_data_r1 <= in_data;
    in_data_r2 <= in_data_r1;

    in_valid_r1 <= in_valid;
    in_valid_r2 <= in_valid_r1;
end

always @(posedge clk) begin
    if (rst) begin
        wraddress <= 0;
        wren <= 0;
    end
    else begin
        wren <= 0;
        if (wraddress != 511) begin
            if (in_valid_r2) begin
                wren <= 1;
                data <= in_data_r2;
            end
            if (wren) begin
                wraddress <= wraddress + 1'b1;
            end
        end
    end
end

bram_dc_diff_width ruleID_mem (
    .data       (data),
    .rdaddress  (rdaddress),
    .rdclock    (clk_status),
    .rden       (rden),
    .wraddress  (wraddress),
    .wrclock    (clk),
    .wren       (wren),
    .q          (q)
);

// Debug
always @(posedge clk) begin
    if (wren) begin
        $display("Wr addr %d, data %x", wraddress, data);
    end
end

endmodule
