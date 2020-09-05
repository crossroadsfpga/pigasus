`include "./struct_s.sv"

// Take the raw pkts and the hdr length, strip
// out the hdr, and send out aligned payload.
module data_align (
    input   logic           clk,
    input   logic           rst,
    input   logic [8:0]     in_pkt_hdr,
    input   logic           in_pkt_sop,
    input   logic           in_pkt_eop,
    input   logic           in_pkt_valid,
    input   logic [511:0]   in_pkt_data,
    input   logic [5:0]     in_pkt_empty,
    output  logic           in_pkt_ready,
    output  logic           out_pkt_sop,
    output  logic           out_pkt_eop,
    output  logic           out_pkt_valid,
    output  logic [511:0]   out_pkt_data,
    output  logic [5:0]     out_pkt_empty,
    input   logic           out_pkt_ready
);

// Need to be 9 bits to allow left shift
logic [8:0]   offset;

logic [511:0] pkt_data_first;
logic [511:0] pkt_data_second;

logic [8:0]   in_pkt_hdr_r1;
logic         in_pkt_sop_r1;
logic         in_pkt_eop_r1;
logic         in_pkt_valid_r1;
logic [511:0] in_pkt_data_r1;
logic [5:0]   in_pkt_empty_r1;

logic         out_pkt_sop_r1;
logic         out_pkt_eop_r1;
logic         out_pkt_valid_r1;
logic [511:0] out_pkt_data_r1;
logic [5:0]   out_pkt_empty_r1;

logic [4:0]   hdr_flits;
logic [4:0]   flits_cnt;

assign pkt_data_first = out_pkt_data_r1 << (offset*8);
assign pkt_data_second = in_pkt_data_r1 >> ((64-offset)*8);

// No back pressure (fully pipelined)
assign in_pkt_ready = 1;

// Logic for alignment
always @(posedge clk) begin
    if (rst) begin
        out_pkt_valid <= 0;
        out_pkt_valid_r1 <= 0;
    end
    else begin
        out_pkt_valid_r1  <= in_pkt_valid_r1;
        out_pkt_valid <= out_pkt_valid_r1;

        out_pkt_data_r1 <= in_pkt_data_r1;
        out_pkt_sop_r1  <= in_pkt_sop_r1;
        out_pkt_eop_r1  <= in_pkt_eop_r1;
        out_pkt_empty_r1  <= in_pkt_empty_r1;

        out_pkt_eop <= out_pkt_eop_r1;
        out_pkt_sop <= out_pkt_sop_r1;
        out_pkt_empty <= out_pkt_empty_r1;
        out_pkt_data <= pkt_data_first | pkt_data_second;

        // Last flit is removed
        if (in_pkt_valid_r1 & in_pkt_eop_r1) begin
            // Single flit case
            if (in_pkt_sop_r1) begin
                out_pkt_empty_r1 <= offset + in_pkt_empty_r1;
            end
            else begin
                if ((offset + in_pkt_empty_r1) >= 64) begin
                    out_pkt_empty <= offset + in_pkt_empty_r1 - 64;
                    out_pkt_eop <= 1;
                    // Next flit (last flit) is removed
                    out_pkt_eop_r1  <= 0;
                    out_pkt_valid_r1 <= 0;
                end
                else begin
                    out_pkt_empty_r1 <= offset + in_pkt_empty_r1;
                end
            end
        end
    end
end

assign hdr_flits = in_pkt_hdr >> 6;
// Logic for removing header flits
always @(posedge clk) begin
    if (rst) begin
        in_pkt_valid_r1 <= 0;
        in_pkt_sop_r1 <= 0;
    end
    else begin
        in_pkt_valid_r1 <= 0;
        in_pkt_sop_r1 <= 0;
        if (flits_cnt >= hdr_flits) begin
            in_pkt_valid_r1 <= in_pkt_valid;
        end
        if (flits_cnt == hdr_flits) begin
            in_pkt_sop_r1 <= 1'b1;
        end
    end
    in_pkt_empty_r1 <= in_pkt_empty;
    in_pkt_data_r1  <= in_pkt_data;
    in_pkt_eop_r1   <= in_pkt_eop;
    in_pkt_hdr_r1   <= in_pkt_hdr;
end

// Count flits
always @(posedge clk) begin
    if (rst) begin
        flits_cnt <= 0;
    end
    else begin
        if (in_pkt_valid) begin
            if (in_pkt_eop) begin
                flits_cnt <= 0;
            end
            else begin
                flits_cnt <= flits_cnt + 1'b1;
            end
        end
    end
end

// Latch offset for alignment
always @(posedge clk) begin
    if (rst) begin
        offset <= 0;
    end
    else begin
        if (in_pkt_valid_r1 & in_pkt_sop_r1) begin
            offset <= in_pkt_hdr_r1 & {6{1'b1}};
        end
    end
end

endmodule
