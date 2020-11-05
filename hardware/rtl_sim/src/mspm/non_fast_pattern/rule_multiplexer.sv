// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// altera message_level level1
// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.

 
// $Id: //acds/rel/13.1/ip/.../avalon-st_multiplexer.sv.terp#1 $
// $Revision: #1 $
// $Date: 2013/09/09 $
// $Author: dmunday $


// --------------------------------------------------------------------------------
//| Avalon Streaming Multiplexer
// --------------------------------------------------------------------------------


`timescale 1ns / 100ps
// ------------------------------------------
// Generation parameters:
//   output_name:        test_multiplexer_0_multiplexer_181_bd2r6li
//   use_packets:        true
//   use_empty:          1
//   empty_width:        4
//   data_width:         128
//   channel_width:      1
//   error_width:        0
//   num_inputs:         2
//   inChWidth:          0
//   selectWidth:        1
//   selectBits:         1-1:0
//   channelSelectBits:  1-1:0
//   inPayloadMap:       in0_data,in0_startofpacket,in0_endofpacket,in0_empty in1_data,in1_startofpacket,in1_endofpacket,in1_empty
//   outPayloadMap:      out_data,out_startofpacket,out_endofpacket,out_empty
//   inPayloadWidth:     134
//   use_packet_scheduling: true
//   schedulingSize:        2
//   schedulingSizeInBits:     1   
//   
// ------------------------------------------


module rule_multiplexer (     
// Interface: out
 output reg              out_channel,
 output reg              out_valid,
 input                   out_ready,
 output reg    [128-1: 0] out_data,
 output reg              out_startofpacket,
 output reg              out_endofpacket,
 output reg    [4-1 : 0] out_empty,

// Interface: in0
 input           in0_valid,
 output reg      in0_ready,
 input [128-1: 0] in0_data,
           
 input           in0_startofpacket,
 input           in0_endofpacket, 
 input [4-1: 0]  in0_empty,
// Interface: in1
 input           in1_valid,
 output reg      in1_ready,
 input [128-1: 0] in1_data,
           
 input           in1_startofpacket,
 input           in1_endofpacket, 
 input [4-1: 0]  in1_empty,
  // Interface: clk
 input              clk,
 // Interface: reset
 input              reset_n

/*AUTOARG*/);

   // ---------------------------------------------------------------------
   //| Signal Declarations
   // ---------------------------------------------------------------------
   reg [134 -1:0]      in0_payload;
   reg [134 -1:0]      in1_payload;
 
   reg [1-1:0]        decision = 0;
   reg [1-1:0]        select = 0;   
   reg                selected_endofpacket = 0;
   reg                selected_valid;
   wire               out_valid_wire;
   wire               selected_ready;
   reg   [134 -1 :0]   selected_payload;  
   reg                packet_in_progress;
   wire [1-1:0]       out_select;   
   wire [134 - 1:0]    out_payload;

   // ---------------------------------------------------------------------
   //| Input Mapping
   // ---------------------------------------------------------------------
   always @* begin
     in0_payload = {in0_data,in0_startofpacket,in0_endofpacket,in0_empty};
     in1_payload = {in1_data,in1_startofpacket,in1_endofpacket,in1_empty};
   end
   
   // ---------------------------------------------------------------------
   //| Scheduling Algorithm
   // ---------------------------------------------------------------------
   always @* begin
         
      decision = 0;
      case(select) 
         0 : begin
            if (in0_valid) decision = 0;
            if (in1_valid) decision = 1;
         end  
         1 : begin
            if (in1_valid) decision = 1;
            if (in0_valid) decision = 0;
         end  
         default : begin // Same as '0', should never get used.
            if (in0_valid) decision = 0;
            if (in1_valid) decision = 1;
         end  
      endcase   
   end

   // ---------------------------------------------------------------------
   //| Capture Decision
   // ---------------------------------------------------------------------
   always @ (negedge reset_n, posedge clk) begin
      if (!reset_n) begin
         select <= 0;
         packet_in_progress <= 0;
      end else begin
         if (!selected_valid && !packet_in_progress) begin
            select <= decision;
         end else begin
            packet_in_progress <= 1;
         end
         if (selected_endofpacket && selected_valid && selected_ready) begin
            select <= decision;
            packet_in_progress <= 0;
         end
      end
   end



   // ---------------------------------------------------------------------
   //| Mux
   // ---------------------------------------------------------------------
   always @* begin
      case(select) 
         0 : begin
            selected_payload = in0_payload;         
            selected_valid   = in0_valid;
            selected_endofpacket = in0_endofpacket;
         end  
         1 : begin
            selected_payload = in1_payload;         
            selected_valid   = in1_valid;
            selected_endofpacket = in1_endofpacket;
         end  
         default : begin
            selected_payload = in0_payload;         
            selected_valid = in0_valid;
            selected_endofpacket = in0_endofpacket;
         end
      endcase

   end

   // ---------------------------------------------------------------------
   //| Back Pressure
   // ---------------------------------------------------------------------
   always @* begin
      in0_ready <= ~in0_valid;
      in1_ready <= ~in1_valid;
      case(select)
      0 : in0_ready <= selected_ready;
      1 : in1_ready <= selected_ready;
      default : in0_ready <= selected_ready;

endcase // case (select)
end // always @ *

   // ---------------------------------------------------------------------
   //| output Pipeline
   // ---------------------------------------------------------------------
   test_multiplexer_0_multiplexer_181_bd2r6li_1stage_pipeline  #( .PAYLOAD_WIDTH( 134 + 1 ) ) outpipe
              ( .clk      (clk ),
                .reset_n  (reset_n  ),
                .in_ready ( selected_ready ),
                .in_valid ( selected_valid ),
                .in_payload ({select,selected_payload}),
                .out_ready(out_ready ),
                .out_valid(out_valid_wire),
                .out_payload({out_select,out_payload}) );


   // ---------------------------------------------------------------------
   //| Output Mapping
   // ---------------------------------------------------------------------
   always @* begin
      out_valid   = out_valid_wire;
      out_channel = out_select;
      {out_data,out_startofpacket,out_endofpacket,out_empty} = out_payload;
   end
endmodule //

//  --------------------------------------------------------------------------------
// | single buffered pipeline stage
//  --------------------------------------------------------------------------------
module test_multiplexer_0_multiplexer_181_bd2r6li_1stage_pipeline
  #( parameter PAYLOAD_WIDTH = 8 )
    ( input                             clk,
         input                          reset_n,
         output reg                     in_ready,
         input                          in_valid,
         input      [PAYLOAD_WIDTH-1:0] in_payload,
         input                          out_ready,
         output reg                     out_valid,
         output reg [PAYLOAD_WIDTH-1:0] out_payload
      );
   reg                                  in_ready1;


   always @* begin
      in_ready = out_ready || ~out_valid;
      //     in_ready = in_ready1;
      //     if (!out_ready)
      //       in_ready = 0;
   end
   always @ (negedge reset_n, posedge clk) begin
      if (!reset_n) begin
         in_ready1 <= 0;
         out_valid <= 0;
         out_payload <= 0;
      end else begin
         in_ready1 <= out_ready || !out_valid;
         if (in_valid) begin
            out_valid <= 1;
         end else if (out_ready) begin
            out_valid <= 0;
         end
         if(in_valid && in_ready) begin
            out_payload <= in_payload;
         end
      end // else: !if(!reset_n)
   end // always @ (negedge reset_n, posedge clk)

endmodule //

