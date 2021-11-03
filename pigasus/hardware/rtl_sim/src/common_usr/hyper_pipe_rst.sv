// From Intel s10_hp_hb.pdf
module hyper_pipe_rst #(
    parameter WIDTH = 1,
    parameter NUM_PIPES = 1)
(
    input   logic               clk,
    input   logic               rst,
    input   logic [WIDTH-1:0]   din,
    output  logic [WIDTH-1:0]   dout
);

    reg [WIDTH-1:0] hp [NUM_PIPES-1:0];
    genvar i;
    generate
        if (NUM_PIPES == 0) begin
            assign dout = din;
        end
        else begin
            always @(posedge clk) begin
                if (rst) begin
                    hp[0] <= 0;
                end
                else begin
                    hp[0] <= din;
                end
            end

            for (i=1; i < NUM_PIPES; i++) begin : hregs
                always @(posedge clk) begin
                    if (rst) begin
                        hp[i] <= 0;
                    end
                    else begin
                        hp[i] <= hp[i-1];
                    end
                end
            end
            assign dout = hp[NUM_PIPES-1];
        end
    endgenerate
endmodule
