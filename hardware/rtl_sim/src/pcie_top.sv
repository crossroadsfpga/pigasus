`include "./src/struct_s.sv"
module pcie_top (
        input  wire         refclk_clk,                              //         refclk.clk
        input  wire         pcie_rstn_npor,                          //      pcie_rstn.npor
        input  wire         pcie_rstn_pin_perst,                     //               .pin_perst
        input  wire         xcvr_rx_in0,                             //           xcvr.rx_in0
        input  wire         xcvr_rx_in1,                             //               .rx_in1
        input  wire         xcvr_rx_in2,                             //               .rx_in2
        input  wire         xcvr_rx_in3,                             //               .rx_in3
        input  wire         xcvr_rx_in4,                             //               .rx_in4
        input  wire         xcvr_rx_in5,                             //               .rx_in5
        input  wire         xcvr_rx_in6,                             //               .rx_in6
        input  wire         xcvr_rx_in7,                             //               .rx_in7
        input  wire         xcvr_rx_in8,                             //               .rx_in8
        input  wire         xcvr_rx_in9,                             //               .rx_in9
        input  wire         xcvr_rx_in10,                            //               .rx_in10
        input  wire         xcvr_rx_in11,                            //               .rx_in11
        input  wire         xcvr_rx_in12,                            //               .rx_in12
        input  wire         xcvr_rx_in13,                            //               .rx_in13
        input  wire         xcvr_rx_in14,                            //               .rx_in14
        input  wire         xcvr_rx_in15,                            //               .rx_in15
        output wire         xcvr_tx_out0,                            //               .tx_out0
        output wire         xcvr_tx_out1,                            //               .tx_out1
        output wire         xcvr_tx_out2,                            //               .tx_out2
        output wire         xcvr_tx_out3,                            //               .tx_out3
        output wire         xcvr_tx_out4,                            //               .tx_out4
        output wire         xcvr_tx_out5,                            //               .tx_out5
        output wire         xcvr_tx_out6,                            //               .tx_out6
        output wire         xcvr_tx_out7,                            //               .tx_out7
        output wire         xcvr_tx_out8,                            //               .tx_out8
        output wire         xcvr_tx_out9,                            //               .tx_out9
        output wire         xcvr_tx_out10,                           //               .tx_out10
        output wire         xcvr_tx_out11,                           //               .tx_out11
        output wire         xcvr_tx_out12,                           //               .tx_out12
        output wire         xcvr_tx_out13,                           //               .tx_out13
        output wire         xcvr_tx_out14,                           //               .tx_out14
        output wire         xcvr_tx_out15,                           //               .tx_out15
`ifndef SIM
        output logic        pcie_clk,
        output logic        pcie_reset_n,
`else
        input  logic        pcie_clk,
        input  logic        pcie_reset_n,
`endif
        input  flit_lite_t              pcie_rb_wr_data,
        input  logic [PDU_AWIDTH-1:0]   pcie_rb_wr_addr,
        input  logic                    pcie_rb_wr_en,
        output logic [PDU_AWIDTH-1:0]   pcie_rb_wr_base_addr,
        output logic                    pcie_rb_almost_full,
        input  logic                    pcie_rb_update_valid,
        input  logic [PDU_AWIDTH-1:0]   pcie_rb_update_size,
        output logic                    disable_pcie,

        //pdumeta fifo out signals
        output pdu_metadata_t           pdumeta_cpu_data,
        output logic                    pdumeta_cpu_valid,
        input  logic   [9:0]            pdumeta_cnt,

        // status register bus
        input  logic           clk_status,
        input  logic   [29:0]  status_addr,
        input  logic           status_read,
        input  logic           status_write,
        input  logic   [31:0]  status_writedata,
        output logic   [31:0]  status_readdata,
        output logic           status_readdata_valid
    );
logic         hip_ctrl_simu_mode_pipe;                 //       hip_ctrl.simu_mode_pipe
logic [66:0]  hip_ctrl_test_in;                        //               .test_in
logic         pipe_sim_only_sim_pipe_pclk_in;          //  pipe_sim_only.sim_pipe_pclk_in
logic [1:0]   pipe_sim_only_sim_pipe_rate;             //               .sim_pipe_rate
logic [5:0]   pipe_sim_only_sim_ltssmstate;            //               .sim_ltssmstate
logic [31:0]  pipe_sim_only_txdata0;                   //               .txdata0
logic [31:0]  pipe_sim_only_txdata1;                   //               .txdata1
logic [31:0]  pipe_sim_only_txdata2;                   //               .txdata2
logic [31:0]  pipe_sim_only_txdata3;                   //               .txdata3
logic [31:0]  pipe_sim_only_txdata4;                   //               .txdata4
logic [31:0]  pipe_sim_only_txdata5;                   //               .txdata5
logic [31:0]  pipe_sim_only_txdata6;                   //               .txdata6
logic [31:0]  pipe_sim_only_txdata7;                   //               .txdata7
logic [31:0]  pipe_sim_only_txdata8;                   //               .txdata8
logic [31:0]  pipe_sim_only_txdata9;                   //               .txdata9
logic [31:0]  pipe_sim_only_txdata10;                  //               .txdata10
logic [31:0]  pipe_sim_only_txdata11;                  //               .txdata11
logic [31:0]  pipe_sim_only_txdata12;                  //               .txdata12
logic [31:0]  pipe_sim_only_txdata13;                  //               .txdata13
logic [31:0]  pipe_sim_only_txdata14;                  //               .txdata14
logic [31:0]  pipe_sim_only_txdata15;                  //               .txdata15
logic [3:0]   pipe_sim_only_txdatak0;                  //               .txdatak0
logic [3:0]   pipe_sim_only_txdatak1;                  //               .txdatak1
logic [3:0]   pipe_sim_only_txdatak2;                  //               .txdatak2
logic [3:0]   pipe_sim_only_txdatak3;                  //               .txdatak3
logic [3:0]   pipe_sim_only_txdatak4;                  //               .txdatak4
logic [3:0]   pipe_sim_only_txdatak5;                  //               .txdatak5
logic [3:0]   pipe_sim_only_txdatak6;                  //               .txdatak6
logic [3:0]   pipe_sim_only_txdatak7;                  //               .txdatak7
logic [3:0]   pipe_sim_only_txdatak8;                  //               .txdatak8
logic [3:0]   pipe_sim_only_txdatak9;                  //               .txdatak9
logic [3:0]   pipe_sim_only_txdatak10;                 //               .txdatak10
logic [3:0]   pipe_sim_only_txdatak11;                 //               .txdatak11
logic [3:0]   pipe_sim_only_txdatak12;                 //               .txdatak12
logic [3:0]   pipe_sim_only_txdatak13;                 //               .txdatak13
logic [3:0]   pipe_sim_only_txdatak14;                 //               .txdatak14
logic [3:0]   pipe_sim_only_txdatak15;                 //               .txdatak15
logic         pipe_sim_only_txcompl0;                  //               .txcompl0
logic         pipe_sim_only_txcompl1;                  //               .txcompl1
logic         pipe_sim_only_txcompl2;                  //               .txcompl2
logic         pipe_sim_only_txcompl3;                  //               .txcompl3
logic         pipe_sim_only_txcompl4;                  //               .txcompl4
logic         pipe_sim_only_txcompl5;                  //               .txcompl5
logic         pipe_sim_only_txcompl6;                  //               .txcompl6
logic         pipe_sim_only_txcompl7;                  //               .txcompl7
logic         pipe_sim_only_txcompl8;                  //               .txcompl8
logic         pipe_sim_only_txcompl9;                  //               .txcompl9
logic         pipe_sim_only_txcompl10;                 //               .txcompl10
logic         pipe_sim_only_txcompl11;                 //               .txcompl11
logic         pipe_sim_only_txcompl12;                 //               .txcompl12
logic         pipe_sim_only_txcompl13;                 //               .txcompl13
logic         pipe_sim_only_txcompl14;                 //               .txcompl14
logic         pipe_sim_only_txcompl15;                 //               .txcompl15
logic         pipe_sim_only_txelecidle0;               //               .txelecidle0
logic         pipe_sim_only_txelecidle1;               //               .txelecidle1
logic         pipe_sim_only_txelecidle2;               //               .txelecidle2
logic         pipe_sim_only_txelecidle3;               //               .txelecidle3
logic         pipe_sim_only_txelecidle4;               //               .txelecidle4
logic         pipe_sim_only_txelecidle5;               //               .txelecidle5
logic         pipe_sim_only_txelecidle6;               //               .txelecidle6
logic         pipe_sim_only_txelecidle7;               //               .txelecidle7
logic         pipe_sim_only_txelecidle8;               //               .txelecidle8
logic         pipe_sim_only_txelecidle9;               //               .txelecidle9
logic         pipe_sim_only_txelecidle10;              //               .txelecidle10
logic         pipe_sim_only_txelecidle11;              //               .txelecidle11
logic         pipe_sim_only_txelecidle12;              //               .txelecidle12
logic         pipe_sim_only_txelecidle13;              //               .txelecidle13
logic         pipe_sim_only_txelecidle14;              //               .txelecidle14
logic         pipe_sim_only_txelecidle15;              //               .txelecidle15
logic         pipe_sim_only_txdetectrx0;               //               .txdetectrx0
logic         pipe_sim_only_txdetectrx1;               //               .txdetectrx1
logic         pipe_sim_only_txdetectrx2;               //               .txdetectrx2
logic         pipe_sim_only_txdetectrx3;               //               .txdetectrx3
logic         pipe_sim_only_txdetectrx4;               //               .txdetectrx4
logic         pipe_sim_only_txdetectrx5;               //               .txdetectrx5
logic         pipe_sim_only_txdetectrx6;               //               .txdetectrx6
logic         pipe_sim_only_txdetectrx7;               //               .txdetectrx7
logic         pipe_sim_only_txdetectrx8;               //               .txdetectrx8
logic         pipe_sim_only_txdetectrx9;               //               .txdetectrx9
logic         pipe_sim_only_txdetectrx10;              //               .txdetectrx10
logic         pipe_sim_only_txdetectrx11;              //               .txdetectrx11
logic         pipe_sim_only_txdetectrx12;              //               .txdetectrx12
logic         pipe_sim_only_txdetectrx13;              //               .txdetectrx13
logic         pipe_sim_only_txdetectrx14;              //               .txdetectrx14
logic         pipe_sim_only_txdetectrx15;              //               .txdetectrx15
logic [1:0]   pipe_sim_only_powerdown0;                //               .powerdown0
logic [1:0]   pipe_sim_only_powerdown1;                //               .powerdown1
logic [1:0]   pipe_sim_only_powerdown2;                //               .powerdown2
logic [1:0]   pipe_sim_only_powerdown3;                //               .powerdown3
logic [1:0]   pipe_sim_only_powerdown4;                //               .powerdown4
logic [1:0]   pipe_sim_only_powerdown5;                //               .powerdown5
logic [1:0]   pipe_sim_only_powerdown6;                //               .powerdown6
logic [1:0]   pipe_sim_only_powerdown7;                //               .powerdown7
logic [1:0]   pipe_sim_only_powerdown8;                //               .powerdown8
logic [1:0]   pipe_sim_only_powerdown9;                //               .powerdown9
logic [1:0]   pipe_sim_only_powerdown10;               //               .powerdown10
logic [1:0]   pipe_sim_only_powerdown11;               //               .powerdown11
logic [1:0]   pipe_sim_only_powerdown12;               //               .powerdown12
logic [1:0]   pipe_sim_only_powerdown13;               //               .powerdown13
logic [1:0]   pipe_sim_only_powerdown14;               //               .powerdown14
logic [1:0]   pipe_sim_only_powerdown15;               //               .powerdown15
logic [2:0]   pipe_sim_only_txmargin0;                 //               .txmargin0
logic [2:0]   pipe_sim_only_txmargin1;                 //               .txmargin1
logic [2:0]   pipe_sim_only_txmargin2;                 //               .txmargin2
logic [2:0]   pipe_sim_only_txmargin3;                 //               .txmargin3
logic [2:0]   pipe_sim_only_txmargin4;                 //               .txmargin4
logic [2:0]   pipe_sim_only_txmargin5;                 //               .txmargin5
logic [2:0]   pipe_sim_only_txmargin6;                 //               .txmargin6
logic [2:0]   pipe_sim_only_txmargin7;                 //               .txmargin7
logic [2:0]   pipe_sim_only_txmargin8;                 //               .txmargin8
logic [2:0]   pipe_sim_only_txmargin9;                 //               .txmargin9
logic [2:0]   pipe_sim_only_txmargin10;                //               .txmargin10
logic [2:0]   pipe_sim_only_txmargin11;                //               .txmargin11
logic [2:0]   pipe_sim_only_txmargin12;                //               .txmargin12
logic [2:0]   pipe_sim_only_txmargin13;                //               .txmargin13
logic [2:0]   pipe_sim_only_txmargin14;                //               .txmargin14
logic [2:0]   pipe_sim_only_txmargin15;                //               .txmargin15
logic         pipe_sim_only_txdeemph0;                 //               .txdeemph0
logic         pipe_sim_only_txdeemph1;                 //               .txdeemph1
logic         pipe_sim_only_txdeemph2;                 //               .txdeemph2
logic         pipe_sim_only_txdeemph3;                 //               .txdeemph3
logic         pipe_sim_only_txdeemph4;                 //               .txdeemph4
logic         pipe_sim_only_txdeemph5;                 //               .txdeemph5
logic         pipe_sim_only_txdeemph6;                 //               .txdeemph6
logic         pipe_sim_only_txdeemph7;                 //               .txdeemph7
logic         pipe_sim_only_txdeemph8;                 //               .txdeemph8
logic         pipe_sim_only_txdeemph9;                 //               .txdeemph9
logic         pipe_sim_only_txdeemph10;                //               .txdeemph10
logic         pipe_sim_only_txdeemph11;                //               .txdeemph11
logic         pipe_sim_only_txdeemph12;                //               .txdeemph12
logic         pipe_sim_only_txdeemph13;                //               .txdeemph13
logic         pipe_sim_only_txdeemph14;                //               .txdeemph14
logic         pipe_sim_only_txdeemph15;                //               .txdeemph15
logic         pipe_sim_only_txswing0;                  //               .txswing0
logic         pipe_sim_only_txswing1;                  //               .txswing1
logic         pipe_sim_only_txswing2;                  //               .txswing2
logic         pipe_sim_only_txswing3;                  //               .txswing3
logic         pipe_sim_only_txswing4;                  //               .txswing4
logic         pipe_sim_only_txswing5;                  //               .txswing5
logic         pipe_sim_only_txswing6;                  //               .txswing6
logic         pipe_sim_only_txswing7;                  //               .txswing7
logic         pipe_sim_only_txswing8;                  //               .txswing8
logic         pipe_sim_only_txswing9;                  //               .txswing9
logic         pipe_sim_only_txswing10;                 //               .txswing10
logic         pipe_sim_only_txswing11;                 //               .txswing11
logic         pipe_sim_only_txswing12;                 //               .txswing12
logic         pipe_sim_only_txswing13;                 //               .txswing13
logic         pipe_sim_only_txswing14;                 //               .txswing14
logic         pipe_sim_only_txswing15;                 //               .txswing15
logic [1:0]   pipe_sim_only_txsynchd0;                 //               .txsynchd0
logic [1:0]   pipe_sim_only_txsynchd1;                 //               .txsynchd1
logic [1:0]   pipe_sim_only_txsynchd2;                 //               .txsynchd2
logic [1:0]   pipe_sim_only_txsynchd3;                 //               .txsynchd3
logic [1:0]   pipe_sim_only_txsynchd4;                 //               .txsynchd4
logic [1:0]   pipe_sim_only_txsynchd5;                 //               .txsynchd5
logic [1:0]   pipe_sim_only_txsynchd6;                 //               .txsynchd6
logic [1:0]   pipe_sim_only_txsynchd7;                 //               .txsynchd7
logic [1:0]   pipe_sim_only_txsynchd8;                 //               .txsynchd8
logic [1:0]   pipe_sim_only_txsynchd9;                 //               .txsynchd9
logic [1:0]   pipe_sim_only_txsynchd10;                //               .txsynchd10
logic [1:0]   pipe_sim_only_txsynchd11;                //               .txsynchd11
logic [1:0]   pipe_sim_only_txsynchd12;                //               .txsynchd12
logic [1:0]   pipe_sim_only_txsynchd13;                //               .txsynchd13
logic [1:0]   pipe_sim_only_txsynchd14;                //               .txsynchd14
logic [1:0]   pipe_sim_only_txsynchd15;                //               .txsynchd15
logic         pipe_sim_only_txblkst0;                  //               .txblkst0
logic         pipe_sim_only_txblkst1;                  //               .txblkst1
logic         pipe_sim_only_txblkst2;                  //               .txblkst2
logic         pipe_sim_only_txblkst3;                  //               .txblkst3
logic         pipe_sim_only_txblkst4;                  //               .txblkst4
logic         pipe_sim_only_txblkst5;                  //               .txblkst5
logic         pipe_sim_only_txblkst6;                  //               .txblkst6
logic         pipe_sim_only_txblkst7;                  //               .txblkst7
logic         pipe_sim_only_txblkst8;                  //               .txblkst8
logic         pipe_sim_only_txblkst9;                  //               .txblkst9
logic         pipe_sim_only_txblkst10;                 //               .txblkst10
logic         pipe_sim_only_txblkst11;                 //               .txblkst11
logic         pipe_sim_only_txblkst12;                 //               .txblkst12
logic         pipe_sim_only_txblkst13;                 //               .txblkst13
logic         pipe_sim_only_txblkst14;                 //               .txblkst14
logic         pipe_sim_only_txblkst15;                 //               .txblkst15
logic         pipe_sim_only_txdataskip0;               //               .txdataskip0
logic         pipe_sim_only_txdataskip1;               //               .txdataskip1
logic         pipe_sim_only_txdataskip2;               //               .txdataskip2
logic         pipe_sim_only_txdataskip3;               //               .txdataskip3
logic         pipe_sim_only_txdataskip4;               //               .txdataskip4
logic         pipe_sim_only_txdataskip5;               //               .txdataskip5
logic         pipe_sim_only_txdataskip6;               //               .txdataskip6
logic         pipe_sim_only_txdataskip7;               //               .txdataskip7
logic         pipe_sim_only_txdataskip8;               //               .txdataskip8
logic         pipe_sim_only_txdataskip9;               //               .txdataskip9
logic         pipe_sim_only_txdataskip10;              //               .txdataskip10
logic         pipe_sim_only_txdataskip11;              //               .txdataskip11
logic         pipe_sim_only_txdataskip12;              //               .txdataskip12
logic         pipe_sim_only_txdataskip13;              //               .txdataskip13
logic         pipe_sim_only_txdataskip14;              //               .txdataskip14
logic         pipe_sim_only_txdataskip15;              //               .txdataskip15
logic [1:0]   pipe_sim_only_rate0;                     //               .rate0
logic [1:0]   pipe_sim_only_rate1;                     //               .rate1
logic [1:0]   pipe_sim_only_rate2;                     //               .rate2
logic [1:0]   pipe_sim_only_rate3;                     //               .rate3
logic [1:0]   pipe_sim_only_rate4;                     //               .rate4
logic [1:0]   pipe_sim_only_rate5;                     //               .rate5
logic [1:0]   pipe_sim_only_rate6;                     //               .rate6
logic [1:0]   pipe_sim_only_rate7;                     //               .rate7
logic [1:0]   pipe_sim_only_rate8;                     //               .rate8
logic [1:0]   pipe_sim_only_rate9;                     //               .rate9
logic [1:0]   pipe_sim_only_rate10;                    //               .rate10
logic [1:0]   pipe_sim_only_rate11;                    //               .rate11
logic [1:0]   pipe_sim_only_rate12;                    //               .rate12
logic [1:0]   pipe_sim_only_rate13;                    //               .rate13
logic [1:0]   pipe_sim_only_rate14;                    //               .rate14
logic [1:0]   pipe_sim_only_rate15;                    //               .rate15
logic         pipe_sim_only_rxpolarity0;               //               .rxpolarity0
logic         pipe_sim_only_rxpolarity1;               //               .rxpolarity1
logic         pipe_sim_only_rxpolarity2;               //               .rxpolarity2
logic         pipe_sim_only_rxpolarity3;               //               .rxpolarity3
logic         pipe_sim_only_rxpolarity4;               //               .rxpolarity4
logic         pipe_sim_only_rxpolarity5;               //               .rxpolarity5
logic         pipe_sim_only_rxpolarity6;               //               .rxpolarity6
logic         pipe_sim_only_rxpolarity7;               //               .rxpolarity7
logic         pipe_sim_only_rxpolarity8;               //               .rxpolarity8
logic         pipe_sim_only_rxpolarity9;               //               .rxpolarity9
logic         pipe_sim_only_rxpolarity10;              //               .rxpolarity10
logic         pipe_sim_only_rxpolarity11;              //               .rxpolarity11
logic         pipe_sim_only_rxpolarity12;              //               .rxpolarity12
logic         pipe_sim_only_rxpolarity13;              //               .rxpolarity13
logic         pipe_sim_only_rxpolarity14;              //               .rxpolarity14
logic         pipe_sim_only_rxpolarity15;              //               .rxpolarity15
logic [2:0]   pipe_sim_only_currentrxpreset0;          //               .currentrxpreset0
logic [2:0]   pipe_sim_only_currentrxpreset1;          //               .currentrxpreset1
logic [2:0]   pipe_sim_only_currentrxpreset2;          //               .currentrxpreset2
logic [2:0]   pipe_sim_only_currentrxpreset3;          //               .currentrxpreset3
logic [2:0]   pipe_sim_only_currentrxpreset4;          //               .currentrxpreset4
logic [2:0]   pipe_sim_only_currentrxpreset5;          //               .currentrxpreset5
logic [2:0]   pipe_sim_only_currentrxpreset6;          //               .currentrxpreset6
logic [2:0]   pipe_sim_only_currentrxpreset7;          //               .currentrxpreset7
logic [2:0]   pipe_sim_only_currentrxpreset8;          //               .currentrxpreset8
logic [2:0]   pipe_sim_only_currentrxpreset9;          //               .currentrxpreset9
logic [2:0]   pipe_sim_only_currentrxpreset10;         //               .currentrxpreset10
logic [2:0]   pipe_sim_only_currentrxpreset11;         //               .currentrxpreset11
logic [2:0]   pipe_sim_only_currentrxpreset12;         //               .currentrxpreset12
logic [2:0]   pipe_sim_only_currentrxpreset13;         //               .currentrxpreset13
logic [2:0]   pipe_sim_only_currentrxpreset14;         //               .currentrxpreset14
logic [2:0]   pipe_sim_only_currentrxpreset15;         //               .currentrxpreset15
logic [17:0]  pipe_sim_only_currentcoeff0;             //               .currentcoeff0
logic [17:0]  pipe_sim_only_currentcoeff1;             //               .currentcoeff1
logic [17:0]  pipe_sim_only_currentcoeff2;             //               .currentcoeff2
logic [17:0]  pipe_sim_only_currentcoeff3;             //               .currentcoeff3
logic [17:0]  pipe_sim_only_currentcoeff4;             //               .currentcoeff4
logic [17:0]  pipe_sim_only_currentcoeff5;             //               .currentcoeff5
logic [17:0]  pipe_sim_only_currentcoeff6;             //               .currentcoeff6
logic [17:0]  pipe_sim_only_currentcoeff7;             //               .currentcoeff7
logic [17:0]  pipe_sim_only_currentcoeff8;             //               .currentcoeff8
logic [17:0]  pipe_sim_only_currentcoeff9;             //               .currentcoeff9
logic [17:0]  pipe_sim_only_currentcoeff10;            //               .currentcoeff10
logic [17:0]  pipe_sim_only_currentcoeff11;            //               .currentcoeff11
logic [17:0]  pipe_sim_only_currentcoeff12;            //               .currentcoeff12
logic [17:0]  pipe_sim_only_currentcoeff13;            //               .currentcoeff13
logic [17:0]  pipe_sim_only_currentcoeff14;            //               .currentcoeff14
logic [17:0]  pipe_sim_only_currentcoeff15;            //               .currentcoeff15
logic         pipe_sim_only_rxeqeval0;                 //               .rxeqeval0
logic         pipe_sim_only_rxeqeval1;                 //               .rxeqeval1
logic         pipe_sim_only_rxeqeval2;                 //               .rxeqeval2
logic         pipe_sim_only_rxeqeval3;                 //               .rxeqeval3
logic         pipe_sim_only_rxeqeval4;                 //               .rxeqeval4
logic         pipe_sim_only_rxeqeval5;                 //               .rxeqeval5
logic         pipe_sim_only_rxeqeval6;                 //               .rxeqeval6
logic         pipe_sim_only_rxeqeval7;                 //               .rxeqeval7
logic         pipe_sim_only_rxeqeval8;                 //               .rxeqeval8
logic         pipe_sim_only_rxeqeval9;                 //               .rxeqeval9
logic         pipe_sim_only_rxeqeval10;                //               .rxeqeval10
logic         pipe_sim_only_rxeqeval11;                //               .rxeqeval11
logic         pipe_sim_only_rxeqeval12;                //               .rxeqeval12
logic         pipe_sim_only_rxeqeval13;                //               .rxeqeval13
logic         pipe_sim_only_rxeqeval14;                //               .rxeqeval14
logic         pipe_sim_only_rxeqeval15;                //               .rxeqeval15
logic         pipe_sim_only_rxeqinprogress0;           //               .rxeqinprogress0
logic         pipe_sim_only_rxeqinprogress1;           //               .rxeqinprogress1
logic         pipe_sim_only_rxeqinprogress2;           //               .rxeqinprogress2
logic         pipe_sim_only_rxeqinprogress3;           //               .rxeqinprogress3
logic         pipe_sim_only_rxeqinprogress4;           //               .rxeqinprogress4
logic         pipe_sim_only_rxeqinprogress5;           //               .rxeqinprogress5
logic         pipe_sim_only_rxeqinprogress6;           //               .rxeqinprogress6
logic         pipe_sim_only_rxeqinprogress7;           //               .rxeqinprogress7
logic         pipe_sim_only_rxeqinprogress8;           //               .rxeqinprogress8
logic         pipe_sim_only_rxeqinprogress9;           //               .rxeqinprogress9
logic         pipe_sim_only_rxeqinprogress10;          //               .rxeqinprogress10
logic         pipe_sim_only_rxeqinprogress11;          //               .rxeqinprogress11
logic         pipe_sim_only_rxeqinprogress12;          //               .rxeqinprogress12
logic         pipe_sim_only_rxeqinprogress13;          //               .rxeqinprogress13
logic         pipe_sim_only_rxeqinprogress14;          //               .rxeqinprogress14
logic         pipe_sim_only_rxeqinprogress15;          //               .rxeqinprogress15
logic         pipe_sim_only_invalidreq0;               //               .invalidreq0
logic         pipe_sim_only_invalidreq1;               //               .invalidreq1
logic         pipe_sim_only_invalidreq2;               //               .invalidreq2
logic         pipe_sim_only_invalidreq3;               //               .invalidreq3
logic         pipe_sim_only_invalidreq4;               //               .invalidreq4
logic         pipe_sim_only_invalidreq5;               //               .invalidreq5
logic         pipe_sim_only_invalidreq6;               //               .invalidreq6
logic         pipe_sim_only_invalidreq7;               //               .invalidreq7
logic         pipe_sim_only_invalidreq8;               //               .invalidreq8
logic         pipe_sim_only_invalidreq9;               //               .invalidreq9
logic         pipe_sim_only_invalidreq10;              //               .invalidreq10
logic         pipe_sim_only_invalidreq11;              //               .invalidreq11
logic         pipe_sim_only_invalidreq12;              //               .invalidreq12
logic         pipe_sim_only_invalidreq13;              //               .invalidreq13
logic         pipe_sim_only_invalidreq14;              //               .invalidreq14
logic         pipe_sim_only_invalidreq15;              //               .invalidreq15
logic [31:0]  pipe_sim_only_rxdata0;                   //               .rxdata0
logic [31:0]  pipe_sim_only_rxdata1;                   //               .rxdata1
logic [31:0]  pipe_sim_only_rxdata2;                   //               .rxdata2
logic [31:0]  pipe_sim_only_rxdata3;                   //               .rxdata3
logic [31:0]  pipe_sim_only_rxdata4;                   //               .rxdata4
logic [31:0]  pipe_sim_only_rxdata5;                   //               .rxdata5
logic [31:0]  pipe_sim_only_rxdata6;                   //               .rxdata6
logic [31:0]  pipe_sim_only_rxdata7;                   //               .rxdata7
logic [31:0]  pipe_sim_only_rxdata8;                   //               .rxdata8
logic [31:0]  pipe_sim_only_rxdata9;                   //               .rxdata9
logic [31:0]  pipe_sim_only_rxdata10;                  //               .rxdata10
logic [31:0]  pipe_sim_only_rxdata11;                  //               .rxdata11
logic [31:0]  pipe_sim_only_rxdata12;                  //               .rxdata12
logic [31:0]  pipe_sim_only_rxdata13;                  //               .rxdata13
logic [31:0]  pipe_sim_only_rxdata14;                  //               .rxdata14
logic [31:0]  pipe_sim_only_rxdata15;                  //               .rxdata15
logic [3:0]   pipe_sim_only_rxdatak0;                  //               .rxdatak0
logic [3:0]   pipe_sim_only_rxdatak1;                  //               .rxdatak1
logic [3:0]   pipe_sim_only_rxdatak2;                  //               .rxdatak2
logic [3:0]   pipe_sim_only_rxdatak3;                  //               .rxdatak3
logic [3:0]   pipe_sim_only_rxdatak4;                  //               .rxdatak4
logic [3:0]   pipe_sim_only_rxdatak5;                  //               .rxdatak5
logic [3:0]   pipe_sim_only_rxdatak6;                  //               .rxdatak6
logic [3:0]   pipe_sim_only_rxdatak7;                  //               .rxdatak7
logic [3:0]   pipe_sim_only_rxdatak8;                  //               .rxdatak8
logic [3:0]   pipe_sim_only_rxdatak9;                  //               .rxdatak9
logic [3:0]   pipe_sim_only_rxdatak10;                 //               .rxdatak10
logic [3:0]   pipe_sim_only_rxdatak11;                 //               .rxdatak11
logic [3:0]   pipe_sim_only_rxdatak12;                 //               .rxdatak12
logic [3:0]   pipe_sim_only_rxdatak13;                 //               .rxdatak13
logic [3:0]   pipe_sim_only_rxdatak14;                 //               .rxdatak14
logic [3:0]   pipe_sim_only_rxdatak15;                 //               .rxdatak15
logic         pipe_sim_only_phystatus0;                //               .phystatus0
logic         pipe_sim_only_phystatus1;                //               .phystatus1
logic         pipe_sim_only_phystatus2;                //               .phystatus2
logic         pipe_sim_only_phystatus3;                //               .phystatus3
logic         pipe_sim_only_phystatus4;                //               .phystatus4
logic         pipe_sim_only_phystatus5;                //               .phystatus5
logic         pipe_sim_only_phystatus6;                //               .phystatus6
logic         pipe_sim_only_phystatus7;                //               .phystatus7
logic         pipe_sim_only_phystatus8;                //               .phystatus8
logic         pipe_sim_only_phystatus9;                //               .phystatus9
logic         pipe_sim_only_phystatus10;               //               .phystatus10
logic         pipe_sim_only_phystatus11;               //               .phystatus11
logic         pipe_sim_only_phystatus12;               //               .phystatus12
logic         pipe_sim_only_phystatus13;               //               .phystatus13
logic         pipe_sim_only_phystatus14;               //               .phystatus14
logic         pipe_sim_only_phystatus15;               //               .phystatus15
logic         pipe_sim_only_rxvalid0;                  //               .rxvalid0
logic         pipe_sim_only_rxvalid1;                  //               .rxvalid1
logic         pipe_sim_only_rxvalid2;                  //               .rxvalid2
logic         pipe_sim_only_rxvalid3;                  //               .rxvalid3
logic         pipe_sim_only_rxvalid4;                  //               .rxvalid4
logic         pipe_sim_only_rxvalid5;                  //               .rxvalid5
logic         pipe_sim_only_rxvalid6;                  //               .rxvalid6
logic         pipe_sim_only_rxvalid7;                  //               .rxvalid7
logic         pipe_sim_only_rxvalid8;                  //               .rxvalid8
logic         pipe_sim_only_rxvalid9;                  //               .rxvalid9
logic         pipe_sim_only_rxvalid10;                 //               .rxvalid10
logic         pipe_sim_only_rxvalid11;                 //               .rxvalid11
logic         pipe_sim_only_rxvalid12;                 //               .rxvalid12
logic         pipe_sim_only_rxvalid13;                 //               .rxvalid13
logic         pipe_sim_only_rxvalid14;                 //               .rxvalid14
logic         pipe_sim_only_rxvalid15;                 //               .rxvalid15
logic [2:0]   pipe_sim_only_rxstatus0;                 //               .rxstatus0
logic [2:0]   pipe_sim_only_rxstatus1;                 //               .rxstatus1
logic [2:0]   pipe_sim_only_rxstatus2;                 //               .rxstatus2
logic [2:0]   pipe_sim_only_rxstatus3;                 //               .rxstatus3
logic [2:0]   pipe_sim_only_rxstatus4;                 //               .rxstatus4
logic [2:0]   pipe_sim_only_rxstatus5;                 //               .rxstatus5
logic [2:0]   pipe_sim_only_rxstatus6;                 //               .rxstatus6
logic [2:0]   pipe_sim_only_rxstatus7;                 //               .rxstatus7
logic [2:0]   pipe_sim_only_rxstatus8;                 //               .rxstatus8
logic [2:0]   pipe_sim_only_rxstatus9;                 //               .rxstatus9
logic [2:0]   pipe_sim_only_rxstatus10;                //               .rxstatus10
logic [2:0]   pipe_sim_only_rxstatus11;                //               .rxstatus11
logic [2:0]   pipe_sim_only_rxstatus12;                //               .rxstatus12
logic [2:0]   pipe_sim_only_rxstatus13;                //               .rxstatus13
logic [2:0]   pipe_sim_only_rxstatus14;                //               .rxstatus14
logic [2:0]   pipe_sim_only_rxstatus15;                //               .rxstatus15
logic         pipe_sim_only_rxelecidle0;               //               .rxelecidle0
logic         pipe_sim_only_rxelecidle1;               //               .rxelecidle1
logic         pipe_sim_only_rxelecidle2;               //               .rxelecidle2
logic         pipe_sim_only_rxelecidle3;               //               .rxelecidle3
logic         pipe_sim_only_rxelecidle4;               //               .rxelecidle4
logic         pipe_sim_only_rxelecidle5;               //               .rxelecidle5
logic         pipe_sim_only_rxelecidle6;               //               .rxelecidle6
logic         pipe_sim_only_rxelecidle7;               //               .rxelecidle7
logic         pipe_sim_only_rxelecidle8;               //               .rxelecidle8
logic         pipe_sim_only_rxelecidle9;               //               .rxelecidle9
logic         pipe_sim_only_rxelecidle10;              //               .rxelecidle10
logic         pipe_sim_only_rxelecidle11;              //               .rxelecidle11
logic         pipe_sim_only_rxelecidle12;              //               .rxelecidle12
logic         pipe_sim_only_rxelecidle13;              //               .rxelecidle13
logic         pipe_sim_only_rxelecidle14;              //               .rxelecidle14
logic         pipe_sim_only_rxelecidle15;              //               .rxelecidle15
logic [1:0]   pipe_sim_only_rxsynchd0;                 //               .rxsynchd0
logic [1:0]   pipe_sim_only_rxsynchd1;                 //               .rxsynchd1
logic [1:0]   pipe_sim_only_rxsynchd2;                 //               .rxsynchd2
logic [1:0]   pipe_sim_only_rxsynchd3;                 //               .rxsynchd3
logic [1:0]   pipe_sim_only_rxsynchd4;                 //               .rxsynchd4
logic [1:0]   pipe_sim_only_rxsynchd5;                 //               .rxsynchd5
logic [1:0]   pipe_sim_only_rxsynchd6;                 //               .rxsynchd6
logic [1:0]   pipe_sim_only_rxsynchd7;                 //               .rxsynchd7
logic [1:0]   pipe_sim_only_rxsynchd8;                 //               .rxsynchd8
logic [1:0]   pipe_sim_only_rxsynchd9;                 //               .rxsynchd9
logic [1:0]   pipe_sim_only_rxsynchd10;                //               .rxsynchd10
logic [1:0]   pipe_sim_only_rxsynchd11;                //               .rxsynchd11
logic [1:0]   pipe_sim_only_rxsynchd12;                //               .rxsynchd12
logic [1:0]   pipe_sim_only_rxsynchd13;                //               .rxsynchd13
logic [1:0]   pipe_sim_only_rxsynchd14;                //               .rxsynchd14
logic [1:0]   pipe_sim_only_rxsynchd15;                //               .rxsynchd15
logic         pipe_sim_only_rxblkst0;                  //               .rxblkst0
logic         pipe_sim_only_rxblkst1;                  //               .rxblkst1
logic         pipe_sim_only_rxblkst2;                  //               .rxblkst2
logic         pipe_sim_only_rxblkst3;                  //               .rxblkst3
logic         pipe_sim_only_rxblkst4;                  //               .rxblkst4
logic         pipe_sim_only_rxblkst5;                  //               .rxblkst5
logic         pipe_sim_only_rxblkst6;                  //               .rxblkst6
logic         pipe_sim_only_rxblkst7;                  //               .rxblkst7
logic         pipe_sim_only_rxblkst8;                  //               .rxblkst8
logic         pipe_sim_only_rxblkst9;                  //               .rxblkst9
logic         pipe_sim_only_rxblkst10;                 //               .rxblkst10
logic         pipe_sim_only_rxblkst11;                 //               .rxblkst11
logic         pipe_sim_only_rxblkst12;                 //               .rxblkst12
logic         pipe_sim_only_rxblkst13;                 //               .rxblkst13
logic         pipe_sim_only_rxblkst14;                 //               .rxblkst14
logic         pipe_sim_only_rxblkst15;                 //               .rxblkst15
logic         pipe_sim_only_rxdataskip0;               //               .rxdataskip0
logic         pipe_sim_only_rxdataskip1;               //               .rxdataskip1
logic         pipe_sim_only_rxdataskip2;               //               .rxdataskip2
logic         pipe_sim_only_rxdataskip3;               //               .rxdataskip3
logic         pipe_sim_only_rxdataskip4;               //               .rxdataskip4
logic         pipe_sim_only_rxdataskip5;               //               .rxdataskip5
logic         pipe_sim_only_rxdataskip6;               //               .rxdataskip6
logic         pipe_sim_only_rxdataskip7;               //               .rxdataskip7
logic         pipe_sim_only_rxdataskip8;               //               .rxdataskip8
logic         pipe_sim_only_rxdataskip9;               //               .rxdataskip9
logic         pipe_sim_only_rxdataskip10;              //               .rxdataskip10
logic         pipe_sim_only_rxdataskip11;              //               .rxdataskip11
logic         pipe_sim_only_rxdataskip12;              //               .rxdataskip12
logic         pipe_sim_only_rxdataskip13;              //               .rxdataskip13
logic         pipe_sim_only_rxdataskip14;              //               .rxdataskip14
logic         pipe_sim_only_rxdataskip15;              //               .rxdataskip15
logic [5:0]   pipe_sim_only_dirfeedback0;              //               .dirfeedback0
logic [5:0]   pipe_sim_only_dirfeedback1;              //               .dirfeedback1
logic [5:0]   pipe_sim_only_dirfeedback2;              //               .dirfeedback2
logic [5:0]   pipe_sim_only_dirfeedback3;              //               .dirfeedback3
logic [5:0]   pipe_sim_only_dirfeedback4;              //               .dirfeedback4
logic [5:0]   pipe_sim_only_dirfeedback5;              //               .dirfeedback5
logic [5:0]   pipe_sim_only_dirfeedback6;              //               .dirfeedback6
logic [5:0]   pipe_sim_only_dirfeedback7;              //               .dirfeedback7
logic [5:0]   pipe_sim_only_dirfeedback8;              //               .dirfeedback8
logic [5:0]   pipe_sim_only_dirfeedback9;              //               .dirfeedback9
logic [5:0]   pipe_sim_only_dirfeedback10;             //               .dirfeedback10
logic [5:0]   pipe_sim_only_dirfeedback11;             //               .dirfeedback11
logic [5:0]   pipe_sim_only_dirfeedback12;             //               .dirfeedback12
logic [5:0]   pipe_sim_only_dirfeedback13;             //               .dirfeedback13
logic [5:0]   pipe_sim_only_dirfeedback14;             //               .dirfeedback14
logic [5:0]   pipe_sim_only_dirfeedback15;             //               .dirfeedback15
logic         pipe_sim_only_sim_pipe_mask_tx_pll_lock; //               .sim_pipe_mask_tx_pll_lock


localparam JTAG_REG_SIZE = 20;
localparam C2F_HEAD_OFFSET = (5*4); //5th dwords
//PCIe signals
logic         rddm_desc_ready;
logic         rddm_desc_valid;
logic [173:0] rddm_desc_data;

logic         wrdm_desc_ready;
logic         wrdm_desc_valid;
logic [173:0] wrdm_desc_data;

logic         wrdm_prio_ready;
logic         wrdm_prio_valid;
logic [173:0] wrdm_prio_data;

logic [17:0] address_0;     //   input,    width = 9,     s1.address
logic write_0;       //   input,    width = 1,       .write
logic read_0;       //   input,    width = 1,       .write
logic readdatavalid_0;       //   input,    width = 1,       .write
logic [511:0] readdata_0;    //  output,  width = 512,       .readdata
logic [511:0] writedata_0;   //   input,  width = 512,       .writedata
logic [63:0] byteenable_0;  //   input,   width = 64,       .byteenable
logic [17:0] address_1;    //   input,    width = 9,     s2.address
logic write_1;      //   input,    width = 1,       .write
logic read_1;      //   input,    width = 1,       .write
logic readdatavalid_1;      //   input,    width = 1,       .write
logic [511:0] readdata_1;   //  output,  width = 512,       .readdata
logic [511:0] writedata_1;  //   input,  width = 512,       .writedata
logic [63:0] byteenable_1; //   input,   width = 64,       .byteenable

//JTAG signals
logic [29:0]  status_addr_r;
logic         status_read_r;
logic         status_write_r;
logic [31:0]  status_writedata_r;
logic [STAT_AWIDTH-1:0] status_addr_sel_r;

logic [31:0] pcie_reg0_status;
logic [31:0] pcie_reg1_status;
logic [31:0] pcie_reg2_status;
logic [31:0] pcie_reg3_status;
logic [31:0] pcie_reg4_status;
logic [31:0] pcie_reg5_status;
logic [31:0] pcie_reg6_status;
logic [31:0] pcie_reg7_status;
logic [31:0] pcie_reg8_status;
logic [31:0] pcie_reg9_status;
logic [31:0] pcie_reg10_status;
logic [31:0] pcie_reg11_status;
logic [31:0] pcie_reg12_status;
logic [31:0] pcie_reg13_status;
logic [31:0] pcie_reg14_status;
logic [31:0] pcie_reg15_status;
logic [31:0] pcie_reg16_status;
logic [31:0] pcie_reg17_status;
logic [31:0] pcie_reg18_status;
logic [31:0] pcie_reg19_status;
logic [31:0] pcie_reg20_status;
logic [31:0] pcie_reg21_status;
logic [31:0] pcie_reg22_status;
logic [31:0] pcie_reg23_status;
logic [31:0] pcie_reg24_status;
logic [31:0] pcie_reg25_status;
logic [31:0] pcie_reg26_status;
logic [31:0] pcie_reg27_status;
logic [31:0] pcie_reg28_status;
logic [31:0] pcie_reg29_status;
logic [31:0] pcie_reg30_status;
logic [31:0] pcie_reg31_status;
logic [31:0] pcie_reg32_status;
logic [31:0] pcie_reg33_status;
logic [31:0] pcie_reg34_status;
logic [31:0] pcie_reg35_status;
logic [31:0] pcie_reg36_status;
logic [31:0] pcie_reg37_status;
logic [31:0] pcie_reg38_status;
logic [31:0] pcie_reg39_status;
logic [31:0] pcie_reg40_status;
logic [31:0] pcie_reg41_status;
logic [31:0] pcie_reg42_status;
logic [31:0] pcie_reg43_status;
logic [31:0] pcie_reg44_status;
logic [31:0] pcie_reg45_status;
logic [31:0] pcie_reg46_status;
logic [31:0] pcie_reg47_status;
logic [31:0] pcie_reg48_status;
logic [31:0] pcie_reg49_status;
logic [31:0] pcie_reg50_status;
logic [31:0] pcie_reg51_status;
logic [31:0] pcie_reg52_status;
logic [31:0] pcie_reg53_status;
logic [31:0] pcie_reg54_status;
logic [31:0] pcie_reg55_status;
logic [31:0] pcie_reg56_status;
logic [31:0] pcie_reg57_status;
logic [31:0] pcie_reg58_status;
logic [31:0] pcie_reg59_status;
logic [31:0] pcie_reg60_status;
logic [31:0] pcie_reg61_status;
logic [31:0] pcie_reg62_status;
logic [31:0] pcie_reg63_status;
logic [31:0] pcie_reg64_status;

logic [31:0] pcie_reg0_r1;
logic [31:0] pcie_reg1_r1;
logic [31:0] pcie_reg2_r1;
logic [31:0] pcie_reg3_r1;
logic [31:0] pcie_reg4_r1;
logic [31:0] pcie_reg5_r1;
logic [31:0] pcie_reg6_r1;
logic [31:0] pcie_reg7_r1;
logic [31:0] pcie_reg8_r1;
logic [31:0] pcie_reg9_r1;
logic [31:0] pcie_reg10_r1;
logic [31:0] pcie_reg11_r1;
logic [31:0] pcie_reg12_r1;
logic [31:0] pcie_reg13_r1;
logic [31:0] pcie_reg14_r1;
logic [31:0] pcie_reg15_r1;
logic [31:0] pcie_reg16_r1;
logic [31:0] pcie_reg17_r1;
logic [31:0] pcie_reg18_r1;
logic [31:0] pcie_reg19_r1;
logic [31:0] pcie_reg20_r1;
logic [31:0] pcie_reg21_r1;
logic [31:0] pcie_reg22_r1;
logic [31:0] pcie_reg23_r1;
logic [31:0] pcie_reg24_r1;
logic [31:0] pcie_reg25_r1;
logic [31:0] pcie_reg26_r1;
logic [31:0] pcie_reg27_r1;
logic [31:0] pcie_reg28_r1;
logic [31:0] pcie_reg29_r1;
logic [31:0] pcie_reg30_r1;
logic [31:0] pcie_reg31_r1;
logic [31:0] pcie_reg32_r1;
logic [31:0] pcie_reg33_r1;
logic [31:0] pcie_reg34_r1;
logic [31:0] pcie_reg35_r1;
logic [31:0] pcie_reg36_r1;
logic [31:0] pcie_reg37_r1;
logic [31:0] pcie_reg38_r1;
logic [31:0] pcie_reg39_r1;
logic [31:0] pcie_reg40_r1;
logic [31:0] pcie_reg41_r1;
logic [31:0] pcie_reg42_r1;
logic [31:0] pcie_reg43_r1;
logic [31:0] pcie_reg44_r1;
logic [31:0] pcie_reg45_r1;
logic [31:0] pcie_reg46_r1;
logic [31:0] pcie_reg47_r1;
logic [31:0] pcie_reg48_r1;
logic [31:0] pcie_reg49_r1;
logic [31:0] pcie_reg50_r1;
logic [31:0] pcie_reg51_r1;
logic [31:0] pcie_reg52_r1;
logic [31:0] pcie_reg53_r1;
logic [31:0] pcie_reg54_r1;
logic [31:0] pcie_reg55_r1;
logic [31:0] pcie_reg56_r1;
logic [31:0] pcie_reg57_r1;
logic [31:0] pcie_reg58_r1;
logic [31:0] pcie_reg59_r1;
logic [31:0] pcie_reg60_r1;
logic [31:0] pcie_reg61_r1;
logic [31:0] pcie_reg62_r1;
logic [31:0] pcie_reg63_r1;
logic [31:0] pcie_reg64_r1;

logic [31:0] pcie_reg0_pcie;
logic [31:0] pcie_reg1_pcie;
logic [31:0] pcie_reg2_pcie;
logic [31:0] pcie_reg3_pcie;
logic [31:0] pcie_reg4_pcie;
logic [31:0] pcie_reg5_pcie;
logic [31:0] pcie_reg6_pcie;
logic [31:0] pcie_reg7_pcie;
logic [31:0] pcie_reg8_pcie;
logic [31:0] pcie_reg9_pcie;
logic [31:0] pcie_reg10_pcie;
logic [31:0] pcie_reg11_pcie;
logic [31:0] pcie_reg12_pcie;
logic [31:0] pcie_reg13_pcie;
logic [31:0] pcie_reg14_pcie;
logic [31:0] pcie_reg15_pcie;
logic [31:0] pcie_reg16_pcie;
logic [31:0] pcie_reg17_pcie;
logic [31:0] pcie_reg18_pcie;
logic [31:0] pcie_reg19_pcie;
logic [31:0] pcie_reg20_pcie;
logic [31:0] pcie_reg21_pcie;
logic [31:0] pcie_reg22_pcie;
logic [31:0] pcie_reg23_pcie;
logic [31:0] pcie_reg24_pcie;
logic [31:0] pcie_reg25_pcie;
logic [31:0] pcie_reg26_pcie;
logic [31:0] pcie_reg27_pcie;
logic [31:0] pcie_reg28_pcie;
logic [31:0] pcie_reg29_pcie;
logic [31:0] pcie_reg30_pcie;
logic [31:0] pcie_reg31_pcie;
logic [31:0] pcie_reg32_pcie;
logic [31:0] pcie_reg33_pcie;
logic [31:0] pcie_reg34_pcie;
logic [31:0] pcie_reg35_pcie;
logic [31:0] pcie_reg36_pcie;
logic [31:0] pcie_reg37_pcie;
logic [31:0] pcie_reg38_pcie;
logic [31:0] pcie_reg39_pcie;
logic [31:0] pcie_reg40_pcie;
logic [31:0] pcie_reg41_pcie;
logic [31:0] pcie_reg42_pcie;
logic [31:0] pcie_reg43_pcie;
logic [31:0] pcie_reg44_pcie;
logic [31:0] pcie_reg45_pcie;
logic [31:0] pcie_reg46_pcie;
logic [31:0] pcie_reg47_pcie;
logic [31:0] pcie_reg48_pcie;
logic [31:0] pcie_reg49_pcie;
logic [31:0] pcie_reg50_pcie;
logic [31:0] pcie_reg51_pcie;
logic [31:0] pcie_reg52_pcie;
logic [31:0] pcie_reg53_pcie;
logic [31:0] pcie_reg54_pcie;
logic [31:0] pcie_reg55_pcie;
logic [31:0] pcie_reg56_pcie;
logic [31:0] pcie_reg57_pcie;
logic [31:0] pcie_reg58_pcie;
logic [31:0] pcie_reg59_pcie;
logic [31:0] pcie_reg60_pcie;
logic [31:0] pcie_reg61_pcie;
logic [31:0] pcie_reg62_pcie;
logic [31:0] pcie_reg63_pcie;
logic [31:0] pcie_reg64_pcie;

//internal signals
pcie_block_t pcie_block;
logic cpu_reg_region;
logic cpu_reg_region_r1;
logic cpu_reg_region_r2;
logic read_0_r1;
logic read_0_r2;
logic [25:0] rb_size;
logic [4:0]  total_core;
logic [3:0]  core_id;
logic internal_update_valid;

logic [RB_AWIDTH-1:0]    f2c_head;
logic [RB_AWIDTH-1:0]    f2c_tail;
logic [63:0]             f2c_kmem_addr;
logic [511:0]            frb_readdata;
logic                    frb_readvalid;
logic [PDU_AWIDTH-1:0]   frb_address;
logic                    frb_read;

logic [C2F_RB_AWIDTH-1:0]   c2f_head;
logic [C2F_RB_AWIDTH-1:0]   c2f_tail;
logic [63:0]                c2f_kmem_addr;
logic [63:0]                c2f_head_addr;

logic                    dma_done;
logic [RB_AWIDTH-1:0]    new_tail;
logic [RB_AWIDTH-1:0]    tail_0;
logic [RB_AWIDTH-1:0]    tail_1;
logic [RB_AWIDTH-1:0]    tail_2;
logic [RB_AWIDTH-1:0]    tail_3;
logic [RB_AWIDTH-1:0]    tail_4;
logic [RB_AWIDTH-1:0]    tail_5;
logic [RB_AWIDTH-1:0]    tail_6;
logic [RB_AWIDTH-1:0]    tail_7;
logic [RB_AWIDTH-1:0]    tail_8;
logic [RB_AWIDTH-1:0]    tail_9;
logic [RB_AWIDTH-1:0]    tail_10;
logic [RB_AWIDTH-1:0]    tail_11;
logic [RB_AWIDTH-1:0]    tail_12;
logic [RB_AWIDTH-1:0]    tail_13;
logic [RB_AWIDTH-1:0]    tail_14;
logic [RB_AWIDTH-1:0]    tail_15;
logic [RB_AWIDTH-1:0]    head_0;
logic [RB_AWIDTH-1:0]    head_1;
logic [RB_AWIDTH-1:0]    head_2;
logic [RB_AWIDTH-1:0]    head_3;
logic [RB_AWIDTH-1:0]    head_4;
logic [RB_AWIDTH-1:0]    head_5;
logic [RB_AWIDTH-1:0]    head_6;
logic [RB_AWIDTH-1:0]    head_7;
logic [RB_AWIDTH-1:0]    head_8;
logic [RB_AWIDTH-1:0]    head_9;
logic [RB_AWIDTH-1:0]    head_10;
logic [RB_AWIDTH-1:0]    head_11;
logic [RB_AWIDTH-1:0]    head_12;
logic [RB_AWIDTH-1:0]    head_13;
logic [RB_AWIDTH-1:0]    head_14;
logic [RB_AWIDTH-1:0]    head_15;
logic [31:0]             kmem_low_0;
logic [31:0]             kmem_low_1;
logic [31:0]             kmem_low_2;
logic [31:0]             kmem_low_3;
logic [31:0]             kmem_low_4;
logic [31:0]             kmem_low_5;
logic [31:0]             kmem_low_6;
logic [31:0]             kmem_low_7;
logic [31:0]             kmem_low_8;
logic [31:0]             kmem_low_9;
logic [31:0]             kmem_low_10;
logic [31:0]             kmem_low_11;
logic [31:0]             kmem_low_12;
logic [31:0]             kmem_low_13;
logic [31:0]             kmem_low_14;
logic [31:0]             kmem_low_15;
logic [31:0]             kmem_high_0;
logic [31:0]             kmem_high_1;
logic [31:0]             kmem_high_2;
logic [31:0]             kmem_high_3;
logic [31:0]             kmem_high_4;
logic [31:0]             kmem_high_5;
logic [31:0]             kmem_high_6;
logic [31:0]             kmem_high_7;
logic [31:0]             kmem_high_8;
logic [31:0]             kmem_high_9;
logic [31:0]             kmem_high_10;
logic [31:0]             kmem_high_11;
logic [31:0]             kmem_high_12;
logic [31:0]             kmem_high_13;
logic [31:0]             kmem_high_14;
logic [31:0]             kmem_high_15;
logic [C2F_RB_AWIDTH-1:0]   c2f_head_1;

// JTAG
always @(posedge clk_status) begin
    status_addr_r       <= status_addr;
    status_addr_sel_r   <= status_addr[29:30-STAT_AWIDTH];

    status_read_r       <= status_read;
    status_write_r      <= status_write;
    status_writedata_r  <= status_writedata;

    status_readdata_valid <= 0;

    if (status_addr_sel_r == PCIE & status_read_r) begin
        case (status_addr_r[6:0])
            7'd0:  status_readdata <= pcie_reg0_status;
            7'd1:  status_readdata <= pcie_reg1_status;
            7'd2:  status_readdata <= pcie_reg2_status;
            7'd3:  status_readdata <= pcie_reg3_status;
            7'd4:  status_readdata <= pcie_reg4_status;
            7'd5:  status_readdata <= pcie_reg5_status;
            7'd6:  status_readdata <= pcie_reg6_status;
            7'd7:  status_readdata <= pcie_reg7_status;
            7'd8:  status_readdata <= pcie_reg8_status;
            7'd9:  status_readdata <= pcie_reg9_status;
            7'd10: status_readdata <= pcie_reg10_status;
            7'd11: status_readdata <= pcie_reg11_status;
            7'd12: status_readdata <= pcie_reg12_status;
            7'd13: status_readdata <= pcie_reg13_status;
            7'd14: status_readdata <= pcie_reg14_status;
            7'd15: status_readdata <= pcie_reg15_status;
            7'd16: status_readdata <= pcie_reg16_status;
            7'd17: status_readdata <= pcie_reg17_status;
            7'd18: status_readdata <= pcie_reg18_status;
            7'd19: status_readdata <= pcie_reg19_status;
            7'd20: status_readdata <= pcie_reg20_status;
            7'd21: status_readdata <= pcie_reg21_status;
            7'd22: status_readdata <= pcie_reg22_status;
            7'd23: status_readdata <= pcie_reg23_status;
            7'd24: status_readdata <= pcie_reg24_status;
            7'd25: status_readdata <= pcie_reg25_status;
            7'd26: status_readdata <= pcie_reg26_status;
            7'd27: status_readdata <= pcie_reg27_status;
            7'd28: status_readdata <= pcie_reg28_status;
            7'd29: status_readdata <= pcie_reg29_status;
            7'd30: status_readdata <= pcie_reg30_status;
            7'd31: status_readdata <= pcie_reg31_status;
            7'd32: status_readdata <= pcie_reg32_status;
            7'd33: status_readdata <= pcie_reg33_status;
            7'd34: status_readdata <= pcie_reg34_status;
            7'd35: status_readdata <= pcie_reg35_status;
            7'd36: status_readdata <= pcie_reg36_status;
            7'd37: status_readdata <= pcie_reg37_status;
            7'd38: status_readdata <= pcie_reg38_status;
            7'd39: status_readdata <= pcie_reg39_status;
            7'd40: status_readdata <= pcie_reg40_status;
            7'd41: status_readdata <= pcie_reg41_status;
            7'd42: status_readdata <= pcie_reg42_status;
            7'd43: status_readdata <= pcie_reg43_status;
            7'd44: status_readdata <= pcie_reg44_status;
            7'd45: status_readdata <= pcie_reg45_status;
            7'd46: status_readdata <= pcie_reg46_status;
            7'd47: status_readdata <= pcie_reg47_status;
            7'd48: status_readdata <= pcie_reg48_status;
            7'd49: status_readdata <= pcie_reg49_status;
            7'd50: status_readdata <= pcie_reg50_status;
            7'd51: status_readdata <= pcie_reg51_status;
            7'd52: status_readdata <= pcie_reg52_status;
            7'd53: status_readdata <= pcie_reg53_status;
            7'd54: status_readdata <= pcie_reg54_status;
            7'd55: status_readdata <= pcie_reg55_status;
            7'd56: status_readdata <= pcie_reg56_status;
            7'd57: status_readdata <= pcie_reg57_status;
            7'd58: status_readdata <= pcie_reg58_status;
            7'd59: status_readdata <= pcie_reg59_status;
            7'd60: status_readdata <= pcie_reg60_status;
            7'd61: status_readdata <= pcie_reg61_status;
            7'd62: status_readdata <= pcie_reg62_status;
            7'd63: status_readdata <= pcie_reg63_status;
            7'd64: status_readdata <= pcie_reg64_status;
        endcase

        status_readdata_valid <= 1;
    end

    if (status_addr_sel_r == PCIE & status_write_r) begin
        case (status_addr_r[6:0])
            7'd64: begin
                pcie_reg64_status   <= status_writedata_r;
            end
        endcase
    end
end

// Clock Crossing jtag -> pcie
always @(posedge pcie_clk) begin
    pcie_reg64_r1   <= pcie_reg64_status;
    pcie_reg64_pcie <= pcie_reg64_r1;
end

assign disable_pcie = pcie_reg64_pcie[0];
assign rb_size      = pcie_reg64_pcie[26:1];
assign total_core   = pcie_reg64_pcie[31:27];

// Clock Crossing pcie -> jtag
always @ (posedge clk_status) begin
    pcie_reg0_r1        <= pcie_reg0_pcie;
    pcie_reg0_status    <= pcie_reg0_r1;
    pcie_reg1_r1        <= pcie_reg1_pcie;
    pcie_reg1_status    <= pcie_reg1_r1;
    pcie_reg2_r1        <= pcie_reg2_pcie;
    pcie_reg2_status    <= pcie_reg2_r1;
    pcie_reg3_r1        <= pcie_reg3_pcie;
    pcie_reg3_status    <= pcie_reg3_r1;
    pcie_reg4_r1        <= pcie_reg4_pcie;
    pcie_reg4_status    <= pcie_reg4_r1;
    pcie_reg5_r1        <= pcie_reg5_pcie;
    pcie_reg5_status    <= pcie_reg5_r1;
    pcie_reg6_r1        <= pcie_reg6_pcie;
    pcie_reg6_status    <= pcie_reg6_r1;
    pcie_reg7_r1        <= pcie_reg7_pcie;
    pcie_reg7_status    <= pcie_reg7_r1;
    pcie_reg8_r1        <= pcie_reg8_pcie;
    pcie_reg8_status    <= pcie_reg8_r1;
    pcie_reg9_r1        <= pcie_reg9_pcie;
    pcie_reg9_status    <= pcie_reg9_r1;
    pcie_reg10_r1       <= pcie_reg10_pcie;
    pcie_reg10_status   <= pcie_reg10_r1;
    pcie_reg11_r1       <= pcie_reg11_pcie;
    pcie_reg11_status   <= pcie_reg11_r1;
    pcie_reg12_r1       <= pcie_reg12_pcie;
    pcie_reg12_status   <= pcie_reg12_r1;
    pcie_reg13_r1       <= pcie_reg13_pcie;
    pcie_reg13_status   <= pcie_reg13_r1;
    pcie_reg14_r1       <= pcie_reg14_pcie;
    pcie_reg14_status   <= pcie_reg14_r1;
    pcie_reg15_r1       <= pcie_reg15_pcie;
    pcie_reg15_status   <= pcie_reg15_r1;
    pcie_reg16_r1       <= pcie_reg16_pcie;
    pcie_reg16_status   <= pcie_reg16_r1;
    pcie_reg17_r1       <= pcie_reg17_pcie;
    pcie_reg17_status   <= pcie_reg17_r1;
    pcie_reg18_r1       <= pcie_reg18_pcie;
    pcie_reg18_status   <= pcie_reg18_r1;
    pcie_reg19_r1       <= pcie_reg19_pcie;
    pcie_reg19_status   <= pcie_reg19_r1;
    pcie_reg20_r1       <= pcie_reg20_pcie;
    pcie_reg20_status   <= pcie_reg20_r1;
    pcie_reg21_r1       <= pcie_reg21_pcie;
    pcie_reg21_status   <= pcie_reg21_r1;
    pcie_reg22_r1       <= pcie_reg22_pcie;
    pcie_reg22_status   <= pcie_reg22_r1;
    pcie_reg23_r1       <= pcie_reg23_pcie;
    pcie_reg23_status   <= pcie_reg23_r1;
    pcie_reg24_r1       <= pcie_reg24_pcie;
    pcie_reg24_status   <= pcie_reg24_r1;
    pcie_reg25_r1       <= pcie_reg25_pcie;
    pcie_reg25_status   <= pcie_reg25_r1;
    pcie_reg26_r1       <= pcie_reg26_pcie;
    pcie_reg26_status   <= pcie_reg26_r1;
    pcie_reg27_r1       <= pcie_reg27_pcie;
    pcie_reg27_status   <= pcie_reg27_r1;
    pcie_reg28_r1       <= pcie_reg28_pcie;
    pcie_reg28_status   <= pcie_reg28_r1;
    pcie_reg29_r1       <= pcie_reg29_pcie;
    pcie_reg29_status   <= pcie_reg29_r1;
    pcie_reg30_r1       <= pcie_reg30_pcie;
    pcie_reg30_status   <= pcie_reg30_r1;
    pcie_reg31_r1       <= pcie_reg31_pcie;
    pcie_reg31_status   <= pcie_reg31_r1;
    pcie_reg32_r1       <= pcie_reg32_pcie;
    pcie_reg32_status   <= pcie_reg32_r1;
    pcie_reg33_r1       <= pcie_reg33_pcie;
    pcie_reg33_status   <= pcie_reg33_r1;
    pcie_reg34_r1       <= pcie_reg34_pcie;
    pcie_reg34_status   <= pcie_reg34_r1;
    pcie_reg35_r1       <= pcie_reg35_pcie;
    pcie_reg35_status   <= pcie_reg35_r1;
    pcie_reg36_r1       <= pcie_reg36_pcie;
    pcie_reg36_status   <= pcie_reg36_r1;
    pcie_reg37_r1       <= pcie_reg37_pcie;
    pcie_reg37_status   <= pcie_reg37_r1;
    pcie_reg38_r1       <= pcie_reg38_pcie;
    pcie_reg38_status   <= pcie_reg38_r1;
    pcie_reg39_r1       <= pcie_reg39_pcie;
    pcie_reg39_status   <= pcie_reg39_r1;
    pcie_reg40_r1       <= pcie_reg40_pcie;
    pcie_reg40_status   <= pcie_reg40_r1;
    pcie_reg41_r1       <= pcie_reg41_pcie;
    pcie_reg41_status   <= pcie_reg41_r1;
    pcie_reg42_r1       <= pcie_reg42_pcie;
    pcie_reg42_status   <= pcie_reg42_r1;
    pcie_reg43_r1       <= pcie_reg43_pcie;
    pcie_reg43_status   <= pcie_reg43_r1;
    pcie_reg44_r1       <= pcie_reg44_pcie;
    pcie_reg44_status   <= pcie_reg44_r1;
    pcie_reg45_r1       <= pcie_reg45_pcie;
    pcie_reg45_status   <= pcie_reg45_r1;
    pcie_reg46_r1       <= pcie_reg46_pcie;
    pcie_reg46_status   <= pcie_reg46_r1;
    pcie_reg47_r1       <= pcie_reg47_pcie;
    pcie_reg47_status   <= pcie_reg47_r1;
    pcie_reg48_r1       <= pcie_reg48_pcie;
    pcie_reg48_status   <= pcie_reg48_r1;
    pcie_reg49_r1       <= pcie_reg49_pcie;
    pcie_reg49_status   <= pcie_reg49_r1;
    pcie_reg50_r1       <= pcie_reg50_pcie;
    pcie_reg50_status   <= pcie_reg50_r1;
    pcie_reg51_r1       <= pcie_reg51_pcie;
    pcie_reg51_status   <= pcie_reg51_r1;
    pcie_reg52_r1       <= pcie_reg52_pcie;
    pcie_reg52_status   <= pcie_reg52_r1;
    pcie_reg53_r1       <= pcie_reg53_pcie;
    pcie_reg53_status   <= pcie_reg53_r1;
    pcie_reg54_r1       <= pcie_reg54_pcie;
    pcie_reg54_status   <= pcie_reg54_r1;
    pcie_reg55_r1       <= pcie_reg55_pcie;
    pcie_reg55_status   <= pcie_reg55_r1;
    pcie_reg56_r1       <= pcie_reg56_pcie;
    pcie_reg56_status   <= pcie_reg56_r1;
    pcie_reg57_r1       <= pcie_reg57_pcie;
    pcie_reg57_status   <= pcie_reg57_r1;
    pcie_reg58_r1       <= pcie_reg58_pcie;
    pcie_reg58_status   <= pcie_reg58_r1;
    pcie_reg59_r1       <= pcie_reg59_pcie;
    pcie_reg59_status   <= pcie_reg59_r1;
    pcie_reg60_r1       <= pcie_reg60_pcie;
    pcie_reg60_status   <= pcie_reg60_r1;
    pcie_reg61_r1       <= pcie_reg61_pcie;
    pcie_reg61_status   <= pcie_reg61_r1;
    pcie_reg62_r1       <= pcie_reg62_pcie;
    pcie_reg62_status   <= pcie_reg62_r1;
    pcie_reg63_r1       <= pcie_reg63_pcie;
    pcie_reg63_status   <= pcie_reg63_r1;
end

// Update PIO register
always @(posedge pcie_clk) begin
    if (!pcie_reset_n) begin
        pcie_reg1_pcie <= 0;
        pcie_reg2_pcie <= 0;
        pcie_reg3_pcie <= 0;
        pcie_reg5_pcie <= 0;
        pcie_reg6_pcie <= 0;
        pcie_reg7_pcie <= 0;
        pcie_reg9_pcie <= 0;
        pcie_reg10_pcie <= 0;
        pcie_reg11_pcie <= 0;
        pcie_reg13_pcie <= 0;
        pcie_reg14_pcie <= 0;
        pcie_reg15_pcie <= 0;
        pcie_reg17_pcie <= 0;
        pcie_reg18_pcie <= 0;
        pcie_reg19_pcie <= 0;
        pcie_reg21_pcie <= 0;
        pcie_reg22_pcie <= 0;
        pcie_reg23_pcie <= 0;
        pcie_reg25_pcie <= 0;
        pcie_reg26_pcie <= 0;
        pcie_reg27_pcie <= 0;
        pcie_reg29_pcie <= 0;
        pcie_reg30_pcie <= 0;
        pcie_reg31_pcie <= 0;
        pcie_reg33_pcie <= 0;
        pcie_reg34_pcie <= 0;
        pcie_reg35_pcie <= 0;
        pcie_reg37_pcie <= 0;
        pcie_reg38_pcie <= 0;
        pcie_reg39_pcie <= 0;
        pcie_reg41_pcie <= 0;
        pcie_reg42_pcie <= 0;
        pcie_reg43_pcie <= 0;
        pcie_reg45_pcie <= 0;
        pcie_reg46_pcie <= 0;
        pcie_reg47_pcie <= 0;
        pcie_reg49_pcie <= 0;
        pcie_reg50_pcie <= 0;
        pcie_reg51_pcie <= 0;
        pcie_reg53_pcie <= 0;
        pcie_reg54_pcie <= 0;
        pcie_reg55_pcie <= 0;
        pcie_reg57_pcie <= 0;
        pcie_reg58_pcie <= 0;
        pcie_reg59_pcie <= 0;
        pcie_reg61_pcie <= 0;
        pcie_reg62_pcie <= 0;
        pcie_reg63_pcie <= 0;
    end
    else begin
        if (write_0) begin
            case(address_0[7:6])
                2'd0: begin
                    // pcie_reg0_pcie  <=  (byteenable_0[3:0]   == 4'b1111) ? writedata_0[31:0]    : pcie_reg0_pcie;
                    pcie_reg1_pcie  <=  (byteenable_0[7:4]   == 4'b1111) ? writedata_0[63:32]   : pcie_reg1_pcie;
                    pcie_reg2_pcie  <=  (byteenable_0[11:8]  == 4'b1111) ? writedata_0[95:64]   : pcie_reg2_pcie;
                    pcie_reg3_pcie  <=  (byteenable_0[16:12] == 4'b1111) ? writedata_0[127:96]  : pcie_reg3_pcie;
                    // pcie_reg4_pcie  <=  (byteenable_0[19:16] == 4'b1111) ? writedata_0[159:128] : pcie_reg4_pcie;
                    pcie_reg5_pcie  <=  (byteenable_0[23:20] == 4'b1111) ? writedata_0[191:160] : pcie_reg5_pcie;
                    pcie_reg6_pcie  <=  (byteenable_0[27:24] == 4'b1111) ? writedata_0[223:192] : pcie_reg6_pcie;
                    pcie_reg7_pcie  <=  (byteenable_0[31:28] == 4'b1111) ? writedata_0[255:224] : pcie_reg7_pcie;
                    // pcie_reg8_pcie  <=  (byteenable_0[35:32] == 4'b1111) ? writedata_0[287:256] : pcie_reg8_pcie;
                    pcie_reg9_pcie  <=  (byteenable_0[39:36] == 4'b1111) ? writedata_0[319:288] : pcie_reg9_pcie;
                    pcie_reg10_pcie <=  (byteenable_0[43:40] == 4'b1111) ? writedata_0[351:320] : pcie_reg10_pcie;
                    pcie_reg11_pcie <=  (byteenable_0[47:44] == 4'b1111) ? writedata_0[383:352] : pcie_reg11_pcie;
                    // pcie_reg12_pcie <=  (byteenable_0[51:48] == 4'b1111) ? writedata_0[415:384] : pcie_reg12_pcie;
                    pcie_reg13_pcie <=  (byteenable_0[55:52] == 4'b1111) ? writedata_0[447:416] : pcie_reg13_pcie;
                    pcie_reg14_pcie <=  (byteenable_0[59:56] == 4'b1111) ? writedata_0[479:448] : pcie_reg14_pcie;
                    pcie_reg15_pcie <=  (byteenable_0[63:60] == 4'b1111) ? writedata_0[511:480] : pcie_reg15_pcie;
                end
                2'd1: begin
                    // pcie_reg16_pcie <=  (byteenable_0[3:0]   == 4'b1111) ? writedata_0[31:0]    : pcie_reg16_pcie;
                    pcie_reg17_pcie <=  (byteenable_0[7:4]   == 4'b1111) ? writedata_0[63:32]   : pcie_reg17_pcie;
                    pcie_reg18_pcie <=  (byteenable_0[11:8]  == 4'b1111) ? writedata_0[95:64]   : pcie_reg18_pcie;
                    pcie_reg19_pcie <=  (byteenable_0[16:12] == 4'b1111) ? writedata_0[127:96]  : pcie_reg19_pcie;
                    // pcie_reg20_pcie <=  (byteenable_0[19:16] == 4'b1111) ? writedata_0[159:128] : pcie_reg20_pcie;
                    pcie_reg21_pcie <=  (byteenable_0[23:20] == 4'b1111) ? writedata_0[191:160] : pcie_reg21_pcie;
                    pcie_reg22_pcie <=  (byteenable_0[27:24] == 4'b1111) ? writedata_0[223:192] : pcie_reg22_pcie;
                    pcie_reg23_pcie <=  (byteenable_0[31:28] == 4'b1111) ? writedata_0[255:224] : pcie_reg23_pcie;
                    // pcie_reg24_pcie <=  (byteenable_0[35:32] == 4'b1111) ? writedata_0[287:256] : pcie_reg24_pcie;
                    pcie_reg25_pcie <=  (byteenable_0[39:36] == 4'b1111) ? writedata_0[319:288] : pcie_reg25_pcie;
                    pcie_reg26_pcie <=  (byteenable_0[43:40] == 4'b1111) ? writedata_0[351:320] : pcie_reg26_pcie;
                    pcie_reg27_pcie <=  (byteenable_0[47:44] == 4'b1111) ? writedata_0[383:352] : pcie_reg27_pcie;
                    // pcie_reg28_pcie <=  (byteenable_0[51:48] == 4'b1111) ? writedata_0[415:384] : pcie_reg28_pcie;
                    pcie_reg29_pcie <=  (byteenable_0[55:52] == 4'b1111) ? writedata_0[447:416] : pcie_reg29_pcie;
                    pcie_reg30_pcie <=  (byteenable_0[59:56] == 4'b1111) ? writedata_0[479:448] : pcie_reg30_pcie;
                    pcie_reg31_pcie <=  (byteenable_0[63:60] == 4'b1111) ? writedata_0[511:480] : pcie_reg31_pcie;
                end
                2'd2: begin
                    // pcie_reg0_pcie  <=  (byteenable_0[3:0]   == 4'b1111) ? writedata_0[31:0]    : pcie_reg0_pcie;
                    pcie_reg33_pcie  <=  (byteenable_0[7:4]   == 4'b1111) ? writedata_0[63:32]   : pcie_reg33_pcie;
                    pcie_reg34_pcie  <=  (byteenable_0[11:8]  == 4'b1111) ? writedata_0[95:64]   : pcie_reg34_pcie;
                    pcie_reg35_pcie  <=  (byteenable_0[16:12] == 4'b1111) ? writedata_0[127:96]  : pcie_reg35_pcie;
                    // pcie_reg4_pcie  <=  (byteenable_0[19:16] == 4'b1111) ? writedata_0[159:128] : pcie_reg4_pcie;
                    pcie_reg37_pcie  <=  (byteenable_0[23:20] == 4'b1111) ? writedata_0[191:160] : pcie_reg37_pcie;
                    pcie_reg38_pcie  <=  (byteenable_0[27:24] == 4'b1111) ? writedata_0[223:192] : pcie_reg38_pcie;
                    pcie_reg39_pcie  <=  (byteenable_0[31:28] == 4'b1111) ? writedata_0[255:224] : pcie_reg39_pcie;
                    // pcie_reg8_pcie  <=  (byteenable_0[35:32] == 4'b1111) ? writedata_0[287:256] : pcie_reg8_pcie;
                    pcie_reg41_pcie  <=  (byteenable_0[39:36] == 4'b1111) ? writedata_0[319:288] : pcie_reg41_pcie;
                    pcie_reg42_pcie <=  (byteenable_0[43:40] == 4'b1111) ? writedata_0[351:320] : pcie_reg42_pcie;
                    pcie_reg43_pcie <=  (byteenable_0[47:44] == 4'b1111) ? writedata_0[383:352] : pcie_reg43_pcie;
                    // pcie_reg12_pcie <=  (byteenable_0[51:48] == 4'b1111) ? writedata_0[415:384] : pcie_reg12_pcie;
                    pcie_reg45_pcie <=  (byteenable_0[55:52] == 4'b1111) ? writedata_0[447:416] : pcie_reg45_pcie;
                    pcie_reg46_pcie <=  (byteenable_0[59:56] == 4'b1111) ? writedata_0[479:448] : pcie_reg46_pcie;
                    pcie_reg47_pcie <=  (byteenable_0[63:60] == 4'b1111) ? writedata_0[511:480] : pcie_reg47_pcie;
                end
                2'd3: begin
                    // pcie_reg16_pcie <=  (byteenable_0[3:0]   == 4'b1111) ? writedata_0[31:0]    : pcie_reg16_pcie;
                    pcie_reg49_pcie <=  (byteenable_0[7:4]   == 4'b1111) ? writedata_0[63:32]   : pcie_reg49_pcie;
                    pcie_reg50_pcie <=  (byteenable_0[11:8]  == 4'b1111) ? writedata_0[95:64]   : pcie_reg50_pcie;
                    pcie_reg51_pcie <=  (byteenable_0[16:12] == 4'b1111) ? writedata_0[127:96]  : pcie_reg51_pcie;
                    // pcie_reg20_pcie <=  (byteenable_0[19:16] == 4'b1111) ? writedata_0[159:128] : pcie_reg20_pcie;
                    pcie_reg53_pcie <=  (byteenable_0[23:20] == 4'b1111) ? writedata_0[191:160] : pcie_reg53_pcie;
                    pcie_reg54_pcie <=  (byteenable_0[27:24] == 4'b1111) ? writedata_0[223:192] : pcie_reg54_pcie;
                    pcie_reg55_pcie <=  (byteenable_0[31:28] == 4'b1111) ? writedata_0[255:224] : pcie_reg55_pcie;
                    // pcie_reg24_pcie <=  (byteenable_0[35:32] == 4'b1111) ? writedata_0[287:256] : pcie_reg24_pcie;
                    pcie_reg57_pcie <=  (byteenable_0[39:36] == 4'b1111) ? writedata_0[319:288] : pcie_reg57_pcie;
                    pcie_reg58_pcie <=  (byteenable_0[43:40] == 4'b1111) ? writedata_0[351:320] : pcie_reg58_pcie;
                    pcie_reg59_pcie <=  (byteenable_0[47:44] == 4'b1111) ? writedata_0[383:352] : pcie_reg59_pcie;
                    // pcie_reg28_pcie <=  (byteenable_0[51:48] == 4'b1111) ? writedata_0[415:384] : pcie_reg28_pcie;
                    pcie_reg61_pcie <=  (byteenable_0[55:52] == 4'b1111) ? writedata_0[447:416] : pcie_reg61_pcie;
                    pcie_reg62_pcie <=  (byteenable_0[59:56] == 4'b1111) ? writedata_0[479:448] : pcie_reg62_pcie;
                    pcie_reg63_pcie <=  (byteenable_0[63:60] == 4'b1111) ? writedata_0[511:480] : pcie_reg63_pcie;
                end
            endcase
        end
    end
end

// PIO_write to JTAG reg
// Below are FPGA write registers. FPGA -> CPU.
assign pcie_reg0_pcie   = tail_0;
assign pcie_reg4_pcie   = tail_1;
assign pcie_reg8_pcie   = tail_2;
assign pcie_reg12_pcie  = tail_3;
assign pcie_reg16_pcie  = tail_4;
assign pcie_reg20_pcie  = tail_5;
assign pcie_reg24_pcie  = tail_6;
assign pcie_reg28_pcie  = tail_7;
assign pcie_reg32_pcie  = tail_8;
assign pcie_reg36_pcie  = tail_9;
assign pcie_reg40_pcie  = tail_10;
assign pcie_reg44_pcie  = tail_11;
assign pcie_reg48_pcie  = tail_12;
assign pcie_reg52_pcie  = tail_13;
assign pcie_reg56_pcie  = tail_14;
assign pcie_reg60_pcie  = tail_15;

assign head_0 = pcie_reg1_pcie;
assign head_1 = pcie_reg5_pcie;
assign head_2 = pcie_reg9_pcie;
assign head_3 = pcie_reg13_pcie;
assign head_4 = pcie_reg17_pcie;
assign head_5 = pcie_reg21_pcie;
assign head_6 = pcie_reg25_pcie;
assign head_7 = pcie_reg29_pcie;
assign head_8 = pcie_reg33_pcie;
assign head_9 = pcie_reg37_pcie;
assign head_10 = pcie_reg41_pcie;
assign head_11 = pcie_reg45_pcie;
assign head_12 = pcie_reg49_pcie;
assign head_13 = pcie_reg53_pcie;
assign head_14 = pcie_reg57_pcie;
assign head_15 = pcie_reg61_pcie;

assign kmem_low_0 = pcie_reg2_pcie;
assign kmem_low_1 = pcie_reg6_pcie;
assign kmem_low_2 = pcie_reg10_pcie;
assign kmem_low_3 = pcie_reg14_pcie;
assign kmem_low_4 = pcie_reg18_pcie;
assign kmem_low_5 = pcie_reg22_pcie;
assign kmem_low_6 = pcie_reg26_pcie;
assign kmem_low_7 = pcie_reg30_pcie;
assign kmem_low_8 = pcie_reg34_pcie;
assign kmem_low_9 = pcie_reg38_pcie;
assign kmem_low_10 = pcie_reg42_pcie;
assign kmem_low_11 = pcie_reg46_pcie;
assign kmem_low_12 = pcie_reg50_pcie;
assign kmem_low_13 = pcie_reg54_pcie;
assign kmem_low_14 = pcie_reg58_pcie;
assign kmem_low_15 = pcie_reg62_pcie;

assign kmem_high_0 = pcie_reg3_pcie;
assign kmem_high_1 = pcie_reg7_pcie;
assign kmem_high_2 = pcie_reg11_pcie;
assign kmem_high_3 = pcie_reg15_pcie;
assign kmem_high_4 = pcie_reg19_pcie;
assign kmem_high_5 = pcie_reg23_pcie;
assign kmem_high_6 = pcie_reg27_pcie;
assign kmem_high_7 = pcie_reg31_pcie;
assign kmem_high_8 = pcie_reg35_pcie;
assign kmem_high_9 = pcie_reg39_pcie;
assign kmem_high_10 = pcie_reg43_pcie;
assign kmem_high_11 = pcie_reg47_pcie;
assign kmem_high_12 = pcie_reg51_pcie;
assign kmem_high_13 = pcie_reg55_pcie;
assign kmem_high_14 = pcie_reg59_pcie;
assign kmem_high_15 = pcie_reg63_pcie;

assign c2f_tail = 0;
assign c2f_kmem_addr = 0;
assign c2f_head_addr = 0;

// Update tail pointer.
// CPU side read MUX, first 512 bit are registers, the rest is BRAM.
always @(posedge pcie_clk) begin
    if (!pcie_reset_n) begin
        tail_0 <= 0;
        tail_1 <= 0;
        tail_2 <= 0;
        tail_3 <= 0;
        tail_4 <= 0;
        tail_5 <= 0;
        tail_6 <= 0;
        tail_7 <= 0;
        tail_8 <= 0;
        tail_9 <= 0;
        tail_10 <= 0;
        tail_11 <= 0;
        tail_12 <= 0;
        tail_13 <= 0;
        tail_14 <= 0;
        tail_15 <= 0;
        f2c_tail <= 0;
        f2c_head <= 0;
        f2c_kmem_addr <= 0;
        core_id <= 0;
    end
    else begin
        // Update core_id and tail pointer
        if (dma_done) begin
            if (core_id == total_core - 1) begin
               core_id <= 0;
            end
            else begin
               core_id <= core_id + 1;
            end

            case (core_id)
                4'd0: tail_0 <= new_tail;
                4'd1: tail_1 <= new_tail;
                4'd2: tail_2 <= new_tail;
                4'd3: tail_3 <= new_tail;
                4'd4: tail_4 <= new_tail;
                4'd5: tail_5 <= new_tail;
                4'd6: tail_6 <= new_tail;
                4'd7: tail_7 <= new_tail;
                4'd8: tail_8 <= new_tail;
                4'd9: tail_9 <= new_tail;
                4'd10: tail_10 <= new_tail;
                4'd11: tail_11 <= new_tail;
                4'd12: tail_12 <= new_tail;
                4'd13: tail_13 <= new_tail;
                4'd14: tail_14 <= new_tail;
                4'd15: tail_15 <= new_tail;
            endcase
        end

        // Select tail and kmem_addr
        case (core_id)
            4'd0: begin
                f2c_tail      <= tail_0;
                f2c_head      <= head_0[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_0,kmem_low_0};
            end
            4'd1: begin
                f2c_tail      <= tail_1;
                f2c_head      <= head_1[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_1,kmem_low_1};
            end
            4'd2: begin
                f2c_tail      <= tail_2;
                f2c_head      <= head_2[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_2,kmem_low_2};
            end
            4'd3: begin
                f2c_tail      <= tail_3;
                f2c_head      <= head_3[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_3,kmem_low_3};
            end
            4'd4: begin
                f2c_tail      <= tail_4;
                f2c_head      <= head_4[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_4,kmem_low_4};
            end
            4'd5: begin
                f2c_tail      <= tail_5;
                f2c_head      <= head_5[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_5,kmem_low_5};
            end
            4'd6: begin
                f2c_tail      <= tail_6;
                f2c_head      <= head_6[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_6,kmem_low_6};
            end
            4'd7: begin
                f2c_tail      <= tail_7;
                f2c_head      <= head_7[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_7,kmem_low_7};
            end
            4'd8: begin
                f2c_tail      <= tail_8;
                f2c_head      <= head_8[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_8,kmem_low_8};
            end
            4'd9: begin
                f2c_tail      <= tail_9;
                f2c_head      <= head_9[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_9,kmem_low_9};
            end
            4'd10: begin
                f2c_tail      <= tail_10;
                f2c_head      <= head_10[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_10,kmem_low_10};
            end
            4'd11: begin
                f2c_tail      <= tail_11;
                f2c_head      <= head_11[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_11,kmem_low_11};
            end
            4'd12: begin
                f2c_tail      <= tail_12;
                f2c_head      <= head_12[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_12,kmem_low_12};
            end
            4'd13: begin
                f2c_tail      <= tail_13;
                f2c_head      <= head_13[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_13,kmem_low_13};
            end
            4'd14: begin
                f2c_tail      <= tail_14;
                f2c_head      <= head_14[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_14,kmem_low_14};
            end
            4'd15: begin
                f2c_tail      <= tail_15;
                f2c_head      <= head_15[RB_AWIDTH-1:0];
                f2c_kmem_addr <= {kmem_high_15,kmem_low_15};
            end
        endcase
    end
end

// PDU_BUFFER
// CPU side read MUX, first 512 bit are registers, the rest is BRAM.
always @(posedge pcie_clk) begin
    if (cpu_reg_region_r2) begin
        case (address_0[7:6])
            2'd0: begin
                readdata_0 <= {pcie_reg15_pcie,pcie_reg14_pcie,pcie_reg13_pcie,pcie_reg12_pcie,
                               pcie_reg11_pcie,pcie_reg10_pcie,pcie_reg9_pcie,pcie_reg8_pcie,
                               pcie_reg7_pcie,pcie_reg6_pcie,pcie_reg5_pcie,pcie_reg4_pcie,
                               pcie_reg3_pcie,pcie_reg2_pcie,pcie_reg1_pcie,pcie_reg0_pcie};
            end
            2'd1: begin
                readdata_0 <= {pcie_reg31_pcie,pcie_reg30_pcie,pcie_reg29_pcie,pcie_reg28_pcie,
                               pcie_reg27_pcie,pcie_reg26_pcie,pcie_reg25_pcie,pcie_reg24_pcie,
                               pcie_reg23_pcie,pcie_reg22_pcie,pcie_reg21_pcie,pcie_reg20_pcie,
                               pcie_reg19_pcie,pcie_reg18_pcie,pcie_reg17_pcie,pcie_reg16_pcie};
            end
            2'd2: begin
                readdata_0 <= {pcie_reg47_pcie,pcie_reg46_pcie,pcie_reg45_pcie,pcie_reg44_pcie,
                               pcie_reg43_pcie,pcie_reg42_pcie,pcie_reg41_pcie,pcie_reg40_pcie,
                               pcie_reg39_pcie,pcie_reg38_pcie,pcie_reg37_pcie,pcie_reg36_pcie,
                               pcie_reg35_pcie,pcie_reg34_pcie,pcie_reg33_pcie,pcie_reg32_pcie};
            end
            2'd3: begin
                readdata_0 <= {pcie_reg63_pcie,pcie_reg62_pcie,pcie_reg61_pcie,pcie_reg60_pcie,
                               pcie_reg59_pcie,pcie_reg58_pcie,pcie_reg57_pcie,pcie_reg56_pcie,
                               pcie_reg55_pcie,pcie_reg54_pcie,pcie_reg53_pcie,pcie_reg52_pcie,
                               pcie_reg51_pcie,pcie_reg50_pcie,pcie_reg49_pcie,pcie_reg48_pcie};
            end
        endcase
        readdatavalid_0 <= read_0_r2;
    end
    else begin
        readdata_0 <= frb_readdata;
        readdatavalid_0 <= frb_readvalid;
    end
end

assign cpu_reg_region = address_0[17:6] < RB_BRAM_OFFSET;

assign frb_read     = cpu_reg_region ? 1'b0 : read_0;
assign frb_address  = address_0[17:6] - RB_BRAM_OFFSET; // First two 512 bit are registers.

// Two cycle read delay
always @(posedge pcie_clk) begin
    cpu_reg_region_r1 <= cpu_reg_region;
    cpu_reg_region_r2 <= cpu_reg_region_r1;

    read_0_r1 <= read_0;
    read_0_r2 <= read_0_r1;
end
`ifdef SIM
    assign pcie_rb_wr_base_addr = 0;
    assign pcie_rb_almost_full  = 0;
    assign pdumeta_cpu_valid    = 0;
`else

fpga2cpu_pcie f2c_inst (
    .clk            (pcie_clk),
    .rst            (!pcie_reset_n),
    .wr_data        (pcie_rb_wr_data),
    .wr_addr        (pcie_rb_wr_addr),
    .wr_en          (pcie_rb_wr_en),
    .wr_base_addr   (pcie_rb_wr_base_addr),
    .almost_full    (pcie_rb_almost_full),
    .update_valid   (pcie_rb_update_valid),
    .update_size    (pcie_rb_update_size),
    .head           (f2c_head),
    .tail           (f2c_tail),
    .kmem_addr      (f2c_kmem_addr),
    .out_tail       (new_tail),
    .dma_done       (dma_done),
    .rb_size        (rb_size),
    .wrdm_desc_ready(wrdm_desc_ready),
    .wrdm_desc_valid(wrdm_desc_valid),
    .wrdm_desc_data (wrdm_desc_data),
    .frb_readdata   (frb_readdata),
    .frb_readvalid  (frb_readvalid),
    .frb_address    (frb_address),
    .frb_read       (frb_read)
);

cpu2fpga_pcie c2f_inst (
    .clk                    (pcie_clk),
    .rst                    (!pcie_reset_n),
    .pdumeta_cpu_data       (pdumeta_cpu_data),
    .pdumeta_cpu_valid      (pdumeta_cpu_valid),
    .pdumeta_cnt            (pdumeta_cnt),
    .head                   (c2f_head),
    .tail                   (c2f_tail),
    .kmem_addr              (c2f_kmem_addr),
    .cpu_c2f_head_addr      (c2f_head_addr),
    .wrdm_prio_ready        (wrdm_prio_ready),
    .wrdm_prio_valid        (wrdm_prio_valid),
    .wrdm_prio_data         (wrdm_prio_data),
    .rddm_desc_ready        (rddm_desc_ready),
    .rddm_desc_valid        (rddm_desc_valid),
    .rddm_desc_data         (rddm_desc_data),
    .c2f_writedata          (writedata_1),
    .c2f_write              (write_1),
    .c2f_address            (address_1[14:6])
);

pcie_ed pcie (
    .refclk_clk                              (refclk_clk),                              //   input,    width = 1,         refclk.clk
    .pcie_rstn_npor                          (pcie_rstn_npor),                          //   input,    width = 1,      pcie_rstn.npor
    .pcie_rstn_pin_perst                     (pcie_rstn_pin_perst),                     //   input,    width = 1,               .pin_perst
    .hip_ctrl_simu_mode_pipe                 (hip_ctrl_simu_mode_pipe),                 //   input,    width = 1,       hip_ctrl.simu_mode_pipe
    .hip_ctrl_test_in                        (hip_ctrl_test_in),                        //   input,   width = 67,               .test_in
    .dut_wrdm_conduit_pfnum                  (),                          //                        dut_wrdm_conduit.pfnum
    .dut_wrdm_desc_ready                     (wrdm_desc_ready),                             //                           dut_wrdm_desc.ready
    .dut_wrdm_desc_valid                     (wrdm_desc_valid),                             //                                        .valid
    .dut_wrdm_desc_data                      (wrdm_desc_data),                              //                                        .data
    .dut_wrdm_prio_ready                     (wrdm_prio_ready),                             //                           dut_wrdm_prio.ready
    .dut_wrdm_prio_valid                     (wrdm_prio_valid),                             //                                        .valid
    .dut_wrdm_prio_data                      (wrdm_prio_data),                              //                                        .data
    .dut_wrdm_tx_valid                       (),                               //                             dut_wrdm_tx.valid
    .dut_wrdm_tx_data                        (),                                //                                        .data
    .dut_rddm_conduit_pfnum                  (),                          //                        dut_rddm_conduit.pfnum
    .dut_rddm_desc_ready                     (rddm_desc_ready),                             //                           dut_rddm_desc.ready
    .dut_rddm_desc_valid                     (rddm_desc_valid),                             //                                        .valid
    .dut_rddm_desc_data                      (rddm_desc_data),                              //                                        .data
    .dut_rddm_prio_ready                     (),                             //                           dut_rddm_prio.ready
    .dut_rddm_prio_valid                     (0),                             //                                        .valid
    .dut_rddm_prio_data                      (0),                              //                                        .data
    .dut_rddm_tx_valid                       (),                               //                             dut_rddm_tx.valid
    .dut_rddm_tx_data                        (),                                //                                        .data
    .pipe_sim_only_sim_pipe_pclk_in          (pipe_sim_only_sim_pipe_pclk_in),          //   input,    width = 1,  pipe_sim_only.sim_pipe_pclk_in
    .pipe_sim_only_sim_pipe_rate             (pipe_sim_only_sim_pipe_rate),             //  output,    width = 2,               .sim_pipe_rate
    .pipe_sim_only_sim_ltssmstate            (pipe_sim_only_sim_ltssmstate),            //  output,    width = 6,               .sim_ltssmstate
    .pipe_sim_only_txdata0                   (pipe_sim_only_txdata0),                   //  output,   width = 32,               .txdata0
    .pipe_sim_only_txdata1                   (pipe_sim_only_txdata1),                   //  output,   width = 32,               .txdata1
    .pipe_sim_only_txdata2                   (pipe_sim_only_txdata2),                   //  output,   width = 32,               .txdata2
    .pipe_sim_only_txdata3                   (pipe_sim_only_txdata3),                   //  output,   width = 32,               .txdata3
    .pipe_sim_only_txdata4                   (pipe_sim_only_txdata4),                   //  output,   width = 32,               .txdata4
    .pipe_sim_only_txdata5                   (pipe_sim_only_txdata5),                   //  output,   width = 32,               .txdata5
    .pipe_sim_only_txdata6                   (pipe_sim_only_txdata6),                   //  output,   width = 32,               .txdata6
    .pipe_sim_only_txdata7                   (pipe_sim_only_txdata7),                   //  output,   width = 32,               .txdata7
    .pipe_sim_only_txdata8                   (pipe_sim_only_txdata8),                   //  output,   width = 32,               .txdata8
    .pipe_sim_only_txdata9                   (pipe_sim_only_txdata9),                   //  output,   width = 32,               .txdata9
    .pipe_sim_only_txdata10                  (pipe_sim_only_txdata10),                  //  output,   width = 32,               .txdata10
    .pipe_sim_only_txdata11                  (pipe_sim_only_txdata11),                  //  output,   width = 32,               .txdata11
    .pipe_sim_only_txdata12                  (pipe_sim_only_txdata12),                  //  output,   width = 32,               .txdata12
    .pipe_sim_only_txdata13                  (pipe_sim_only_txdata13),                  //  output,   width = 32,               .txdata13
    .pipe_sim_only_txdata14                  (pipe_sim_only_txdata14),                  //  output,   width = 32,               .txdata14
    .pipe_sim_only_txdata15                  (pipe_sim_only_txdata15),                  //  output,   width = 32,               .txdata15
    .pipe_sim_only_txdatak0                  (pipe_sim_only_txdatak0),                  //  output,    width = 4,               .txdatak0
    .pipe_sim_only_txdatak1                  (pipe_sim_only_txdatak1),                  //  output,    width = 4,               .txdatak1
    .pipe_sim_only_txdatak2                  (pipe_sim_only_txdatak2),                  //  output,    width = 4,               .txdatak2
    .pipe_sim_only_txdatak3                  (pipe_sim_only_txdatak3),                  //  output,    width = 4,               .txdatak3
    .pipe_sim_only_txdatak4                  (pipe_sim_only_txdatak4),                  //  output,    width = 4,               .txdatak4
    .pipe_sim_only_txdatak5                  (pipe_sim_only_txdatak5),                  //  output,    width = 4,               .txdatak5
    .pipe_sim_only_txdatak6                  (pipe_sim_only_txdatak6),                  //  output,    width = 4,               .txdatak6
    .pipe_sim_only_txdatak7                  (pipe_sim_only_txdatak7),                  //  output,    width = 4,               .txdatak7
    .pipe_sim_only_txdatak8                  (pipe_sim_only_txdatak8),                  //  output,    width = 4,               .txdatak8
    .pipe_sim_only_txdatak9                  (pipe_sim_only_txdatak9),                  //  output,    width = 4,               .txdatak9
    .pipe_sim_only_txdatak10                 (pipe_sim_only_txdatak10),                 //  output,    width = 4,               .txdatak10
    .pipe_sim_only_txdatak11                 (pipe_sim_only_txdatak11),                 //  output,    width = 4,               .txdatak11
    .pipe_sim_only_txdatak12                 (pipe_sim_only_txdatak12),                 //  output,    width = 4,               .txdatak12
    .pipe_sim_only_txdatak13                 (pipe_sim_only_txdatak13),                 //  output,    width = 4,               .txdatak13
    .pipe_sim_only_txdatak14                 (pipe_sim_only_txdatak14),                 //  output,    width = 4,               .txdatak14
    .pipe_sim_only_txdatak15                 (pipe_sim_only_txdatak15),                 //  output,    width = 4,               .txdatak15
    .pipe_sim_only_txcompl0                  (pipe_sim_only_txcompl0),                  //  output,    width = 1,               .txcompl0
    .pipe_sim_only_txcompl1                  (pipe_sim_only_txcompl1),                  //  output,    width = 1,               .txcompl1
    .pipe_sim_only_txcompl2                  (pipe_sim_only_txcompl2),                  //  output,    width = 1,               .txcompl2
    .pipe_sim_only_txcompl3                  (pipe_sim_only_txcompl3),                  //  output,    width = 1,               .txcompl3
    .pipe_sim_only_txcompl4                  (pipe_sim_only_txcompl4),                  //  output,    width = 1,               .txcompl4
    .pipe_sim_only_txcompl5                  (pipe_sim_only_txcompl5),                  //  output,    width = 1,               .txcompl5
    .pipe_sim_only_txcompl6                  (pipe_sim_only_txcompl6),                  //  output,    width = 1,               .txcompl6
    .pipe_sim_only_txcompl7                  (pipe_sim_only_txcompl7),                  //  output,    width = 1,               .txcompl7
    .pipe_sim_only_txcompl8                  (pipe_sim_only_txcompl8),                  //  output,    width = 1,               .txcompl8
    .pipe_sim_only_txcompl9                  (pipe_sim_only_txcompl9),                  //  output,    width = 1,               .txcompl9
    .pipe_sim_only_txcompl10                 (pipe_sim_only_txcompl10),                 //  output,    width = 1,               .txcompl10
    .pipe_sim_only_txcompl11                 (pipe_sim_only_txcompl11),                 //  output,    width = 1,               .txcompl11
    .pipe_sim_only_txcompl12                 (pipe_sim_only_txcompl12),                 //  output,    width = 1,               .txcompl12
    .pipe_sim_only_txcompl13                 (pipe_sim_only_txcompl13),                 //  output,    width = 1,               .txcompl13
    .pipe_sim_only_txcompl14                 (pipe_sim_only_txcompl14),                 //  output,    width = 1,               .txcompl14
    .pipe_sim_only_txcompl15                 (pipe_sim_only_txcompl15),                 //  output,    width = 1,               .txcompl15
    .pipe_sim_only_txelecidle0               (pipe_sim_only_txelecidle0),               //  output,    width = 1,               .txelecidle0
    .pipe_sim_only_txelecidle1               (pipe_sim_only_txelecidle1),               //  output,    width = 1,               .txelecidle1
    .pipe_sim_only_txelecidle2               (pipe_sim_only_txelecidle2),               //  output,    width = 1,               .txelecidle2
    .pipe_sim_only_txelecidle3               (pipe_sim_only_txelecidle3),               //  output,    width = 1,               .txelecidle3
    .pipe_sim_only_txelecidle4               (pipe_sim_only_txelecidle4),               //  output,    width = 1,               .txelecidle4
    .pipe_sim_only_txelecidle5               (pipe_sim_only_txelecidle5),               //  output,    width = 1,               .txelecidle5
    .pipe_sim_only_txelecidle6               (pipe_sim_only_txelecidle6),               //  output,    width = 1,               .txelecidle6
    .pipe_sim_only_txelecidle7               (pipe_sim_only_txelecidle7),               //  output,    width = 1,               .txelecidle7
    .pipe_sim_only_txelecidle8               (pipe_sim_only_txelecidle8),               //  output,    width = 1,               .txelecidle8
    .pipe_sim_only_txelecidle9               (pipe_sim_only_txelecidle9),               //  output,    width = 1,               .txelecidle9
    .pipe_sim_only_txelecidle10              (pipe_sim_only_txelecidle10),              //  output,    width = 1,               .txelecidle10
    .pipe_sim_only_txelecidle11              (pipe_sim_only_txelecidle11),              //  output,    width = 1,               .txelecidle11
    .pipe_sim_only_txelecidle12              (pipe_sim_only_txelecidle12),              //  output,    width = 1,               .txelecidle12
    .pipe_sim_only_txelecidle13              (pipe_sim_only_txelecidle13),              //  output,    width = 1,               .txelecidle13
    .pipe_sim_only_txelecidle14              (pipe_sim_only_txelecidle14),              //  output,    width = 1,               .txelecidle14
    .pipe_sim_only_txelecidle15              (pipe_sim_only_txelecidle15),              //  output,    width = 1,               .txelecidle15
    .pipe_sim_only_txdetectrx0               (pipe_sim_only_txdetectrx0),               //  output,    width = 1,               .txdetectrx0
    .pipe_sim_only_txdetectrx1               (pipe_sim_only_txdetectrx1),               //  output,    width = 1,               .txdetectrx1
    .pipe_sim_only_txdetectrx2               (pipe_sim_only_txdetectrx2),               //  output,    width = 1,               .txdetectrx2
    .pipe_sim_only_txdetectrx3               (pipe_sim_only_txdetectrx3),               //  output,    width = 1,               .txdetectrx3
    .pipe_sim_only_txdetectrx4               (pipe_sim_only_txdetectrx4),               //  output,    width = 1,               .txdetectrx4
    .pipe_sim_only_txdetectrx5               (pipe_sim_only_txdetectrx5),               //  output,    width = 1,               .txdetectrx5
    .pipe_sim_only_txdetectrx6               (pipe_sim_only_txdetectrx6),               //  output,    width = 1,               .txdetectrx6
    .pipe_sim_only_txdetectrx7               (pipe_sim_only_txdetectrx7),               //  output,    width = 1,               .txdetectrx7
    .pipe_sim_only_txdetectrx8               (pipe_sim_only_txdetectrx8),               //  output,    width = 1,               .txdetectrx8
    .pipe_sim_only_txdetectrx9               (pipe_sim_only_txdetectrx9),               //  output,    width = 1,               .txdetectrx9
    .pipe_sim_only_txdetectrx10              (pipe_sim_only_txdetectrx10),              //  output,    width = 1,               .txdetectrx10
    .pipe_sim_only_txdetectrx11              (pipe_sim_only_txdetectrx11),              //  output,    width = 1,               .txdetectrx11
    .pipe_sim_only_txdetectrx12              (pipe_sim_only_txdetectrx12),              //  output,    width = 1,               .txdetectrx12
    .pipe_sim_only_txdetectrx13              (pipe_sim_only_txdetectrx13),              //  output,    width = 1,               .txdetectrx13
    .pipe_sim_only_txdetectrx14              (pipe_sim_only_txdetectrx14),              //  output,    width = 1,               .txdetectrx14
    .pipe_sim_only_txdetectrx15              (pipe_sim_only_txdetectrx15),              //  output,    width = 1,               .txdetectrx15
    .pipe_sim_only_powerdown0                (pipe_sim_only_powerdown0),                //  output,    width = 2,               .powerdown0
    .pipe_sim_only_powerdown1                (pipe_sim_only_powerdown1),                //  output,    width = 2,               .powerdown1
    .pipe_sim_only_powerdown2                (pipe_sim_only_powerdown2),                //  output,    width = 2,               .powerdown2
    .pipe_sim_only_powerdown3                (pipe_sim_only_powerdown3),                //  output,    width = 2,               .powerdown3
    .pipe_sim_only_powerdown4                (pipe_sim_only_powerdown4),                //  output,    width = 2,               .powerdown4
    .pipe_sim_only_powerdown5                (pipe_sim_only_powerdown5),                //  output,    width = 2,               .powerdown5
    .pipe_sim_only_powerdown6                (pipe_sim_only_powerdown6),                //  output,    width = 2,               .powerdown6
    .pipe_sim_only_powerdown7                (pipe_sim_only_powerdown7),                //  output,    width = 2,               .powerdown7
    .pipe_sim_only_powerdown8                (pipe_sim_only_powerdown8),                //  output,    width = 2,               .powerdown8
    .pipe_sim_only_powerdown9                (pipe_sim_only_powerdown9),                //  output,    width = 2,               .powerdown9
    .pipe_sim_only_powerdown10               (pipe_sim_only_powerdown10),               //  output,    width = 2,               .powerdown10
    .pipe_sim_only_powerdown11               (pipe_sim_only_powerdown11),               //  output,    width = 2,               .powerdown11
    .pipe_sim_only_powerdown12               (pipe_sim_only_powerdown12),               //  output,    width = 2,               .powerdown12
    .pipe_sim_only_powerdown13               (pipe_sim_only_powerdown13),               //  output,    width = 2,               .powerdown13
    .pipe_sim_only_powerdown14               (pipe_sim_only_powerdown14),               //  output,    width = 2,               .powerdown14
    .pipe_sim_only_powerdown15               (pipe_sim_only_powerdown15),               //  output,    width = 2,               .powerdown15
    .pipe_sim_only_txmargin0                 (pipe_sim_only_txmargin0),                 //  output,    width = 3,               .txmargin0
    .pipe_sim_only_txmargin1                 (pipe_sim_only_txmargin1),                 //  output,    width = 3,               .txmargin1
    .pipe_sim_only_txmargin2                 (pipe_sim_only_txmargin2),                 //  output,    width = 3,               .txmargin2
    .pipe_sim_only_txmargin3                 (pipe_sim_only_txmargin3),                 //  output,    width = 3,               .txmargin3
    .pipe_sim_only_txmargin4                 (pipe_sim_only_txmargin4),                 //  output,    width = 3,               .txmargin4
    .pipe_sim_only_txmargin5                 (pipe_sim_only_txmargin5),                 //  output,    width = 3,               .txmargin5
    .pipe_sim_only_txmargin6                 (pipe_sim_only_txmargin6),                 //  output,    width = 3,               .txmargin6
    .pipe_sim_only_txmargin7                 (pipe_sim_only_txmargin7),                 //  output,    width = 3,               .txmargin7
    .pipe_sim_only_txmargin8                 (pipe_sim_only_txmargin8),                 //  output,    width = 3,               .txmargin8
    .pipe_sim_only_txmargin9                 (pipe_sim_only_txmargin9),                 //  output,    width = 3,               .txmargin9
    .pipe_sim_only_txmargin10                (pipe_sim_only_txmargin10),                //  output,    width = 3,               .txmargin10
    .pipe_sim_only_txmargin11                (pipe_sim_only_txmargin11),                //  output,    width = 3,               .txmargin11
    .pipe_sim_only_txmargin12                (pipe_sim_only_txmargin12),                //  output,    width = 3,               .txmargin12
    .pipe_sim_only_txmargin13                (pipe_sim_only_txmargin13),                //  output,    width = 3,               .txmargin13
    .pipe_sim_only_txmargin14                (pipe_sim_only_txmargin14),                //  output,    width = 3,               .txmargin14
    .pipe_sim_only_txmargin15                (pipe_sim_only_txmargin15),                //  output,    width = 3,               .txmargin15
    .pipe_sim_only_txdeemph0                 (pipe_sim_only_txdeemph0),                 //  output,    width = 1,               .txdeemph0
    .pipe_sim_only_txdeemph1                 (pipe_sim_only_txdeemph1),                 //  output,    width = 1,               .txdeemph1
    .pipe_sim_only_txdeemph2                 (pipe_sim_only_txdeemph2),                 //  output,    width = 1,               .txdeemph2
    .pipe_sim_only_txdeemph3                 (pipe_sim_only_txdeemph3),                 //  output,    width = 1,               .txdeemph3
    .pipe_sim_only_txdeemph4                 (pipe_sim_only_txdeemph4),                 //  output,    width = 1,               .txdeemph4
    .pipe_sim_only_txdeemph5                 (pipe_sim_only_txdeemph5),                 //  output,    width = 1,               .txdeemph5
    .pipe_sim_only_txdeemph6                 (pipe_sim_only_txdeemph6),                 //  output,    width = 1,               .txdeemph6
    .pipe_sim_only_txdeemph7                 (pipe_sim_only_txdeemph7),                 //  output,    width = 1,               .txdeemph7
    .pipe_sim_only_txdeemph8                 (pipe_sim_only_txdeemph8),                 //  output,    width = 1,               .txdeemph8
    .pipe_sim_only_txdeemph9                 (pipe_sim_only_txdeemph9),                 //  output,    width = 1,               .txdeemph9
    .pipe_sim_only_txdeemph10                (pipe_sim_only_txdeemph10),                //  output,    width = 1,               .txdeemph10
    .pipe_sim_only_txdeemph11                (pipe_sim_only_txdeemph11),                //  output,    width = 1,               .txdeemph11
    .pipe_sim_only_txdeemph12                (pipe_sim_only_txdeemph12),                //  output,    width = 1,               .txdeemph12
    .pipe_sim_only_txdeemph13                (pipe_sim_only_txdeemph13),                //  output,    width = 1,               .txdeemph13
    .pipe_sim_only_txdeemph14                (pipe_sim_only_txdeemph14),                //  output,    width = 1,               .txdeemph14
    .pipe_sim_only_txdeemph15                (pipe_sim_only_txdeemph15),                //  output,    width = 1,               .txdeemph15
    .pipe_sim_only_txswing0                  (pipe_sim_only_txswing0),                  //  output,    width = 1,               .txswing0
    .pipe_sim_only_txswing1                  (pipe_sim_only_txswing1),                  //  output,    width = 1,               .txswing1
    .pipe_sim_only_txswing2                  (pipe_sim_only_txswing2),                  //  output,    width = 1,               .txswing2
    .pipe_sim_only_txswing3                  (pipe_sim_only_txswing3),                  //  output,    width = 1,               .txswing3
    .pipe_sim_only_txswing4                  (pipe_sim_only_txswing4),                  //  output,    width = 1,               .txswing4
    .pipe_sim_only_txswing5                  (pipe_sim_only_txswing5),                  //  output,    width = 1,               .txswing5
    .pipe_sim_only_txswing6                  (pipe_sim_only_txswing6),                  //  output,    width = 1,               .txswing6
    .pipe_sim_only_txswing7                  (pipe_sim_only_txswing7),                  //  output,    width = 1,               .txswing7
    .pipe_sim_only_txswing8                  (pipe_sim_only_txswing8),                  //  output,    width = 1,               .txswing8
    .pipe_sim_only_txswing9                  (pipe_sim_only_txswing9),                  //  output,    width = 1,               .txswing9
    .pipe_sim_only_txswing10                 (pipe_sim_only_txswing10),                 //  output,    width = 1,               .txswing10
    .pipe_sim_only_txswing11                 (pipe_sim_only_txswing11),                 //  output,    width = 1,               .txswing11
    .pipe_sim_only_txswing12                 (pipe_sim_only_txswing12),                 //  output,    width = 1,               .txswing12
    .pipe_sim_only_txswing13                 (pipe_sim_only_txswing13),                 //  output,    width = 1,               .txswing13
    .pipe_sim_only_txswing14                 (pipe_sim_only_txswing14),                 //  output,    width = 1,               .txswing14
    .pipe_sim_only_txswing15                 (pipe_sim_only_txswing15),                 //  output,    width = 1,               .txswing15
    .pipe_sim_only_txsynchd0                 (pipe_sim_only_txsynchd0),                 //  output,    width = 2,               .txsynchd0
    .pipe_sim_only_txsynchd1                 (pipe_sim_only_txsynchd1),                 //  output,    width = 2,               .txsynchd1
    .pipe_sim_only_txsynchd2                 (pipe_sim_only_txsynchd2),                 //  output,    width = 2,               .txsynchd2
    .pipe_sim_only_txsynchd3                 (pipe_sim_only_txsynchd3),                 //  output,    width = 2,               .txsynchd3
    .pipe_sim_only_txsynchd4                 (pipe_sim_only_txsynchd4),                 //  output,    width = 2,               .txsynchd4
    .pipe_sim_only_txsynchd5                 (pipe_sim_only_txsynchd5),                 //  output,    width = 2,               .txsynchd5
    .pipe_sim_only_txsynchd6                 (pipe_sim_only_txsynchd6),                 //  output,    width = 2,               .txsynchd6
    .pipe_sim_only_txsynchd7                 (pipe_sim_only_txsynchd7),                 //  output,    width = 2,               .txsynchd7
    .pipe_sim_only_txsynchd8                 (pipe_sim_only_txsynchd8),                 //  output,    width = 2,               .txsynchd8
    .pipe_sim_only_txsynchd9                 (pipe_sim_only_txsynchd9),                 //  output,    width = 2,               .txsynchd9
    .pipe_sim_only_txsynchd10                (pipe_sim_only_txsynchd10),                //  output,    width = 2,               .txsynchd10
    .pipe_sim_only_txsynchd11                (pipe_sim_only_txsynchd11),                //  output,    width = 2,               .txsynchd11
    .pipe_sim_only_txsynchd12                (pipe_sim_only_txsynchd12),                //  output,    width = 2,               .txsynchd12
    .pipe_sim_only_txsynchd13                (pipe_sim_only_txsynchd13),                //  output,    width = 2,               .txsynchd13
    .pipe_sim_only_txsynchd14                (pipe_sim_only_txsynchd14),                //  output,    width = 2,               .txsynchd14
    .pipe_sim_only_txsynchd15                (pipe_sim_only_txsynchd15),                //  output,    width = 2,               .txsynchd15
    .pipe_sim_only_txblkst0                  (pipe_sim_only_txblkst0),                  //  output,    width = 1,               .txblkst0
    .pipe_sim_only_txblkst1                  (pipe_sim_only_txblkst1),                  //  output,    width = 1,               .txblkst1
    .pipe_sim_only_txblkst2                  (pipe_sim_only_txblkst2),                  //  output,    width = 1,               .txblkst2
    .pipe_sim_only_txblkst3                  (pipe_sim_only_txblkst3),                  //  output,    width = 1,               .txblkst3
    .pipe_sim_only_txblkst4                  (pipe_sim_only_txblkst4),                  //  output,    width = 1,               .txblkst4
    .pipe_sim_only_txblkst5                  (pipe_sim_only_txblkst5),                  //  output,    width = 1,               .txblkst5
    .pipe_sim_only_txblkst6                  (pipe_sim_only_txblkst6),                  //  output,    width = 1,               .txblkst6
    .pipe_sim_only_txblkst7                  (pipe_sim_only_txblkst7),                  //  output,    width = 1,               .txblkst7
    .pipe_sim_only_txblkst8                  (pipe_sim_only_txblkst8),                  //  output,    width = 1,               .txblkst8
    .pipe_sim_only_txblkst9                  (pipe_sim_only_txblkst9),                  //  output,    width = 1,               .txblkst9
    .pipe_sim_only_txblkst10                 (pipe_sim_only_txblkst10),                 //  output,    width = 1,               .txblkst10
    .pipe_sim_only_txblkst11                 (pipe_sim_only_txblkst11),                 //  output,    width = 1,               .txblkst11
    .pipe_sim_only_txblkst12                 (pipe_sim_only_txblkst12),                 //  output,    width = 1,               .txblkst12
    .pipe_sim_only_txblkst13                 (pipe_sim_only_txblkst13),                 //  output,    width = 1,               .txblkst13
    .pipe_sim_only_txblkst14                 (pipe_sim_only_txblkst14),                 //  output,    width = 1,               .txblkst14
    .pipe_sim_only_txblkst15                 (pipe_sim_only_txblkst15),                 //  output,    width = 1,               .txblkst15
    .pipe_sim_only_txdataskip0               (pipe_sim_only_txdataskip0),               //  output,    width = 1,               .txdataskip0
    .pipe_sim_only_txdataskip1               (pipe_sim_only_txdataskip1),               //  output,    width = 1,               .txdataskip1
    .pipe_sim_only_txdataskip2               (pipe_sim_only_txdataskip2),               //  output,    width = 1,               .txdataskip2
    .pipe_sim_only_txdataskip3               (pipe_sim_only_txdataskip3),               //  output,    width = 1,               .txdataskip3
    .pipe_sim_only_txdataskip4               (pipe_sim_only_txdataskip4),               //  output,    width = 1,               .txdataskip4
    .pipe_sim_only_txdataskip5               (pipe_sim_only_txdataskip5),               //  output,    width = 1,               .txdataskip5
    .pipe_sim_only_txdataskip6               (pipe_sim_only_txdataskip6),               //  output,    width = 1,               .txdataskip6
    .pipe_sim_only_txdataskip7               (pipe_sim_only_txdataskip7),               //  output,    width = 1,               .txdataskip7
    .pipe_sim_only_txdataskip8               (pipe_sim_only_txdataskip8),               //  output,    width = 1,               .txdataskip8
    .pipe_sim_only_txdataskip9               (pipe_sim_only_txdataskip9),               //  output,    width = 1,               .txdataskip9
    .pipe_sim_only_txdataskip10              (pipe_sim_only_txdataskip10),              //  output,    width = 1,               .txdataskip10
    .pipe_sim_only_txdataskip11              (pipe_sim_only_txdataskip11),              //  output,    width = 1,               .txdataskip11
    .pipe_sim_only_txdataskip12              (pipe_sim_only_txdataskip12),              //  output,    width = 1,               .txdataskip12
    .pipe_sim_only_txdataskip13              (pipe_sim_only_txdataskip13),              //  output,    width = 1,               .txdataskip13
    .pipe_sim_only_txdataskip14              (pipe_sim_only_txdataskip14),              //  output,    width = 1,               .txdataskip14
    .pipe_sim_only_txdataskip15              (pipe_sim_only_txdataskip15),              //  output,    width = 1,               .txdataskip15
    .pipe_sim_only_rate0                     (pipe_sim_only_rate0),                     //  output,    width = 2,               .rate0
    .pipe_sim_only_rate1                     (pipe_sim_only_rate1),                     //  output,    width = 2,               .rate1
    .pipe_sim_only_rate2                     (pipe_sim_only_rate2),                     //  output,    width = 2,               .rate2
    .pipe_sim_only_rate3                     (pipe_sim_only_rate3),                     //  output,    width = 2,               .rate3
    .pipe_sim_only_rate4                     (pipe_sim_only_rate4),                     //  output,    width = 2,               .rate4
    .pipe_sim_only_rate5                     (pipe_sim_only_rate5),                     //  output,    width = 2,               .rate5
    .pipe_sim_only_rate6                     (pipe_sim_only_rate6),                     //  output,    width = 2,               .rate6
    .pipe_sim_only_rate7                     (pipe_sim_only_rate7),                     //  output,    width = 2,               .rate7
    .pipe_sim_only_rate8                     (pipe_sim_only_rate8),                     //  output,    width = 2,               .rate8
    .pipe_sim_only_rate9                     (pipe_sim_only_rate9),                     //  output,    width = 2,               .rate9
    .pipe_sim_only_rate10                    (pipe_sim_only_rate10),                    //  output,    width = 2,               .rate10
    .pipe_sim_only_rate11                    (pipe_sim_only_rate11),                    //  output,    width = 2,               .rate11
    .pipe_sim_only_rate12                    (pipe_sim_only_rate12),                    //  output,    width = 2,               .rate12
    .pipe_sim_only_rate13                    (pipe_sim_only_rate13),                    //  output,    width = 2,               .rate13
    .pipe_sim_only_rate14                    (pipe_sim_only_rate14),                    //  output,    width = 2,               .rate14
    .pipe_sim_only_rate15                    (pipe_sim_only_rate15),                    //  output,    width = 2,               .rate15
    .pipe_sim_only_rxpolarity0               (pipe_sim_only_rxpolarity0),               //  output,    width = 1,               .rxpolarity0
    .pipe_sim_only_rxpolarity1               (pipe_sim_only_rxpolarity1),               //  output,    width = 1,               .rxpolarity1
    .pipe_sim_only_rxpolarity2               (pipe_sim_only_rxpolarity2),               //  output,    width = 1,               .rxpolarity2
    .pipe_sim_only_rxpolarity3               (pipe_sim_only_rxpolarity3),               //  output,    width = 1,               .rxpolarity3
    .pipe_sim_only_rxpolarity4               (pipe_sim_only_rxpolarity4),               //  output,    width = 1,               .rxpolarity4
    .pipe_sim_only_rxpolarity5               (pipe_sim_only_rxpolarity5),               //  output,    width = 1,               .rxpolarity5
    .pipe_sim_only_rxpolarity6               (pipe_sim_only_rxpolarity6),               //  output,    width = 1,               .rxpolarity6
    .pipe_sim_only_rxpolarity7               (pipe_sim_only_rxpolarity7),               //  output,    width = 1,               .rxpolarity7
    .pipe_sim_only_rxpolarity8               (pipe_sim_only_rxpolarity8),               //  output,    width = 1,               .rxpolarity8
    .pipe_sim_only_rxpolarity9               (pipe_sim_only_rxpolarity9),               //  output,    width = 1,               .rxpolarity9
    .pipe_sim_only_rxpolarity10              (pipe_sim_only_rxpolarity10),              //  output,    width = 1,               .rxpolarity10
    .pipe_sim_only_rxpolarity11              (pipe_sim_only_rxpolarity11),              //  output,    width = 1,               .rxpolarity11
    .pipe_sim_only_rxpolarity12              (pipe_sim_only_rxpolarity12),              //  output,    width = 1,               .rxpolarity12
    .pipe_sim_only_rxpolarity13              (pipe_sim_only_rxpolarity13),              //  output,    width = 1,               .rxpolarity13
    .pipe_sim_only_rxpolarity14              (pipe_sim_only_rxpolarity14),              //  output,    width = 1,               .rxpolarity14
    .pipe_sim_only_rxpolarity15              (pipe_sim_only_rxpolarity15),              //  output,    width = 1,               .rxpolarity15
    .pipe_sim_only_currentrxpreset0          (pipe_sim_only_currentrxpreset0),          //  output,    width = 3,               .currentrxpreset0
    .pipe_sim_only_currentrxpreset1          (pipe_sim_only_currentrxpreset1),          //  output,    width = 3,               .currentrxpreset1
    .pipe_sim_only_currentrxpreset2          (pipe_sim_only_currentrxpreset2),          //  output,    width = 3,               .currentrxpreset2
    .pipe_sim_only_currentrxpreset3          (pipe_sim_only_currentrxpreset3),          //  output,    width = 3,               .currentrxpreset3
    .pipe_sim_only_currentrxpreset4          (pipe_sim_only_currentrxpreset4),          //  output,    width = 3,               .currentrxpreset4
    .pipe_sim_only_currentrxpreset5          (pipe_sim_only_currentrxpreset5),          //  output,    width = 3,               .currentrxpreset5
    .pipe_sim_only_currentrxpreset6          (pipe_sim_only_currentrxpreset6),          //  output,    width = 3,               .currentrxpreset6
    .pipe_sim_only_currentrxpreset7          (pipe_sim_only_currentrxpreset7),          //  output,    width = 3,               .currentrxpreset7
    .pipe_sim_only_currentrxpreset8          (pipe_sim_only_currentrxpreset8),          //  output,    width = 3,               .currentrxpreset8
    .pipe_sim_only_currentrxpreset9          (pipe_sim_only_currentrxpreset9),          //  output,    width = 3,               .currentrxpreset9
    .pipe_sim_only_currentrxpreset10         (pipe_sim_only_currentrxpreset10),         //  output,    width = 3,               .currentrxpreset10
    .pipe_sim_only_currentrxpreset11         (pipe_sim_only_currentrxpreset11),         //  output,    width = 3,               .currentrxpreset11
    .pipe_sim_only_currentrxpreset12         (pipe_sim_only_currentrxpreset12),         //  output,    width = 3,               .currentrxpreset12
    .pipe_sim_only_currentrxpreset13         (pipe_sim_only_currentrxpreset13),         //  output,    width = 3,               .currentrxpreset13
    .pipe_sim_only_currentrxpreset14         (pipe_sim_only_currentrxpreset14),         //  output,    width = 3,               .currentrxpreset14
    .pipe_sim_only_currentrxpreset15         (pipe_sim_only_currentrxpreset15),         //  output,    width = 3,               .currentrxpreset15
    .pipe_sim_only_currentcoeff0             (pipe_sim_only_currentcoeff0),             //  output,   width = 18,               .currentcoeff0
    .pipe_sim_only_currentcoeff1             (pipe_sim_only_currentcoeff1),             //  output,   width = 18,               .currentcoeff1
    .pipe_sim_only_currentcoeff2             (pipe_sim_only_currentcoeff2),             //  output,   width = 18,               .currentcoeff2
    .pipe_sim_only_currentcoeff3             (pipe_sim_only_currentcoeff3),             //  output,   width = 18,               .currentcoeff3
    .pipe_sim_only_currentcoeff4             (pipe_sim_only_currentcoeff4),             //  output,   width = 18,               .currentcoeff4
    .pipe_sim_only_currentcoeff5             (pipe_sim_only_currentcoeff5),             //  output,   width = 18,               .currentcoeff5
    .pipe_sim_only_currentcoeff6             (pipe_sim_only_currentcoeff6),             //  output,   width = 18,               .currentcoeff6
    .pipe_sim_only_currentcoeff7             (pipe_sim_only_currentcoeff7),             //  output,   width = 18,               .currentcoeff7
    .pipe_sim_only_currentcoeff8             (pipe_sim_only_currentcoeff8),             //  output,   width = 18,               .currentcoeff8
    .pipe_sim_only_currentcoeff9             (pipe_sim_only_currentcoeff9),             //  output,   width = 18,               .currentcoeff9
    .pipe_sim_only_currentcoeff10            (pipe_sim_only_currentcoeff10),            //  output,   width = 18,               .currentcoeff10
    .pipe_sim_only_currentcoeff11            (pipe_sim_only_currentcoeff11),            //  output,   width = 18,               .currentcoeff11
    .pipe_sim_only_currentcoeff12            (pipe_sim_only_currentcoeff12),            //  output,   width = 18,               .currentcoeff12
    .pipe_sim_only_currentcoeff13            (pipe_sim_only_currentcoeff13),            //  output,   width = 18,               .currentcoeff13
    .pipe_sim_only_currentcoeff14            (pipe_sim_only_currentcoeff14),            //  output,   width = 18,               .currentcoeff14
    .pipe_sim_only_currentcoeff15            (pipe_sim_only_currentcoeff15),            //  output,   width = 18,               .currentcoeff15
    .pipe_sim_only_rxeqeval0                 (pipe_sim_only_rxeqeval0),                 //  output,    width = 1,               .rxeqeval0
    .pipe_sim_only_rxeqeval1                 (pipe_sim_only_rxeqeval1),                 //  output,    width = 1,               .rxeqeval1
    .pipe_sim_only_rxeqeval2                 (pipe_sim_only_rxeqeval2),                 //  output,    width = 1,               .rxeqeval2
    .pipe_sim_only_rxeqeval3                 (pipe_sim_only_rxeqeval3),                 //  output,    width = 1,               .rxeqeval3
    .pipe_sim_only_rxeqeval4                 (pipe_sim_only_rxeqeval4),                 //  output,    width = 1,               .rxeqeval4
    .pipe_sim_only_rxeqeval5                 (pipe_sim_only_rxeqeval5),                 //  output,    width = 1,               .rxeqeval5
    .pipe_sim_only_rxeqeval6                 (pipe_sim_only_rxeqeval6),                 //  output,    width = 1,               .rxeqeval6
    .pipe_sim_only_rxeqeval7                 (pipe_sim_only_rxeqeval7),                 //  output,    width = 1,               .rxeqeval7
    .pipe_sim_only_rxeqeval8                 (pipe_sim_only_rxeqeval8),                 //  output,    width = 1,               .rxeqeval8
    .pipe_sim_only_rxeqeval9                 (pipe_sim_only_rxeqeval9),                 //  output,    width = 1,               .rxeqeval9
    .pipe_sim_only_rxeqeval10                (pipe_sim_only_rxeqeval10),                //  output,    width = 1,               .rxeqeval10
    .pipe_sim_only_rxeqeval11                (pipe_sim_only_rxeqeval11),                //  output,    width = 1,               .rxeqeval11
    .pipe_sim_only_rxeqeval12                (pipe_sim_only_rxeqeval12),                //  output,    width = 1,               .rxeqeval12
    .pipe_sim_only_rxeqeval13                (pipe_sim_only_rxeqeval13),                //  output,    width = 1,               .rxeqeval13
    .pipe_sim_only_rxeqeval14                (pipe_sim_only_rxeqeval14),                //  output,    width = 1,               .rxeqeval14
    .pipe_sim_only_rxeqeval15                (pipe_sim_only_rxeqeval15),                //  output,    width = 1,               .rxeqeval15
    .pipe_sim_only_rxeqinprogress0           (pipe_sim_only_rxeqinprogress0),           //  output,    width = 1,               .rxeqinprogress0
    .pipe_sim_only_rxeqinprogress1           (pipe_sim_only_rxeqinprogress1),           //  output,    width = 1,               .rxeqinprogress1
    .pipe_sim_only_rxeqinprogress2           (pipe_sim_only_rxeqinprogress2),           //  output,    width = 1,               .rxeqinprogress2
    .pipe_sim_only_rxeqinprogress3           (pipe_sim_only_rxeqinprogress3),           //  output,    width = 1,               .rxeqinprogress3
    .pipe_sim_only_rxeqinprogress4           (pipe_sim_only_rxeqinprogress4),           //  output,    width = 1,               .rxeqinprogress4
    .pipe_sim_only_rxeqinprogress5           (pipe_sim_only_rxeqinprogress5),           //  output,    width = 1,               .rxeqinprogress5
    .pipe_sim_only_rxeqinprogress6           (pipe_sim_only_rxeqinprogress6),           //  output,    width = 1,               .rxeqinprogress6
    .pipe_sim_only_rxeqinprogress7           (pipe_sim_only_rxeqinprogress7),           //  output,    width = 1,               .rxeqinprogress7
    .pipe_sim_only_rxeqinprogress8           (pipe_sim_only_rxeqinprogress8),           //  output,    width = 1,               .rxeqinprogress8
    .pipe_sim_only_rxeqinprogress9           (pipe_sim_only_rxeqinprogress9),           //  output,    width = 1,               .rxeqinprogress9
    .pipe_sim_only_rxeqinprogress10          (pipe_sim_only_rxeqinprogress10),          //  output,    width = 1,               .rxeqinprogress10
    .pipe_sim_only_rxeqinprogress11          (pipe_sim_only_rxeqinprogress11),          //  output,    width = 1,               .rxeqinprogress11
    .pipe_sim_only_rxeqinprogress12          (pipe_sim_only_rxeqinprogress12),          //  output,    width = 1,               .rxeqinprogress12
    .pipe_sim_only_rxeqinprogress13          (pipe_sim_only_rxeqinprogress13),          //  output,    width = 1,               .rxeqinprogress13
    .pipe_sim_only_rxeqinprogress14          (pipe_sim_only_rxeqinprogress14),          //  output,    width = 1,               .rxeqinprogress14
    .pipe_sim_only_rxeqinprogress15          (pipe_sim_only_rxeqinprogress15),          //  output,    width = 1,               .rxeqinprogress15
    .pipe_sim_only_invalidreq0               (pipe_sim_only_invalidreq0),               //  output,    width = 1,               .invalidreq0
    .pipe_sim_only_invalidreq1               (pipe_sim_only_invalidreq1),               //  output,    width = 1,               .invalidreq1
    .pipe_sim_only_invalidreq2               (pipe_sim_only_invalidreq2),               //  output,    width = 1,               .invalidreq2
    .pipe_sim_only_invalidreq3               (pipe_sim_only_invalidreq3),               //  output,    width = 1,               .invalidreq3
    .pipe_sim_only_invalidreq4               (pipe_sim_only_invalidreq4),               //  output,    width = 1,               .invalidreq4
    .pipe_sim_only_invalidreq5               (pipe_sim_only_invalidreq5),               //  output,    width = 1,               .invalidreq5
    .pipe_sim_only_invalidreq6               (pipe_sim_only_invalidreq6),               //  output,    width = 1,               .invalidreq6
    .pipe_sim_only_invalidreq7               (pipe_sim_only_invalidreq7),               //  output,    width = 1,               .invalidreq7
    .pipe_sim_only_invalidreq8               (pipe_sim_only_invalidreq8),               //  output,    width = 1,               .invalidreq8
    .pipe_sim_only_invalidreq9               (pipe_sim_only_invalidreq9),               //  output,    width = 1,               .invalidreq9
    .pipe_sim_only_invalidreq10              (pipe_sim_only_invalidreq10),              //  output,    width = 1,               .invalidreq10
    .pipe_sim_only_invalidreq11              (pipe_sim_only_invalidreq11),              //  output,    width = 1,               .invalidreq11
    .pipe_sim_only_invalidreq12              (pipe_sim_only_invalidreq12),              //  output,    width = 1,               .invalidreq12
    .pipe_sim_only_invalidreq13              (pipe_sim_only_invalidreq13),              //  output,    width = 1,               .invalidreq13
    .pipe_sim_only_invalidreq14              (pipe_sim_only_invalidreq14),              //  output,    width = 1,               .invalidreq14
    .pipe_sim_only_invalidreq15              (pipe_sim_only_invalidreq15),              //  output,    width = 1,               .invalidreq15
    .pipe_sim_only_rxdata0                   (pipe_sim_only_rxdata0),                   //   input,   width = 32,               .rxdata0
    .pipe_sim_only_rxdata1                   (pipe_sim_only_rxdata1),                   //   input,   width = 32,               .rxdata1
    .pipe_sim_only_rxdata2                   (pipe_sim_only_rxdata2),                   //   input,   width = 32,               .rxdata2
    .pipe_sim_only_rxdata3                   (pipe_sim_only_rxdata3),                   //   input,   width = 32,               .rxdata3
    .pipe_sim_only_rxdata4                   (pipe_sim_only_rxdata4),                   //   input,   width = 32,               .rxdata4
    .pipe_sim_only_rxdata5                   (pipe_sim_only_rxdata5),                   //   input,   width = 32,               .rxdata5
    .pipe_sim_only_rxdata6                   (pipe_sim_only_rxdata6),                   //   input,   width = 32,               .rxdata6
    .pipe_sim_only_rxdata7                   (pipe_sim_only_rxdata7),                   //   input,   width = 32,               .rxdata7
    .pipe_sim_only_rxdata8                   (pipe_sim_only_rxdata8),                   //   input,   width = 32,               .rxdata8
    .pipe_sim_only_rxdata9                   (pipe_sim_only_rxdata9),                   //   input,   width = 32,               .rxdata9
    .pipe_sim_only_rxdata10                  (pipe_sim_only_rxdata10),                  //   input,   width = 32,               .rxdata10
    .pipe_sim_only_rxdata11                  (pipe_sim_only_rxdata11),                  //   input,   width = 32,               .rxdata11
    .pipe_sim_only_rxdata12                  (pipe_sim_only_rxdata12),                  //   input,   width = 32,               .rxdata12
    .pipe_sim_only_rxdata13                  (pipe_sim_only_rxdata13),                  //   input,   width = 32,               .rxdata13
    .pipe_sim_only_rxdata14                  (pipe_sim_only_rxdata14),                  //   input,   width = 32,               .rxdata14
    .pipe_sim_only_rxdata15                  (pipe_sim_only_rxdata15),                  //   input,   width = 32,               .rxdata15
    .pipe_sim_only_rxdatak0                  (pipe_sim_only_rxdatak0),                  //   input,    width = 4,               .rxdatak0
    .pipe_sim_only_rxdatak1                  (pipe_sim_only_rxdatak1),                  //   input,    width = 4,               .rxdatak1
    .pipe_sim_only_rxdatak2                  (pipe_sim_only_rxdatak2),                  //   input,    width = 4,               .rxdatak2
    .pipe_sim_only_rxdatak3                  (pipe_sim_only_rxdatak3),                  //   input,    width = 4,               .rxdatak3
    .pipe_sim_only_rxdatak4                  (pipe_sim_only_rxdatak4),                  //   input,    width = 4,               .rxdatak4
    .pipe_sim_only_rxdatak5                  (pipe_sim_only_rxdatak5),                  //   input,    width = 4,               .rxdatak5
    .pipe_sim_only_rxdatak6                  (pipe_sim_only_rxdatak6),                  //   input,    width = 4,               .rxdatak6
    .pipe_sim_only_rxdatak7                  (pipe_sim_only_rxdatak7),                  //   input,    width = 4,               .rxdatak7
    .pipe_sim_only_rxdatak8                  (pipe_sim_only_rxdatak8),                  //   input,    width = 4,               .rxdatak8
    .pipe_sim_only_rxdatak9                  (pipe_sim_only_rxdatak9),                  //   input,    width = 4,               .rxdatak9
    .pipe_sim_only_rxdatak10                 (pipe_sim_only_rxdatak10),                 //   input,    width = 4,               .rxdatak10
    .pipe_sim_only_rxdatak11                 (pipe_sim_only_rxdatak11),                 //   input,    width = 4,               .rxdatak11
    .pipe_sim_only_rxdatak12                 (pipe_sim_only_rxdatak12),                 //   input,    width = 4,               .rxdatak12
    .pipe_sim_only_rxdatak13                 (pipe_sim_only_rxdatak13),                 //   input,    width = 4,               .rxdatak13
    .pipe_sim_only_rxdatak14                 (pipe_sim_only_rxdatak14),                 //   input,    width = 4,               .rxdatak14
    .pipe_sim_only_rxdatak15                 (pipe_sim_only_rxdatak15),                 //   input,    width = 4,               .rxdatak15
    .pipe_sim_only_phystatus0                (pipe_sim_only_phystatus0),                //   input,    width = 1,               .phystatus0
    .pipe_sim_only_phystatus1                (pipe_sim_only_phystatus1),                //   input,    width = 1,               .phystatus1
    .pipe_sim_only_phystatus2                (pipe_sim_only_phystatus2),                //   input,    width = 1,               .phystatus2
    .pipe_sim_only_phystatus3                (pipe_sim_only_phystatus3),                //   input,    width = 1,               .phystatus3
    .pipe_sim_only_phystatus4                (pipe_sim_only_phystatus4),                //   input,    width = 1,               .phystatus4
    .pipe_sim_only_phystatus5                (pipe_sim_only_phystatus5),                //   input,    width = 1,               .phystatus5
    .pipe_sim_only_phystatus6                (pipe_sim_only_phystatus6),                //   input,    width = 1,               .phystatus6
    .pipe_sim_only_phystatus7                (pipe_sim_only_phystatus7),                //   input,    width = 1,               .phystatus7
    .pipe_sim_only_phystatus8                (pipe_sim_only_phystatus8),                //   input,    width = 1,               .phystatus8
    .pipe_sim_only_phystatus9                (pipe_sim_only_phystatus9),                //   input,    width = 1,               .phystatus9
    .pipe_sim_only_phystatus10               (pipe_sim_only_phystatus10),               //   input,    width = 1,               .phystatus10
    .pipe_sim_only_phystatus11               (pipe_sim_only_phystatus11),               //   input,    width = 1,               .phystatus11
    .pipe_sim_only_phystatus12               (pipe_sim_only_phystatus12),               //   input,    width = 1,               .phystatus12
    .pipe_sim_only_phystatus13               (pipe_sim_only_phystatus13),               //   input,    width = 1,               .phystatus13
    .pipe_sim_only_phystatus14               (pipe_sim_only_phystatus14),               //   input,    width = 1,               .phystatus14
    .pipe_sim_only_phystatus15               (pipe_sim_only_phystatus15),               //   input,    width = 1,               .phystatus15
    .pipe_sim_only_rxvalid0                  (pipe_sim_only_rxvalid0),                  //   input,    width = 1,               .rxvalid0
    .pipe_sim_only_rxvalid1                  (pipe_sim_only_rxvalid1),                  //   input,    width = 1,               .rxvalid1
    .pipe_sim_only_rxvalid2                  (pipe_sim_only_rxvalid2),                  //   input,    width = 1,               .rxvalid2
    .pipe_sim_only_rxvalid3                  (pipe_sim_only_rxvalid3),                  //   input,    width = 1,               .rxvalid3
    .pipe_sim_only_rxvalid4                  (pipe_sim_only_rxvalid4),                  //   input,    width = 1,               .rxvalid4
    .pipe_sim_only_rxvalid5                  (pipe_sim_only_rxvalid5),                  //   input,    width = 1,               .rxvalid5
    .pipe_sim_only_rxvalid6                  (pipe_sim_only_rxvalid6),                  //   input,    width = 1,               .rxvalid6
    .pipe_sim_only_rxvalid7                  (pipe_sim_only_rxvalid7),                  //   input,    width = 1,               .rxvalid7
    .pipe_sim_only_rxvalid8                  (pipe_sim_only_rxvalid8),                  //   input,    width = 1,               .rxvalid8
    .pipe_sim_only_rxvalid9                  (pipe_sim_only_rxvalid9),                  //   input,    width = 1,               .rxvalid9
    .pipe_sim_only_rxvalid10                 (pipe_sim_only_rxvalid10),                 //   input,    width = 1,               .rxvalid10
    .pipe_sim_only_rxvalid11                 (pipe_sim_only_rxvalid11),                 //   input,    width = 1,               .rxvalid11
    .pipe_sim_only_rxvalid12                 (pipe_sim_only_rxvalid12),                 //   input,    width = 1,               .rxvalid12
    .pipe_sim_only_rxvalid13                 (pipe_sim_only_rxvalid13),                 //   input,    width = 1,               .rxvalid13
    .pipe_sim_only_rxvalid14                 (pipe_sim_only_rxvalid14),                 //   input,    width = 1,               .rxvalid14
    .pipe_sim_only_rxvalid15                 (pipe_sim_only_rxvalid15),                 //   input,    width = 1,               .rxvalid15
    .pipe_sim_only_rxstatus0                 (pipe_sim_only_rxstatus0),                 //   input,    width = 3,               .rxstatus0
    .pipe_sim_only_rxstatus1                 (pipe_sim_only_rxstatus1),                 //   input,    width = 3,               .rxstatus1
    .pipe_sim_only_rxstatus2                 (pipe_sim_only_rxstatus2),                 //   input,    width = 3,               .rxstatus2
    .pipe_sim_only_rxstatus3                 (pipe_sim_only_rxstatus3),                 //   input,    width = 3,               .rxstatus3
    .pipe_sim_only_rxstatus4                 (pipe_sim_only_rxstatus4),                 //   input,    width = 3,               .rxstatus4
    .pipe_sim_only_rxstatus5                 (pipe_sim_only_rxstatus5),                 //   input,    width = 3,               .rxstatus5
    .pipe_sim_only_rxstatus6                 (pipe_sim_only_rxstatus6),                 //   input,    width = 3,               .rxstatus6
    .pipe_sim_only_rxstatus7                 (pipe_sim_only_rxstatus7),                 //   input,    width = 3,               .rxstatus7
    .pipe_sim_only_rxstatus8                 (pipe_sim_only_rxstatus8),                 //   input,    width = 3,               .rxstatus8
    .pipe_sim_only_rxstatus9                 (pipe_sim_only_rxstatus9),                 //   input,    width = 3,               .rxstatus9
    .pipe_sim_only_rxstatus10                (pipe_sim_only_rxstatus10),                //   input,    width = 3,               .rxstatus10
    .pipe_sim_only_rxstatus11                (pipe_sim_only_rxstatus11),                //   input,    width = 3,               .rxstatus11
    .pipe_sim_only_rxstatus12                (pipe_sim_only_rxstatus12),                //   input,    width = 3,               .rxstatus12
    .pipe_sim_only_rxstatus13                (pipe_sim_only_rxstatus13),                //   input,    width = 3,               .rxstatus13
    .pipe_sim_only_rxstatus14                (pipe_sim_only_rxstatus14),                //   input,    width = 3,               .rxstatus14
    .pipe_sim_only_rxstatus15                (pipe_sim_only_rxstatus15),                //   input,    width = 3,               .rxstatus15
    .pipe_sim_only_rxelecidle0               (pipe_sim_only_rxelecidle0),               //   input,    width = 1,               .rxelecidle0
    .pipe_sim_only_rxelecidle1               (pipe_sim_only_rxelecidle1),               //   input,    width = 1,               .rxelecidle1
    .pipe_sim_only_rxelecidle2               (pipe_sim_only_rxelecidle2),               //   input,    width = 1,               .rxelecidle2
    .pipe_sim_only_rxelecidle3               (pipe_sim_only_rxelecidle3),               //   input,    width = 1,               .rxelecidle3
    .pipe_sim_only_rxelecidle4               (pipe_sim_only_rxelecidle4),               //   input,    width = 1,               .rxelecidle4
    .pipe_sim_only_rxelecidle5               (pipe_sim_only_rxelecidle5),               //   input,    width = 1,               .rxelecidle5
    .pipe_sim_only_rxelecidle6               (pipe_sim_only_rxelecidle6),               //   input,    width = 1,               .rxelecidle6
    .pipe_sim_only_rxelecidle7               (pipe_sim_only_rxelecidle7),               //   input,    width = 1,               .rxelecidle7
    .pipe_sim_only_rxelecidle8               (pipe_sim_only_rxelecidle8),               //   input,    width = 1,               .rxelecidle8
    .pipe_sim_only_rxelecidle9               (pipe_sim_only_rxelecidle9),               //   input,    width = 1,               .rxelecidle9
    .pipe_sim_only_rxelecidle10              (pipe_sim_only_rxelecidle10),              //   input,    width = 1,               .rxelecidle10
    .pipe_sim_only_rxelecidle11              (pipe_sim_only_rxelecidle11),              //   input,    width = 1,               .rxelecidle11
    .pipe_sim_only_rxelecidle12              (pipe_sim_only_rxelecidle12),              //   input,    width = 1,               .rxelecidle12
    .pipe_sim_only_rxelecidle13              (pipe_sim_only_rxelecidle13),              //   input,    width = 1,               .rxelecidle13
    .pipe_sim_only_rxelecidle14              (pipe_sim_only_rxelecidle14),              //   input,    width = 1,               .rxelecidle14
    .pipe_sim_only_rxelecidle15              (pipe_sim_only_rxelecidle15),              //   input,    width = 1,               .rxelecidle15
    .pipe_sim_only_rxsynchd0                 (pipe_sim_only_rxsynchd0),                 //   input,    width = 2,               .rxsynchd0
    .pipe_sim_only_rxsynchd1                 (pipe_sim_only_rxsynchd1),                 //   input,    width = 2,               .rxsynchd1
    .pipe_sim_only_rxsynchd2                 (pipe_sim_only_rxsynchd2),                 //   input,    width = 2,               .rxsynchd2
    .pipe_sim_only_rxsynchd3                 (pipe_sim_only_rxsynchd3),                 //   input,    width = 2,               .rxsynchd3
    .pipe_sim_only_rxsynchd4                 (pipe_sim_only_rxsynchd4),                 //   input,    width = 2,               .rxsynchd4
    .pipe_sim_only_rxsynchd5                 (pipe_sim_only_rxsynchd5),                 //   input,    width = 2,               .rxsynchd5
    .pipe_sim_only_rxsynchd6                 (pipe_sim_only_rxsynchd6),                 //   input,    width = 2,               .rxsynchd6
    .pipe_sim_only_rxsynchd7                 (pipe_sim_only_rxsynchd7),                 //   input,    width = 2,               .rxsynchd7
    .pipe_sim_only_rxsynchd8                 (pipe_sim_only_rxsynchd8),                 //   input,    width = 2,               .rxsynchd8
    .pipe_sim_only_rxsynchd9                 (pipe_sim_only_rxsynchd9),                 //   input,    width = 2,               .rxsynchd9
    .pipe_sim_only_rxsynchd10                (pipe_sim_only_rxsynchd10),                //   input,    width = 2,               .rxsynchd10
    .pipe_sim_only_rxsynchd11                (pipe_sim_only_rxsynchd11),                //   input,    width = 2,               .rxsynchd11
    .pipe_sim_only_rxsynchd12                (pipe_sim_only_rxsynchd12),                //   input,    width = 2,               .rxsynchd12
    .pipe_sim_only_rxsynchd13                (pipe_sim_only_rxsynchd13),                //   input,    width = 2,               .rxsynchd13
    .pipe_sim_only_rxsynchd14                (pipe_sim_only_rxsynchd14),                //   input,    width = 2,               .rxsynchd14
    .pipe_sim_only_rxsynchd15                (pipe_sim_only_rxsynchd15),                //   input,    width = 2,               .rxsynchd15
    .pipe_sim_only_rxblkst0                  (pipe_sim_only_rxblkst0),                  //   input,    width = 1,               .rxblkst0
    .pipe_sim_only_rxblkst1                  (pipe_sim_only_rxblkst1),                  //   input,    width = 1,               .rxblkst1
    .pipe_sim_only_rxblkst2                  (pipe_sim_only_rxblkst2),                  //   input,    width = 1,               .rxblkst2
    .pipe_sim_only_rxblkst3                  (pipe_sim_only_rxblkst3),                  //   input,    width = 1,               .rxblkst3
    .pipe_sim_only_rxblkst4                  (pipe_sim_only_rxblkst4),                  //   input,    width = 1,               .rxblkst4
    .pipe_sim_only_rxblkst5                  (pipe_sim_only_rxblkst5),                  //   input,    width = 1,               .rxblkst5
    .pipe_sim_only_rxblkst6                  (pipe_sim_only_rxblkst6),                  //   input,    width = 1,               .rxblkst6
    .pipe_sim_only_rxblkst7                  (pipe_sim_only_rxblkst7),                  //   input,    width = 1,               .rxblkst7
    .pipe_sim_only_rxblkst8                  (pipe_sim_only_rxblkst8),                  //   input,    width = 1,               .rxblkst8
    .pipe_sim_only_rxblkst9                  (pipe_sim_only_rxblkst9),                  //   input,    width = 1,               .rxblkst9
    .pipe_sim_only_rxblkst10                 (pipe_sim_only_rxblkst10),                 //   input,    width = 1,               .rxblkst10
    .pipe_sim_only_rxblkst11                 (pipe_sim_only_rxblkst11),                 //   input,    width = 1,               .rxblkst11
    .pipe_sim_only_rxblkst12                 (pipe_sim_only_rxblkst12),                 //   input,    width = 1,               .rxblkst12
    .pipe_sim_only_rxblkst13                 (pipe_sim_only_rxblkst13),                 //   input,    width = 1,               .rxblkst13
    .pipe_sim_only_rxblkst14                 (pipe_sim_only_rxblkst14),                 //   input,    width = 1,               .rxblkst14
    .pipe_sim_only_rxblkst15                 (pipe_sim_only_rxblkst15),                 //   input,    width = 1,               .rxblkst15
    .pipe_sim_only_rxdataskip0               (pipe_sim_only_rxdataskip0),               //   input,    width = 1,               .rxdataskip0
    .pipe_sim_only_rxdataskip1               (pipe_sim_only_rxdataskip1),               //   input,    width = 1,               .rxdataskip1
    .pipe_sim_only_rxdataskip2               (pipe_sim_only_rxdataskip2),               //   input,    width = 1,               .rxdataskip2
    .pipe_sim_only_rxdataskip3               (pipe_sim_only_rxdataskip3),               //   input,    width = 1,               .rxdataskip3
    .pipe_sim_only_rxdataskip4               (pipe_sim_only_rxdataskip4),               //   input,    width = 1,               .rxdataskip4
    .pipe_sim_only_rxdataskip5               (pipe_sim_only_rxdataskip5),               //   input,    width = 1,               .rxdataskip5
    .pipe_sim_only_rxdataskip6               (pipe_sim_only_rxdataskip6),               //   input,    width = 1,               .rxdataskip6
    .pipe_sim_only_rxdataskip7               (pipe_sim_only_rxdataskip7),               //   input,    width = 1,               .rxdataskip7
    .pipe_sim_only_rxdataskip8               (pipe_sim_only_rxdataskip8),               //   input,    width = 1,               .rxdataskip8
    .pipe_sim_only_rxdataskip9               (pipe_sim_only_rxdataskip9),               //   input,    width = 1,               .rxdataskip9
    .pipe_sim_only_rxdataskip10              (pipe_sim_only_rxdataskip10),              //   input,    width = 1,               .rxdataskip10
    .pipe_sim_only_rxdataskip11              (pipe_sim_only_rxdataskip11),              //   input,    width = 1,               .rxdataskip11
    .pipe_sim_only_rxdataskip12              (pipe_sim_only_rxdataskip12),              //   input,    width = 1,               .rxdataskip12
    .pipe_sim_only_rxdataskip13              (pipe_sim_only_rxdataskip13),              //   input,    width = 1,               .rxdataskip13
    .pipe_sim_only_rxdataskip14              (pipe_sim_only_rxdataskip14),              //   input,    width = 1,               .rxdataskip14
    .pipe_sim_only_rxdataskip15              (pipe_sim_only_rxdataskip15),              //   input,    width = 1,               .rxdataskip15
    .pipe_sim_only_dirfeedback0              (pipe_sim_only_dirfeedback0),              //   input,    width = 6,               .dirfeedback0
    .pipe_sim_only_dirfeedback1              (pipe_sim_only_dirfeedback1),              //   input,    width = 6,               .dirfeedback1
    .pipe_sim_only_dirfeedback2              (pipe_sim_only_dirfeedback2),              //   input,    width = 6,               .dirfeedback2
    .pipe_sim_only_dirfeedback3              (pipe_sim_only_dirfeedback3),              //   input,    width = 6,               .dirfeedback3
    .pipe_sim_only_dirfeedback4              (pipe_sim_only_dirfeedback4),              //   input,    width = 6,               .dirfeedback4
    .pipe_sim_only_dirfeedback5              (pipe_sim_only_dirfeedback5),              //   input,    width = 6,               .dirfeedback5
    .pipe_sim_only_dirfeedback6              (pipe_sim_only_dirfeedback6),              //   input,    width = 6,               .dirfeedback6
    .pipe_sim_only_dirfeedback7              (pipe_sim_only_dirfeedback7),              //   input,    width = 6,               .dirfeedback7
    .pipe_sim_only_dirfeedback8              (pipe_sim_only_dirfeedback8),              //   input,    width = 6,               .dirfeedback8
    .pipe_sim_only_dirfeedback9              (pipe_sim_only_dirfeedback9),              //   input,    width = 6,               .dirfeedback9
    .pipe_sim_only_dirfeedback10             (pipe_sim_only_dirfeedback10),             //   input,    width = 6,               .dirfeedback10
    .pipe_sim_only_dirfeedback11             (pipe_sim_only_dirfeedback11),             //   input,    width = 6,               .dirfeedback11
    .pipe_sim_only_dirfeedback12             (pipe_sim_only_dirfeedback12),             //   input,    width = 6,               .dirfeedback12
    .pipe_sim_only_dirfeedback13             (pipe_sim_only_dirfeedback13),             //   input,    width = 6,               .dirfeedback13
    .pipe_sim_only_dirfeedback14             (pipe_sim_only_dirfeedback14),             //   input,    width = 6,               .dirfeedback14
    .pipe_sim_only_dirfeedback15             (pipe_sim_only_dirfeedback15),             //   input,    width = 6,               .dirfeedback15
    .pipe_sim_only_sim_pipe_mask_tx_pll_lock (pipe_sim_only_sim_pipe_mask_tx_pll_lock), //   input,    width = 1,               .sim_pipe_mask_tx_pll_lock
    .xcvr_rx_in0                             (xcvr_rx_in0),                             //   input,    width = 1,           xcvr.rx_in0
    .xcvr_rx_in1                             (xcvr_rx_in1),                             //   input,    width = 1,               .rx_in1
    .xcvr_rx_in2                             (xcvr_rx_in2),                             //   input,    width = 1,               .rx_in2
    .xcvr_rx_in3                             (xcvr_rx_in3),                             //   input,    width = 1,               .rx_in3
    .xcvr_rx_in4                             (xcvr_rx_in4),                             //   input,    width = 1,               .rx_in4
    .xcvr_rx_in5                             (xcvr_rx_in5),                             //   input,    width = 1,               .rx_in5
    .xcvr_rx_in6                             (xcvr_rx_in6),                             //   input,    width = 1,               .rx_in6
    .xcvr_rx_in7                             (xcvr_rx_in7),                             //   input,    width = 1,               .rx_in7
    .xcvr_rx_in8                             (xcvr_rx_in8),                             //   input,    width = 1,               .rx_in8
    .xcvr_rx_in9                             (xcvr_rx_in9),                             //   input,    width = 1,               .rx_in9
    .xcvr_rx_in10                            (xcvr_rx_in10),                            //   input,    width = 1,               .rx_in10
    .xcvr_rx_in11                            (xcvr_rx_in11),                            //   input,    width = 1,               .rx_in11
    .xcvr_rx_in12                            (xcvr_rx_in12),                            //   input,    width = 1,               .rx_in12
    .xcvr_rx_in13                            (xcvr_rx_in13),                            //   input,    width = 1,               .rx_in13
    .xcvr_rx_in14                            (xcvr_rx_in14),                            //   input,    width = 1,               .rx_in14
    .xcvr_rx_in15                            (xcvr_rx_in15),                            //   input,    width = 1,               .rx_in15
    .xcvr_tx_out0                            (xcvr_tx_out0),                            //  output,    width = 1,               .tx_out0
    .xcvr_tx_out1                            (xcvr_tx_out1),                            //  output,    width = 1,               .tx_out1
    .xcvr_tx_out2                            (xcvr_tx_out2),                            //  output,    width = 1,               .tx_out2
    .xcvr_tx_out3                            (xcvr_tx_out3),                            //  output,    width = 1,               .tx_out3
    .xcvr_tx_out4                            (xcvr_tx_out4),                            //  output,    width = 1,               .tx_out4
    .xcvr_tx_out5                            (xcvr_tx_out5),                            //  output,    width = 1,               .tx_out5
    .xcvr_tx_out6                            (xcvr_tx_out6),                            //  output,    width = 1,               .tx_out6
    .xcvr_tx_out7                            (xcvr_tx_out7),                            //  output,    width = 1,               .tx_out7
    .xcvr_tx_out8                            (xcvr_tx_out8),                            //  output,    width = 1,               .tx_out8
    .xcvr_tx_out9                            (xcvr_tx_out9),                            //  output,    width = 1,               .tx_out9
    .xcvr_tx_out10                           (xcvr_tx_out10),                           //  output,    width = 1,               .tx_out10
    .xcvr_tx_out11                           (xcvr_tx_out11),                           //  output,    width = 1,               .tx_out11
    .xcvr_tx_out12                           (xcvr_tx_out12),                           //  output,    width = 1,               .tx_out12
    .xcvr_tx_out13                           (xcvr_tx_out13),                           //  output,    width = 1,               .tx_out13
    .xcvr_tx_out14                           (xcvr_tx_out14),                           //  output,    width = 1,               .tx_out14
    .xcvr_tx_out15                           (xcvr_tx_out15),                           //  output,    width = 1,               .tx_out15
    .generic_component_0_coreclkout_hip_clk          (pcie_clk),          //  output,    width = 1,      generic_component_0_coreclkout_hip.clk
    .generic_component_0_app_nreset_status_1_reset_n (pcie_reset_n), //  output,    width = 1, generic_component_0_app_nreset_status_1.reset_n
    .mm_bridge_0_m0_waitrequest              (1'b0),              //   input,    width = 1, mm_bridge_0_m0.waitrequest
    .mm_bridge_0_m0_readdata                 (readdata_0),                 //   input,  width = 512,               .readdata
    .mm_bridge_0_m0_readdatavalid            (readdatavalid_0),            //   input,    width = 1,               .readdatavalid
    .mm_bridge_0_m0_burstcount               (),               //  output,    width = 1,               .burstcount
    .mm_bridge_0_m0_writedata                (writedata_0),                //  output,  width = 512,               .writedata
    .mm_bridge_0_m0_address                  (address_0),                  //  output,    width = 15,               .address
    .mm_bridge_0_m0_write                    (write_0),                    //  output,    width = 1,               .write
    .mm_bridge_0_m0_read                     (read_0),                     //  output,    width = 1,               .read
    .mm_bridge_0_m0_byteenable               (byteenable_0),               //  output,   width = 64,               .byteenable
    .mm_bridge_0_m0_debugaccess              (),              //  output,    width = 1,               .debugaccess
    .mm_bridge_1_m0_waitrequest              (1'b0),              //   input,    width = 1, mm_bridge_1_m0.waitrequest
    .mm_bridge_1_m0_readdata                 (readdata_1),                 //   input,  width = 512,               .readdata
    .mm_bridge_1_m0_readdatavalid            (readdatavalid_1),            //   input,    width = 1,               .readdatavalid
    .mm_bridge_1_m0_burstcount               (),               //  output,    width = 1,               .burstcount
    .mm_bridge_1_m0_writedata                (writedata_1),                //  output,  width = 512,               .writedata
    .mm_bridge_1_m0_address                  (address_1),                  //  output,    width = 15,               .address
    .mm_bridge_1_m0_write                    (write_1),                    //  output,    width = 1,               .write
    .mm_bridge_1_m0_read                     (read_1),                     //  output,    width = 1,               .read
    .mm_bridge_1_m0_byteenable               (byteenable_1),               //  output,   width = 64,               .byteenable
    .mm_bridge_1_m0_debugaccess              ()               //  output,    width = 1,               .debugaccess
);
`endif

endmodule
