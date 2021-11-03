`include "./src/struct_s.sv"
//`define DUMMY
module rule_packer_32_512 (
    input   logic           clk,
    input   logic           rst,
    input   logic           in_rule_sop,
    input   logic           in_rule_eop,
    input   logic [1:0]     in_rule_empty,
    input   logic           in_rule_valid,
    input   logic [31:0]    in_rule_data,
    output  logic           in_rule_ready,

    output  logic           out_rule_sop,
    output  logic           out_rule_eop,
    output  logic           out_rule_valid,
    output  logic [511:0]   out_rule_data,
    output  logic [5:0]     out_rule_empty,
    input   logic           out_rule_ready
);

logic [7:0] flit_cnt;
`ifdef DUMMY
    assign out_rule_sop   = in_rule_sop;
    assign out_rule_empty = in_rule_empty;
    assign out_rule_eop   = in_rule_eop;
    assign out_rule_data  = in_rule_data;
    assign out_rule_valid = in_rule_valid;
    assign in_rule_ready  = out_rule_ready;
`else
logic [7:0] int_cnt;

assign out_rule_empty = 0;

// Convert to 512 bit for PCIe.
assign in_rule_ready = !(in_rule_eop & int_cnt != 0) & out_rule_ready;

always @(posedge clk) begin
    if (rst) begin
        int_cnt <= 0;
        out_rule_sop <= 0;
        out_rule_eop <= 0;
        out_rule_data <= 0;
        out_rule_valid <= 0;
        flit_cnt <= 0;
    end else begin
        if(out_rule_ready)begin
            out_rule_sop <= 0;
            out_rule_eop <= 0;
            out_rule_valid <= 0;
            if (in_rule_valid) begin
                if (in_rule_eop) begin
                    // Fetch, write, clear the output
                    if (int_cnt == 0) begin
                        out_rule_valid <= 1;
                        out_rule_eop <= 1;
                        out_rule_sop <= !out_rule_sop & (flit_cnt == 0);
                    end else begin
                    // Forward the valid data first. Clear the
                    // cnt, then forward the last. Wait, write
                    // whatever is there.
                        int_cnt <= 0;
                        out_rule_valid <= 1;
                        out_rule_sop <= !out_rule_sop & (flit_cnt == 0);
                    end
                end else begin
                    // Fetch and write
                    if (int_cnt == 15) begin
                        int_cnt <= 0;
                        out_rule_valid <= 1;
                        out_rule_sop <= !out_rule_sop & (flit_cnt == 0);
                    end else begin
                    // Fetch, do not write
                        int_cnt <= int_cnt + 1;
                    end
                end
            end
        end
        if(out_rule_ready & out_rule_valid)begin
            if(out_rule_eop)begin
                flit_cnt <= 0;
            end else begin
                flit_cnt <= flit_cnt + 1;
            end
        end
    end

    // Clear the data
    if (in_rule_valid) begin
        if (int_cnt == 0) begin
            out_rule_data <= 0;
        end
        case (int_cnt)
            8'd0:  out_rule_data[31:0]    <= in_rule_data;
            8'd1:  out_rule_data[63:32]   <= in_rule_data;
            8'd2:  out_rule_data[95:64]   <= in_rule_data;
            8'd3:  out_rule_data[127:96]  <= in_rule_data;
            8'd4:  out_rule_data[169:128] <= in_rule_data;
            8'd5:  out_rule_data[191:160] <= in_rule_data;
            8'd6:  out_rule_data[223:192] <= in_rule_data;
            8'd7:  out_rule_data[255:224] <= in_rule_data;
            8'd8:  out_rule_data[287:256] <= in_rule_data;
            8'd9:  out_rule_data[319:288] <= in_rule_data;
            8'd10: out_rule_data[351:320] <= in_rule_data;
            8'd11: out_rule_data[383:352] <= in_rule_data;
            8'd12: out_rule_data[415:384] <= in_rule_data;
            8'd13: out_rule_data[447:416] <= in_rule_data;
            8'd14: out_rule_data[479:448] <= in_rule_data;
            8'd15: out_rule_data[511:480] <= in_rule_data;
            default: out_rule_data <= 0;
        endcase
    end
end
`endif


endmodule
