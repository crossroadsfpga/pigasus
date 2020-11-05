`include "./src/struct_s.sv"
module data_shift (
    input   logic           clk,
    input   logic           rst,
    input   logic           in_pkt_sop,
    input   logic           in_pkt_eop,
    input   logic           in_pkt_valid,
    input   logic [255:0]   in_pkt_data,
    input   logic [4:0]     in_pkt_empty,
    output  logic           in_pkt_ready,
    input   metadata_t      in_meta_data,
    input   logic           in_meta_valid,
    output  logic           in_meta_ready,
    output  logic           out_pkt_sop,
    output  logic           out_pkt_eop,
    output  logic           out_pkt_valid,
    output  logic [255:0]   out_pkt_data,
    output  logic [4:0]     out_pkt_empty,
    input   logic           out_pkt_ready
);

logic [255:0]   in_pkt_data_r;
logic           last_flit;
logic [4:0]     last_empty;
logic           shift;
logic [63:0]    shift_data;
logic           shift_latch;
logic           udp;
logic           udp_latch;

// No back pressure for now
assign in_pkt_ready = 1;

assign shift = in_pkt_valid & in_pkt_sop;
assign in_meta_ready = shift;
assign shift_data = {8'hff, in_meta_data.last_7_bytes};
assign udp = in_meta_valid & in_meta_ready & (in_meta_data.prot == PROT_UDP);

// Create a window for shifted flits.
always @(posedge clk) begin
    if (in_pkt_valid) begin
        if (in_pkt_sop) begin
            if (in_pkt_eop) begin
                shift_latch <= 0;
                udp_latch <= 0;
            end
            else begin
                if (shift) begin
                    shift_latch <= 1;
                end
                if (udp) begin
                    udp_latch <= 1;
                end
            end
        end
        else begin
            if (in_pkt_eop) begin
                shift_latch <= 0;
                udp_latch <= 0;
            end
        end
    end
end

// Datapath
always @(posedge clk) begin
    if (udp | udp_latch) begin
        out_pkt_sop <= in_pkt_sop;
        out_pkt_eop <= in_pkt_eop;
        out_pkt_empty <= in_pkt_empty;
        out_pkt_data <= in_pkt_data;
        out_pkt_valid <= in_pkt_valid;
    end
    else begin
        in_pkt_data_r <= in_pkt_data;
        if (shift | shift_latch) begin
            // First flit
            if (in_pkt_valid & in_pkt_sop) begin
                out_pkt_data <= {shift_data, in_pkt_data[255:64]};
            end
            // The remaining flits
            else begin
                out_pkt_data <= {in_pkt_data_r[63:0],
                                 in_pkt_data[255:64]};
            end
        end
        else if (last_flit) begin
            out_pkt_data <= {in_pkt_data_r[63:0], {192{1'b1}}};
        end
        else begin
            out_pkt_data <= in_pkt_data;
        end

        last_flit <= 0;
        last_empty <= 0;
        out_pkt_sop <= in_pkt_sop;
        out_pkt_eop <= 0;
        out_pkt_empty <= 0;

        // Handle eop and empty signals
        if (in_pkt_valid) begin
            if (in_pkt_eop) begin
                // No need to create a new flit
                if (in_pkt_empty >= 5'd8) begin
                    out_pkt_empty <= in_pkt_empty - 5'd8;
                    out_pkt_eop <= 1;
                end
                // Create a new flit
                else begin
                    last_flit <= 1;
                    last_empty <= in_pkt_empty + 5'd24;
                end
            end
        end

        // One cycle delay
        if (last_flit) begin
            out_pkt_eop <= 1;
            out_pkt_empty <= last_empty;
            out_pkt_valid <= 1;
        end
        else begin
            out_pkt_valid <= in_pkt_valid;
        end
    end
end

endmodule
