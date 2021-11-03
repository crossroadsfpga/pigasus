`timescale 1 ps / 1 ps

module pc_loopback (
    input                arst,
    input                clk_rx,
    input                clk_tx,
    input                rx_valid,
    input                rx_sop,
    input                rx_eop,
    input [5:0]          rx_empty,
    output logic         rx_ready,
    input [511:0]        rx_data,
    output logic         tx_valid,
    output logic         tx_sop,
    output logic         tx_eop,
    output logic [5:0]   tx_empty,
    output logic [511:0] tx_data,
    input                tx_ready
);
    localparam      THRESHOLD = 29;

    logic           rx_valid_int;
    logic           rx_almost_full;

    logic           tx_valid_int;
    logic           tx_sop_int;
    logic           tx_eop_int;
    logic   [5:0]   tx_empty_int;
    logic   [511:0] tx_data_int;

    logic           loopback_sop;
    logic           loopback_eop;
    logic   [5:0]   loopback_empty;
    logic   [511:0] loopback_data;
    logic           loopback_valid;

    logic           loopback_sop_r2;
    logic           loopback_eop_r2;
    logic   [5:0]   loopback_empty_r2;
    logic   [511:0] loopback_data_r2;
    logic           loopback_valid_r2;

    //the buffer size is 2^5 = 32. use one more bit.
    logic   [5:0]   remaining;    
    logic   [4:0]   rx_cnt;    
    logic   [4:0]   tx_cnt;    
    logic   [4:0]   tx_cnt_sync;    
    logic           rst_rx;
    logic           rst_tx;
    
    //Back pressure
    always_ff @(posedge clk_tx) begin
        if(rst_tx)begin
            tx_cnt <= 0;
        end else begin
            if(tx_ready & tx_valid)begin
                tx_cnt <= tx_cnt + 1;
            end
        end
    end

    always_ff @(posedge clk_rx) begin
        if(rst_rx)begin
            rx_cnt <= 0;
            remaining <= 0;
            rx_almost_full <= 0;
        end else begin
            if(rx_valid_int)begin
                rx_cnt <= rx_cnt + 1;
            end

            if (rx_cnt >= tx_cnt_sync)begin
                remaining <= rx_cnt - tx_cnt_sync;
            end else begin
                remaining <= rx_cnt + 32 - tx_cnt_sync;
            end 

            if(remaining > THRESHOLD)begin
                rx_almost_full <= 1;
            end else begin
                rx_almost_full <= 0;
            end
        end
    end
    assign rx_ready = !rx_almost_full;
    assign rx_valid_int = rx_valid & rx_ready;

    always_ff @(posedge clk_tx) begin
        tx_valid_int    <= loopback_valid_r2;
        tx_sop_int      <= loopback_sop_r2;
        tx_eop_int      <= loopback_eop_r2;
        tx_empty_int    <= loopback_empty_r2;
        tx_data_int     <= loopback_data_r2;
    end

    alt_ehipc2_reset_synchronizer reset_sync_tx (
        .clk       (clk_tx),
        .aclr      (arst),
        .aclr_sync (rst_tx)
    );
    alt_ehipc2_reset_synchronizer reset_sync_rx (
        .clk       (clk_rx),
        .aclr      (arst),
        .aclr_sync (rst_rx)
    );

    alt_e100s10_pointer_synchronizer #(
        .WIDTH  (5)
    ) ps (
        .clk_in     (clk_tx),
        .ptr_in     (tx_cnt),
        .clk_out    (clk_rx),
        .ptr_out    (tx_cnt_sync)
    );

    alt_e100s10_loopback_client #(
        .SIM_EMULATE    (0)
    ) mlb (
        .i_arst     (arst),

        .i_clk_w    (clk_rx),
        .i_sop      (rx_sop),
        .i_eop      (rx_eop),
        .i_valid    (rx_valid_int),
        .i_empty    (rx_empty),
        .i_data     (rx_data),

        .i_clk_r    (clk_tx),
        .o_sop      (loopback_sop),
        .o_eop      (loopback_eop),
        .o_valid    (loopback_valid),
        .o_empty    (loopback_empty),
        .o_data     (loopback_data),
        .i_ready    (tx_ready)
    );

    alt_e100s10_ready_skid #(
        .WIDTH  (1+1+1+6+512)  // sop, eop, empty, data
    ) mlb_skid (
        .i_clk      (clk_tx),
        .i_data     ({loopback_valid,loopback_sop, loopback_eop, loopback_empty, loopback_data}),
        .o_ready    (),
        .o_data     ({loopback_valid_r2,loopback_sop_r2, loopback_eop_r2, loopback_empty_r2, loopback_data_r2}),
        .i_ready    (tx_ready)
    );

    alt_e100s10_ready_skid #(
        .WIDTH  (1+1+1+6+512)  // sop, eop, empty, data
    ) output_skid (
        .i_clk      (clk_tx),
        .i_data     ({tx_valid_int,tx_sop_int, tx_eop_int, tx_empty_int, tx_data_int}),
        .o_ready    (),
        .o_data     ({tx_valid, tx_sop, tx_eop, tx_empty, tx_data}),
        .i_ready    (tx_ready)
    );

endmodule

