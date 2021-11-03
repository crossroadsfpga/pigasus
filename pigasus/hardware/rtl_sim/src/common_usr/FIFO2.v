
// Copyright (c) 2000-2012 Bluespec, Inc.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// $Revision: 29755 $
// $Date: 2012-10-22 13:58:12 +0000 (Mon, 22 Oct 2012) $

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

`ifdef BSV_ASYNC_RESET
 `define BSV_ARESET_EDGE_META or `BSV_RESET_EDGE RST
`else
 `define BSV_ARESET_EDGE_META
`endif

`ifdef BSV_RESET_FIFO_HEAD
 `define BSV_ARESET_EDGE_HEAD `BSV_ARESET_EDGE_META
`else
 `define BSV_ARESET_EDGE_HEAD
`endif

// Depth 2 FIFO
module FIFO2(CLK,
             RST,
             D_IN,
             ENQ,
             FULL_N,
             D_OUT,
             DEQ,
             EMPTY_N,
             CLR);

   parameter width = 1;
   parameter guarded = 1;

   input     CLK ;
   input     RST ;
   input [width - 1 : 0] D_IN;
   input                 ENQ;
   input                 DEQ;
   input                 CLR ;

   output                FULL_N;
   output                EMPTY_N;
   output [width - 1 : 0] D_OUT;

   //
   // Pick the storage mechanism based on the FIFO's size.
   //
   generate
     if (width < 64)
       begin
          FIFO2_Reg#(.width(width), .guarded(guarded))
            fifo_reg(.CLK(CLK),
                     .RST(RST),
                     .D_IN(D_IN),
                     .ENQ(ENQ),
                     .FULL_N(FULL_N),
                     .D_OUT(D_OUT),
                     .DEQ(DEQ),
                     .EMPTY_N(EMPTY_N),
                     .CLR(CLR));
       end
     else
       begin
          FIFO2_LUTRAM#(.width(width), .guarded(guarded))
            fifo_lut(.CLK(CLK),
                     .RST(RST),
                     .D_IN(D_IN),
                     .ENQ(ENQ),
                     .FULL_N(FULL_N),
                     .D_OUT(D_OUT),
                     .DEQ(DEQ),
                     .EMPTY_N(EMPTY_N),
                     .CLR(CLR));
       end
   endgenerate

endmodule


//
// The original FIFO2 code using registers and a MUX.
//
module FIFO2_Reg(CLK,
                 RST,
                 D_IN,
                 ENQ,
                 FULL_N,
                 D_OUT,
                 DEQ,
                 EMPTY_N,
                 CLR);

   parameter width = 1;
   parameter guarded = 1;

   input     CLK ;
   input     RST ;
   input [width - 1 : 0] D_IN;
   input                 ENQ;
   input                 DEQ;
   input                 CLR ;

   output                FULL_N;
   output                EMPTY_N;
   output [width - 1 : 0] D_OUT;

   reg                    full_reg;
   reg                    empty_reg;
   reg [width - 1 : 0]    data0_reg;
   reg [width - 1 : 0]    data1_reg;

   assign                 FULL_N = full_reg ;
   assign                 EMPTY_N = empty_reg ;
   assign                 D_OUT = data0_reg ;


   // Optimize the loading logic since state encoding is not power of 2!
   wire                   d0di = (ENQ && ! empty_reg ) || ( ENQ && DEQ && full_reg ) ;
   wire                   d0d1 = DEQ && ! full_reg ;
   wire                   d0h = ((! DEQ) && (! ENQ )) || (!DEQ && empty_reg ) || ( ! ENQ &&full_reg) ;
   wire                   d1di = ENQ & empty_reg ;

`ifdef BSV_NO_INITIAL_BLOCKS
`else // not BSV_NO_INITIAL_BLOCKS
   // synopsys translate_off
   initial
     begin
        data0_reg   = {((width + 1)/2) {2'b10}} ;
        data1_reg  = {((width + 1)/2) {2'b10}} ;
        empty_reg = 1'b0;
        full_reg  = 1'b1;
     end // initial begin
   // synopsys translate_on
`endif // BSV_NO_INITIAL_BLOCKS

   always@(posedge CLK `BSV_ARESET_EDGE_META)
     begin
        if (RST == `BSV_RESET_VALUE)
          begin
             empty_reg <= `BSV_ASSIGNMENT_DELAY 1'b0;
             full_reg  <= `BSV_ASSIGNMENT_DELAY 1'b1;
          end // if (RST == `BSV_RESET_VALUE)
        else
          begin
             if (CLR)
               begin
                  empty_reg <= `BSV_ASSIGNMENT_DELAY 1'b0;
                  full_reg  <= `BSV_ASSIGNMENT_DELAY 1'b1;
               end // if (CLR)
             else if ( ENQ && ! DEQ ) // just enq
               begin
                  empty_reg <= `BSV_ASSIGNMENT_DELAY 1'b1;
                  full_reg <= `BSV_ASSIGNMENT_DELAY ! empty_reg ;
               end
             else if ( DEQ && ! ENQ )
               begin
                  full_reg  <= `BSV_ASSIGNMENT_DELAY 1'b1;
                  empty_reg <= `BSV_ASSIGNMENT_DELAY ! full_reg;
               end // if ( DEQ && ! ENQ )
          end // else: !if(RST == `BSV_RESET_VALUE)

     end // always@ (posedge CLK or `BSV_RESET_EDGE RST)


   always@(posedge CLK `BSV_ARESET_EDGE_HEAD)
     begin
`ifdef BSV_RESET_FIFO_HEAD
        if (RST == `BSV_RESET_VALUE)
          begin
             data0_reg <= `BSV_ASSIGNMENT_DELAY {width {1'b0}} ;
             data1_reg <= `BSV_ASSIGNMENT_DELAY {width {1'b0}} ;
          end
        else
`endif
          begin
             data0_reg  <= `BSV_ASSIGNMENT_DELAY
                           {width{d0di}} & D_IN | {width{d0d1}} & data1_reg | {width{d0h}} & data0_reg ;
             data1_reg <= `BSV_ASSIGNMENT_DELAY
                          d1di ? D_IN : data1_reg ;
          end // else: !if(RST == `BSV_RESET_VALUE)
     end // always@ (posedge CLK or `BSV_RESET_EDGE RST)



   // synopsys translate_off
   always@(posedge CLK)
     begin: error_checks
        reg deqerror, enqerror ;

        deqerror =  0;
        enqerror = 0;
        if (RST == ! `BSV_RESET_VALUE)
          begin
             if ( ! empty_reg && DEQ )
               begin
                  deqerror =  1;
                  $display( "Warning: FIFO2: %m -- Dequeuing from empty fifo" ) ;
               end
             if ( ! full_reg && ENQ && (!DEQ || guarded) )
               begin
                  enqerror = 1;
                  $display( "Warning: FIFO2: %m -- Enqueuing to a full fifo" ) ;
               end
          end
     end // always@ (posedge CLK)
   // synopsys translate_on

endmodule


//
// FIFO2 implementation using LUTRAM for storage.
//
module FIFO2_LUTRAM(CLK,
                    RST,
                    D_IN,
                    ENQ,
                    FULL_N,
                    D_OUT,
                    DEQ,
                    EMPTY_N,
                    CLR);

   parameter width = 1;
   parameter guarded = 1;

   input     CLK ;
   input     RST ;
   input [width - 1 : 0] D_IN;
   input                 ENQ;
   input                 DEQ;
   input                 CLR ;

   output                FULL_N;
   output                EMPTY_N;
   output [width - 1 : 0] D_OUT;
     
   // synthesis attribute ram_style of data is distributed
   reg [width - 1 : 0] data[0 : 1] /* synthesis ramstyle = "MLAB, no_rw_check" */;

   reg wr_idx;
   reg rd_idx;

   reg [1 : 0] valid_cnt;
   reg [1 : 0] valid_cnt_next;

   assign D_OUT = data[rd_idx];

   reg    full_reg;
   reg    empty_reg;
   assign FULL_N = full_reg ;
   assign EMPTY_N = empty_reg ;

   // Write pointer advances on ENQ
   always@(posedge CLK `BSV_ARESET_EDGE_META)
     begin
        if ((RST == `BSV_RESET_VALUE) || CLR)
          begin
             wr_idx <= `BSV_ASSIGNMENT_DELAY 1'b0;
          end
        else if (ENQ)
          begin
             data[wr_idx] <= `BSV_ASSIGNMENT_DELAY D_IN;
             wr_idx <= `BSV_ASSIGNMENT_DELAY ~wr_idx;
          end
     end

   // Read pointer advances on DEQ
   always@(posedge CLK `BSV_ARESET_EDGE_META)
     begin
        if ((RST == `BSV_RESET_VALUE) || CLR)
          begin
             rd_idx <= `BSV_ASSIGNMENT_DELAY 1'b0;
          end
        else if (DEQ)
          begin
             rd_idx <= `BSV_ASSIGNMENT_DELAY ~rd_idx;
          end
     end

   // Update count of live values
   always@(posedge CLK `BSV_ARESET_EDGE_META)
     begin
        if ((RST == `BSV_RESET_VALUE) || CLR)
          begin
             valid_cnt <= `BSV_ASSIGNMENT_DELAY 2'd0;
             full_reg <= `BSV_ASSIGNMENT_DELAY 1'b1;
             empty_reg <= `BSV_ASSIGNMENT_DELAY 1'b0;
          end
        else
          begin
             valid_cnt <= `BSV_ASSIGNMENT_DELAY valid_cnt_next;
             full_reg <= `BSV_ASSIGNMENT_DELAY (valid_cnt_next != 2'd2);
             empty_reg <= `BSV_ASSIGNMENT_DELAY (valid_cnt_next != 2'd0);
          end
     end

   always@(*)
     begin
        valid_cnt_next = valid_cnt;

        if (DEQ && ! ENQ)
          begin
             valid_cnt_next = valid_cnt_next - 2'd1;
          end
        else if (ENQ && ! DEQ)
          begin
             valid_cnt_next = valid_cnt_next + 2'd1;
          end
     end

   // synopsys translate_off
   always@(posedge CLK)
     begin: error_checks
        reg deqerror, enqerror ;

        deqerror =  0;
        enqerror = 0;
        if (RST == ! `BSV_RESET_VALUE)
          begin
             if ( ! empty_reg && DEQ )
               begin
                  deqerror =  1;
                  $display( "Warning: FIFO2: %m -- Dequeuing from empty fifo" ) ;
               end
             // Altera MLAB doesn't guarantee read before write.  This test
             // is more stringent than FIFO2_Reg.
             if ( ! full_reg && ENQ )
               begin
                  enqerror = 1;
                  $display( "Warning: FIFO2: %m -- Enqueuing to a full fifo" ) ;
               end
          end
     end // always@ (posedge CLK)
   // synopsys translate_on

endmodule // qa_drv_prim_fifo_lutram
