//Unified pkt FIFO
//FIFO_NAME, a string describes the name of the FIFO
//MEM_TYPE, could be either "M20K" (BRAM) or MLAB (LUTRAM)
//DUAL_CLOCK, 0 or 1; 0 is single clock, 1 is dual clock
//USE_ALMOST_FULL, 0 or 1; 0 means not using almost_full, use in_ready for
//backpressure. 1 means ONLY use almost_full for backpressure.
//FULL_LEVEL, if the FIFO occupancy reaches this value, almost_full will be raised.
`timescale 1 ps / 1 ps
module unified_pkt_fifo #(
    //new parameters
    parameter FIFO_NAME = "FIFO",
    parameter MEM_TYPE = "M20K",
    parameter DUAL_CLOCK = 0,
    parameter USE_ALMOST_FULL = 0,
    parameter FULL_LEVEL = 450,//does not matter is USE_ALMOST_FULL is 0
    //parameters used for generated IP
    parameter SYMBOLS_PER_BEAT    = 64,
    parameter BITS_PER_SYMBOL     = 8,
    parameter FIFO_DEPTH          = 512
) (
	input  logic         in_clk,   
	input  logic         in_reset, 
	input  logic         out_clk,  //Only used in DC mode
	input  logic         out_reset,
	input  logic [SYMBOLS_PER_BEAT*BITS_PER_SYMBOL-1:0] in_data, 		
    input  logic         in_valid,         
	output logic         in_ready,         
	input  logic         in_startofpacket, 
	input  logic         in_endofpacket,   
	input  logic [5:0]   in_empty,         
	output logic [SYMBOLS_PER_BEAT*BITS_PER_SYMBOL-1:0] out_data,
	output logic         out_valid,         
	input  logic         out_ready,         
	output logic         out_startofpacket, 
	output logic         out_endofpacket,   
	output logic [5:0]   out_empty,         
    //new signals
    output logic [31:0]  fill_level, //current occupancy
    output logic         almost_full, //current occupancy reaches FULL_LEVEL
    output logic         overflow    //only used for RTL sim for now
);

generate
    if(USE_ALMOST_FULL==1)begin
        always @(posedge in_clk) begin
            if (in_reset) begin
                almost_full <= 0;
            end
            else begin
                if (fill_level >= FULL_LEVEL) begin
                    almost_full <= 1;
                end
                else begin
                    almost_full <= 0;
                end
            end
        end

        //When almost_full is high, upstream should deassert in_valid after some delay. 
        //If the upstream fails to do so, 'overflow' can happen. 
        //The upstream thinks the data is passing through,
        //but the data is not accepted as in_ready is low. 
        always @(posedge in_clk)begin
            if (in_reset)begin
                overflow <= 1'b0;
            end else begin
                if(in_valid & !in_ready)begin
                    overflow <= 1'b1;
                    //Debug
                    $error("%s overflows!",FIFO_NAME);
                    $finish;
                end
            end
        end
    end else begin
        assign almost_full = 1'b0;
        assign overflow = 1'b0;
    end

    //dual clock
    if(DUAL_CLOCK==1)begin
        if(MEM_TYPE=="M20K")begin
            dc_fifo_wrapper_infill #(
                .SYMBOLS_PER_BEAT(SYMBOLS_PER_BEAT),
                .BITS_PER_SYMBOL(BITS_PER_SYMBOL),
                .FIFO_DEPTH(FIFO_DEPTH),
                .USE_PACKETS(1)
            )
            dc_pkt_fifo (
                .in_clk            (in_clk),
                .in_reset_n        (!in_reset),
                .out_clk           (out_clk),
                .out_reset_n       (!out_reset),
                .in_csr_address    (0),
                .in_csr_read       (1'b1),
                .in_csr_write      (1'b0),
                .in_csr_readdata   (fill_level),
                .in_csr_writedata  (0),
                .in_data           (in_data),
                .in_valid          (in_valid),
                .in_ready          (in_ready),
                .in_startofpacket  (in_startofpacket),
                .in_endofpacket    (in_endofpacket),
                .in_empty          (in_empty),
                .out_data          (out_data),
                .out_valid         (out_valid),
                .out_ready         (out_ready),
                .out_startofpacket (out_startofpacket),
                .out_endofpacket   (out_endofpacket),
                .out_empty         (out_empty)
            );
        end else begin
            dc_fifo_wrapper_infill_mlab #(
                .SYMBOLS_PER_BEAT(SYMBOLS_PER_BEAT),
                .BITS_PER_SYMBOL(BITS_PER_SYMBOL),
                .FIFO_DEPTH(FIFO_DEPTH),
                .USE_PACKETS(1)
            )
            dc_pkt_fifo_mlab (
                .in_clk            (in_clk),
                .in_reset_n        (!in_reset),
                .out_clk           (out_clk),
                .out_reset_n       (!out_reset),
                .in_csr_address    (0),
                .in_csr_read       (1'b1),
                .in_csr_write      (1'b0),
                .in_csr_readdata   (fill_level),
                .in_csr_writedata  (0),
                .in_data           (in_data),
                .in_valid          (in_valid),
                .in_ready          (in_ready),
                .in_startofpacket  (in_startofpacket),
                .in_endofpacket    (in_endofpacket),
                .in_empty          (in_empty),
                .out_data          (out_data),
                .out_valid         (out_valid),
                .out_ready         (out_ready),
                .out_startofpacket (out_startofpacket),
                .out_endofpacket   (out_endofpacket),
                .out_empty         (out_empty)
            );
        end
    //single clock
    end else begin
        if(MEM_TYPE=="M20K")begin
            fifo_pkt_wrapper_infill #(
                .SYMBOLS_PER_BEAT(SYMBOLS_PER_BEAT),
                .BITS_PER_SYMBOL(BITS_PER_SYMBOL),
                .FIFO_DEPTH(FIFO_DEPTH),
                .USE_PACKETS(1)
            )
            sc_pkt_fifo (
                .clk               (in_clk),
                .reset             (in_reset),
                .csr_address       (0),
                .csr_read          (1'b1),
                .csr_write         (1'b0),
                .csr_readdata      (fill_level),
                .csr_writedata     (0),
                .in_data           (in_data),
                .in_valid          (in_valid),
                .in_ready          (in_ready),
                .in_startofpacket  (in_startofpacket),
                .in_endofpacket    (in_endofpacket),
                .in_empty          (in_empty),
                .out_data          (out_data),
                .out_valid         (out_valid),
                .out_ready         (out_ready),
                .out_startofpacket (out_startofpacket),
                .out_endofpacket   (out_endofpacket),
                .out_empty         (out_empty)
            );
        end else begin
            fifo_pkt_wrapper_infill_mlab #(
                .SYMBOLS_PER_BEAT(SYMBOLS_PER_BEAT),
                .BITS_PER_SYMBOL(BITS_PER_SYMBOL),
                .FIFO_DEPTH(FIFO_DEPTH),
                .USE_PACKETS(1)
            )
            sc_pkt_fifo_mlab (
                .clk               (in_clk),
                .reset             (in_reset),
                .csr_address       (0),
                .csr_read          (1'b1),
                .csr_write         (1'b0),
                .csr_readdata      (fill_level),
                .csr_writedata     (0),
                .in_data           (in_data),
                .in_valid          (in_valid),
                .in_ready          (in_ready),
                .in_startofpacket  (in_startofpacket),
                .in_endofpacket    (in_endofpacket),
                .in_empty          (in_empty),
                .out_data          (out_data),
                .out_valid         (out_valid),
                .out_ready         (out_ready),
                .out_startofpacket (out_startofpacket),
                .out_endofpacket   (out_endofpacket),
                .out_empty         (out_empty)
            );
        end
    end
endgenerate

endmodule
