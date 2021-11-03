`include "active_msg.vh"
`include "channel_if.vh"

`define CEILING(x,y) (((x) + (y) - 1) / (y))

//
// Converts direct connected standard to NOC
// compatible ready handshake via rxPop
// 
module client_epig_shim#(SDARG_BITS=32,DATA_BITS=512)
   (
	input logic clk,
	input logic SoftReset,

	server.svr svr2fl,
        channel_if.tx tx,
        channel_if.rx rx
   );

    localparam WIDTH = DATA_BITS+6*SDARG_BITS;
    logic [WIDTH-1:0]      msg_out;
    logic [SDARG_BITS-1:0] hdr_out;
    logic [SDARG_BITS-1:0] chn_out;
    logic empty_N;
    logic full_N;

    assign svr2fl.txFull = ~tx.ready;
    assign svr2fl.txAlmostFull = tx.almost_full;
    assign tx.valid   = svr2fl.txP.tx;
    assign tx.data    = svr2fl.txP.tx_msg.data;
    assign tx.channel = svr2fl.txP.tx_msg.head.arg2;
    assign tx.empty   = svr2fl.txP.tx_msg.head.arg3[7:2];
    assign tx.eop     = svr2fl.txP.tx_msg.head.arg3[1];
    assign tx.sop     = svr2fl.txP.tx_msg.head.arg3[0];

    assign svr2fl.rxP.rx_msg.head.arg2 = chn_out;
    assign svr2fl.rxP.rx_msg.head.arg3 = hdr_out;
    assign svr2fl.rxP.rx_msg.data      = msg_out;
    assign svr2fl.rxP.rxEmpty          = ~empty_N;
    assign rx.ready = full_N;
    assign rx.almost_full = ~full_N;

    FIFO2 #(.width(SDARG_BITS), .guarded(32'd0)) conv_chnlQ
           (.RST(~SoftReset),
            .CLK(clk),
 
            .D_IN({SDARG_BITS{1'b0}}|{rx.channel}),
            .ENQ(rx.valid&full_N),
            .DEQ(svr2fl.rxPop),
            .CLR(1'b0),
            .D_OUT(chn_out),
            .FULL_N(),
            .EMPTY_N());
    FIFO2 #(.width(SDARG_BITS), .guarded(32'd0)) conv_hdrQ
           (.RST(~SoftReset),
            .CLK(clk),
 
            .D_IN({SDARG_BITS{1'b0}}|{rx.empty,rx.eop,rx.sop}),
            .ENQ(rx.valid&full_N),
            .DEQ(svr2fl.rxPop),
            .CLR(1'b0),
            .D_OUT(hdr_out),
            .FULL_N(),
            .EMPTY_N());
    FIFO2 #(.width(DATA_BITS), .guarded(32'd0)) conv_dataQ
           (.RST(~SoftReset),
            .CLK(clk),
 
            .D_IN(rx.data),
            .ENQ(rx.valid&full_N),
            .DEQ(svr2fl.rxPop),
            .CLR(1'b0),
            .D_OUT(msg_out),
            .FULL_N(full_N),
            .EMPTY_N(empty_N));

endmodule
module server_epig_shim#(SDARG_BITS=32,DATA_BITS=512) 
   (
	input logic clk,
	input logic SoftReset,

	server.clt fl2clt,
        channel_if.tx tx,
        channel_if.rx rx
   );

    assign rx.ready = ~fl2clt.txFull;
    assign rx.almost_full = fl2clt.txAlmostFull;
    assign fl2clt.txP.tx = rx.valid /*& ~fl2clt.txFull*/;
    assign fl2clt.txP.tx_msg.data = rx.data;
    assign fl2clt.txP.tx_msg.head.arg2 = rx.channel;
    assign fl2clt.txP.tx_msg.head.arg3 = {SDARG_BITS{1'b0}}|{rx.empty,rx.eop,rx.sop};

    assign tx.data      = fl2clt.rxP.rx_msg.data;
    assign tx.channel   = fl2clt.rxP.rx_msg.head.arg2;
    assign tx.sop       = fl2clt.rxP.rx_msg.head.arg3[0];
    assign tx.eop       = fl2clt.rxP.rx_msg.head.arg3[1];
    assign tx.empty     = fl2clt.rxP.rx_msg.head.arg3[7:2];
    assign tx.valid     = ~fl2clt.rxP.rxEmpty;
    assign fl2clt.rxPop = /*~fl2clt.rxP.rxEmpty &*/ tx.ready;

endmodule
//module client_epig_shim_fifo#(SDARG_BITS=32,DATA_BITS=512,DEPTH=512,AF_LVL=490)
//   (
//	input logic clk,
//	input logic SoftReset,
//
//	server.svr svr2fl,
//        channel_if.tx tx,
//        channel_if.rx rx
//   );
//
//    localparam WIDTH = DATA_BITS+6*SDARG_BITS;
//    logic [WIDTH-1:0]      msg_out;
//    logic [SDARG_BITS-1:0] hdr_out;
//    logic [SDARG_BITS-1:0] chn_out;
//    logic empty_N;
//    logic full_N;
//
//    assign svr2fl.txFull = ~tx.ready;
//    assign tx.valid   = svr2fl.txP.tx;
//    assign tx.data    = svr2fl.txP.tx_msg.data;
//    assign tx.channel = svr2fl.txP.tx_msg.head.arg2;
//    assign tx.empty   = svr2fl.txP.tx_msg.head.arg3[7:2];
//    assign tx.eop     = svr2fl.txP.tx_msg.head.arg3[1];
//    assign tx.sop     = svr2fl.txP.tx_msg.head.arg3[0];
//
//    assign svr2fl.rxP.rx_msg.head.arg2 = chn_out;
//    assign svr2fl.rxP.rx_msg.head.arg3 = hdr_out;
//    assign svr2fl.rxP.rx_msg.data      = msg_out;
//    assign svr2fl.rxP.rxEmpty          = ~empty_N;
//    assign rx.ready = full_N;
//
//    SizedFIFO_almost_full #(.p1width(SDARG_BITS),
//                            .p2depth(DEPTH),
//                            .p3cntr_width($clog2(DEPTH)),
//                            .afvalue(AF_LVL),
//                            .guarded(32'd0)) conv_chnlQ
//           (.RST(~SoftReset),
//            .CLK(clk),
// 
//            .D_IN({SDARG_BITS{1'b0}}|{rx.channel}),
//            .ENQ(rx.valid&full_N),
//            .DEQ(svr2fl.rxPop),
//            .CLR(1'b0),
//            .D_OUT(chn_out),
//            .FULL_N(),
//            .EMPTY_N());
//    SizedFIFO_almost_full #(.p1width(SDARG_BITS),
//                            .p2depth(DEPTH),
//                            .p3cntr_width($clog2(DEPTH)),
//                            .afvalue(AF_LVL),
//                            .guarded(32'd0)) conv_hdrQ
//           (.RST(~SoftReset),
//            .CLK(clk),
// 
//            .D_IN({SDARG_BITS{1'b0}}|{rx.empty,rx.eop,rx.sop}),
//            .ENQ(rx.valid&full_N),
//            .DEQ(svr2fl.rxPop),
//            .CLR(1'b0),
//            .D_OUT(hdr_out),
//            .FULL_N(),
//            .EMPTY_N());
//    SizedFIFO_almost_full #(.p1width(DATA_BITS),
//                            .p2depth(DEPTH),
//                            .p3cntr_width($clog2(DEPTH)),
//                            .afvalue(AF_LVL),
//                            .guarded(32'd0)) conv_dataQ
//           (.RST(~SoftReset),
//            .CLK(clk),
// 
//            .D_IN(rx.data),
//            .ENQ(rx.valid&full_N),
//            .DEQ(svr2fl.rxPop),
//            .CLR(1'b0),
//            .D_OUT(msg_out),
//            .ALM_FULL(rx.almost_full),
//            .FULL_N(full_N),
//            .EMPTY_N(empty_N));
//
//endmodule
//module server_epig_shim_fifo#(SDARG_BITS=32,DATA_BITS=512,DEPTH=512,AF_LVL=490) 
//   (
//	input logic clk,
//	input logic SoftReset,
//
//	server.clt fl2clt,
//        channel_if.tx tx,
//        channel_if.rx rx
//   );
//
//    logic full_N, empty_N;
//
//    assign rx.ready = full_N;
//    assign fl2clt.txP.tx = empty_N & ~fl2clt.txFull;
//    //assign rx.almost_full = 1'b1;
//    //assign fl2clt.txP.tx = rx.valid & ~fl2clt.txFull;
//    //assign fl2clt.txP.tx_msg.data = rx.data;
//    //assign fl2clt.txP.tx_msg.head.arg2 = rx.channel;
//    //assign fl2clt.txP.tx_msg.head.arg3 = {SDARG_BITS{1'b0}}|{rx.empty,rx.eop,rx.sop};
//
//    SizedFIFO_almost_full #(.p1width(SDARG_BITS),
//                            .p2depth(DEPTH),
//                            .p3cntr_width($clog2(DEPTH)),
//                            .afvalue(AF_LVL),
//                            .guarded(32'd0)) conv_chnlQ
//           (.RST(~SoftReset),
//            .CLK(clk),
// 
//            .D_IN({SDARG_BITS{1'b0}}|{rx.channel}),
//            .ENQ(rx.valid&full_N),
//            .DEQ(~fl2clt.txFull&empty_N),
//            .CLR(1'b0),
//            .D_OUT(fl2clt.txP.tx_msg.head.arg2),
//            .FULL_N(),
//            .EMPTY_N());
//    SizedFIFO_almost_full #(.p1width(SDARG_BITS),
//                            .p2depth(DEPTH),
//                            .p3cntr_width($clog2(DEPTH)),
//                            .afvalue(AF_LVL),
//                            .guarded(32'd0)) conv_hdrQ
//           (.RST(~SoftReset),
//            .CLK(clk),
// 
//            .D_IN({SDARG_BITS{1'b0}}|{rx.empty,rx.eop,rx.sop}),
//            .ENQ(rx.valid&full_N),
//            .DEQ(~fl2clt.txFull&empty_N),
//            .CLR(1'b0),
//            .D_OUT(fl2clt.txP.tx_msg.head.arg3),
//            .FULL_N(),
//            .EMPTY_N());
//    SizedFIFO_almost_full #(.p1width(DATA_BITS),
//                            .p2depth(DEPTH),
//                            .p3cntr_width($clog2(DEPTH)),
//                            .afvalue(AF_LVL),
//                            .guarded(32'd0)) conv_dataQ
//           (.RST(~SoftReset),
//            .CLK(clk),
// 
//            .D_IN(rx.data),
//            .ENQ(rx.valid&full_N),
//            .DEQ(~fl2clt.txFull&empty_N),
//            .CLR(1'b0),
//            .D_OUT(fl2clt.txP.tx_msg.data),
//            .ALM_FULL(rx.almost_full),
//            .FULL_N(full_N),
//            .EMPTY_N(empty_N));
//
//    assign tx.data      = fl2clt.rxP.rx_msg.data;
//    assign tx.channel   = fl2clt.rxP.rx_msg.head.arg2;
//    assign tx.sop       = fl2clt.rxP.rx_msg.head.arg3[0];
//    assign tx.eop       = fl2clt.rxP.rx_msg.head.arg3[1];
//    assign tx.empty     = fl2clt.rxP.rx_msg.head.arg3[7:2];
//    assign tx.valid     = ~fl2clt.rxP.rxEmpty;
//    assign fl2clt.rxPop = ~fl2clt.rxP.rxEmpty & tx.ready;
//
//endmodule


// Inject to requests
module noc_tb_client
   (
	input logic clk,
	input logic SoftReset,

	input logic sendReq,

    server.clt clt
   );

  	reg [31:0] cycle;
  	reg [31:0] i_ctr, o_ctr;
    always_ff @(posedge clk) begin
      if(SoftReset) begin
        i_ctr <= 32'd0;
        o_ctr <= 32'd0;
      end else begin
	if (clt.txP.tx) i_ctr <= i_ctr + 1;
	if (!clt.rxP.rxEmpty) o_ctr <= o_ctr + 1;
      end
    end

    always_ff @(posedge clk) begin
      if(SoftReset) begin
        clt.txP.tx <= 0;
        clt.txP.tx_msg <= 'b0;
      end else begin
    //always_comb begin 
        clt.txP.tx <= sendReq&&!clt.txFull;
        clt.txP.tx_msg.data <= {4{128'hbeef_cafe_0000_face_feed_0000_dead_face}};
      	if(clt.txFull&&clt.txP.tx) begin 
           $display("%m, @%3d: ERROR: Send while full!", cycle);
      	end
      	if(clt.txAlmostFull) begin 
           $display("%m, @%3d: WARN: Almost full!", cycle);
      	end
      	if(clt.txP.tx) begin // valid flit
           $display("%m, @%3d: Passing injected flit %d.", cycle,i_ctr+1);
      	end
      end
    end

    assign clt.rxPop = !clt.rxP.rxEmpty;
    always_ff @(posedge clk) begin
      if (SoftReset) cycle <= 0;
      else cycle <= cycle + 1;
      if(!clt.rxP.rxEmpty) begin // valid flit
        $display("%m, @%3d: Ejecting flit %d - %x.", cycle,o_ctr+1,clt.rxP.rx_msg.data);
      end
    end
endmodule

// Respond to requests
module noc_tb_server
   (
	input logic clk,
	input logic SoftReset,

        input logic stallRsp,

	server.svr svr
   );

  	reg [31:0] cycle;
    always_ff @(posedge clk) begin
      if (SoftReset) cycle <= 0;
      else cycle <= cycle + 1;
    end

   	assign svr.txFull = stallRsp;
   	assign svr.txAlmostFull = 1'b1;
   	always_ff @(posedge clk) begin
   		if(SoftReset) begin
   			svr.rxP.rxEmpty <= 1'b1;
                        svr.rxP.rx_msg <= 'b0;
   		end else begin
                        svr.rxP.rx_msg.head.srcid <= svr.txP.tx_msg.head.dstid;
                        svr.rxP.rxEmpty <= !svr.txP.tx;
                        svr.rxP.rx_msg.head.dstid <= svr.txP.tx_msg.head.srcid;
   			svr.rxP.rx_msg.data <= svr.txP.tx_msg.data;
   			if (svr.txP.tx) begin
        		$display("%m, @%3d: Serving flit data %x.", cycle, svr.txP.tx_msg.data[255:0]);
    		end
   		end
   end

endmodule
