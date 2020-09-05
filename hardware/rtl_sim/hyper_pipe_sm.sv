`timescale 1 ps / 1 ps
`include "./struct_s.sv"

module hyper_pipe_sm (
    // Clk & rst
    input  logic         front_clk,
    input  logic         front_rst,
    input  logic         back_clk,
    input  logic         back_rst,
    input  logic         clk_datamover,
    input  logic         rst_datamover,

    input  logic         in_sop,
    input  logic         in_eop,
    input  logic [511:0] in_data,
    input  logic [5:0]   in_empty,
    input  logic         in_valid,
    input  logic         in_almost_full,
    input  logic         in_meta_valid,
    input  metadata_t    in_meta_data,
    input  metadata_t    out_meta_data,
    input  logic         out_meta_valid,
    input  logic         out_match_valid,
    input  logic [511:0] out_match_data,
    input  logic         out_match_last,
    input  logic         out_match_almost_full,

    output  logic         reg_in_sop,
    output  logic         reg_in_eop,
    output  logic [511:0] reg_in_data,
    output  logic [5:0]   reg_in_empty,
    output  logic         reg_in_valid,
    output  logic         reg_in_almost_full,
    output  logic         reg_in_meta_valid,
    output  metadata_t    reg_in_meta_data,
    output  metadata_t    reg_out_meta_data,
    output  logic         reg_out_meta_valid,
    output  logic         reg_out_match_valid,
    output  logic [511:0] reg_out_match_data,
    output  logic         reg_out_match_last,
    output  logic         reg_out_match_almost_full
);

localparam NUM_PIPES = 1;

// Eth in
hyper_pipe #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_in_sop (
    .clk(clk_datamover),
    .din(in_sop),
    .dout(reg_in_sop)
);
hyper_pipe #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_in_eop (
    .clk(clk_datamover),
    .din(in_eop),
    .dout(reg_in_eop)
);
hyper_pipe #(
    .WIDTH (512),
    .NUM_PIPES(NUM_PIPES)
) hp_in_data (
    .clk(clk_datamover),
    .din(in_data),
    .dout(reg_in_data)
);
hyper_pipe #(
    .WIDTH (6),
    .NUM_PIPES(NUM_PIPES)
) hp_in_empty (
    .clk(clk_datamover),
    .din(in_empty),
    .dout(reg_in_empty)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_in_valid (
    .clk(clk_datamover),
    .rst(rst_datamover),
    .din(in_valid),
    .dout(reg_in_valid)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_in_almost_full (
    .clk(clk_datamover),
    .rst(rst_datamover),
    .din(in_almost_full),
    .dout(reg_in_almost_full)
);

hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_in_meta_valid (
    .clk(clk_datamover),
    .rst(rst_datamover),
    .din(in_meta_valid),
    .dout(reg_in_meta_valid)
);
hyper_pipe #(
    .WIDTH (META_WIDTH),
    .NUM_PIPES(NUM_PIPES)
) hp_in_meta_data (
    .clk(clk_datamover),
    .din(in_meta_data),
    .dout(reg_in_meta_data)
);

hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_out_meta_valid (
    .clk(front_clk),
    .rst(front_rst),
    .din(out_meta_valid),
    .dout(reg_out_meta_valid)
);
hyper_pipe #(
    .WIDTH (META_WIDTH),
    .NUM_PIPES(NUM_PIPES)
) hp_out_meta_data (
    .clk(front_clk),
    .din(out_meta_data),
    .dout(reg_out_meta_data)
);

hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_out_match_valid (
    .clk(back_clk),
    .rst(back_rst),
    .din(out_match_valid),
    .dout(reg_out_match_valid)
);
hyper_pipe #(
    .WIDTH (512),
    .NUM_PIPES(NUM_PIPES)
) hp_out_match_data (
    .clk(back_clk),
    .din(out_match_data),
    .dout(reg_out_match_data)
);
hyper_pipe #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_out_match_last (
    .clk(back_clk),
    .din(out_match_last),
    .dout(reg_out_match_last)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_out_match_almost_full (
    .clk(back_clk),
    .rst(back_rst),
    .din(out_match_almost_full),
    .dout(reg_out_match_almost_full)
);

endmodule
