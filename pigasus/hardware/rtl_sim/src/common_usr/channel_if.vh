//
// Interface and struct definitions
//

`ifndef MSG_VH
`define MSG_VH

interface channel_if#(WIDTH=512,NUM=2) ();

    typedef logic [WIDTH-1:0]    t_data;
    typedef logic [5:0]          t_empty;
    typedef logic [NUM-1:0]      t_channel;

    t_data      data;
    logic       valid;
    logic       ready;
    logic       sop;
    logic       eop;
    t_empty     empty;
    logic       almost_full;
    t_channel   channel;

    modport tx
       (
        output data,
        output valid,
        input  ready,
        output sop,
        output eop,
        output empty,
        input  almost_full,
        output channel
        );

    modport rx
       (
        input  data,
        input  valid,
        output ready,
        input  sop,
        input  eop,
        input  empty,
        output almost_full,
        input  channel
        );

endinterface

`endif
