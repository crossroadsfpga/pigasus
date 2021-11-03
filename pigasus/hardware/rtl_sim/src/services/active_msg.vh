//
// Interface and struct definitions
//

`ifndef ACT_MSG_VH
`define ACT_MSG_VH

interface server#(SDARG_BITS=32, DATA_BITS=512) ();

    //localparam SDARG_BITS = 32;
    typedef logic [SDARG_BITS-1:0] t_sdarg;

    //localparam DATA_BITS = 512;
    typedef logic [DATA_BITS-1:0] t_data;

    // AM_HEAD
    typedef struct packed
    {
        t_sdarg srcid; // Server ID sending message to server to complete request
        t_sdarg dstid; // Server ID receiving message after request completed
        t_sdarg arg0;  // User defined arguments for server processing
        t_sdarg arg1;  // ie.) Typically I use arg 1 for address on a read/write server
        t_sdarg arg2;  // These need to be returned with a response
        t_sdarg arg3;  //
    }
    t_am_head;

    // AM_DATA
    typedef struct packed
    {
        t_data data;
    }
    t_am_data;

    // AM_FULL
    typedef struct packed
    {
        t_am_data data;
        t_am_head head;
    }
    t_am_full;

    typedef struct packed
    {
        t_am_full tx_msg;
        logic     tx;
    }
    t_tx_msg_channel;

    typedef struct packed
    {
        logic     rxEmpty;
        t_am_full rx_msg;
    }
    t_rx_msg_channel;

    t_tx_msg_channel txP;
    logic            txFull;
    logic            txAlmostFull;

    t_rx_msg_channel rxP;
    logic            rxPop;

    // Server port
    modport svr
       (
        input  txP,
        output txFull,
        output txAlmostFull,
        output rxP,
        input  rxPop
        );

    // Client port
    modport clt
       (
        output txP,
        input  txFull,
        input  txAlmostFull,
        input  rxP,
        output rxPop
        );

endinterface // server

`endif
