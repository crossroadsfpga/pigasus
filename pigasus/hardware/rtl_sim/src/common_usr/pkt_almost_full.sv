//Pace pkt based on almost_full signal
//If downstream is almost full the upstream will stop at pkt boundary.
//Insert one cycle gap between each output pkt
module pkt_almost_full #(
        parameter DWIDTH = 512,
        parameter EWIDTH = 6,
        parameter NUM_PIPES = 0
    )(
    input  logic              clk,                  
    input  logic              rst,                  
    input  logic [DWIDTH-1:0] in_data,
    input  logic              in_sop,
    input  logic              in_eop,
    input  logic [EWIDTH-1:0] in_empty,
    input  logic              in_valid,
    output logic              in_ready,

    output logic [DWIDTH-1:0] out_data,
    output logic              out_sop,
    output logic              out_eop,
    output logic [EWIDTH-1:0] out_empty,
    output logic              out_valid,
    input  logic              out_almost_full
);

typedef enum{
    IDLE,
    SEND
} state_t;

state_t state;
logic [DWIDTH-1:0] temp_data;
logic              temp_sop;
logic              temp_eop;
logic [EWIDTH-1:0] temp_empty;
logic              temp_valid;

assign in_ready = (state==SEND);

always@(posedge clk)begin
    if(rst)begin
        state <= IDLE;
        temp_sop <= 0;
        temp_eop <= 0;
        temp_empty <= 0;
        temp_valid <= 0;
    end else begin
        case(state)
            IDLE:begin
                temp_sop <= 0;
                temp_eop <= 0;
                temp_empty <= 0;
                temp_valid <= 0;
                if(!out_almost_full)begin
                    state <= SEND;
                end
            end
            SEND:begin
                temp_sop <= in_sop;
                temp_eop <= in_eop;
                temp_valid <= in_valid;
                temp_empty <= in_empty;
                if(in_valid & in_eop)begin
                    //if(out_almost_full)begin
                    //    state <= IDLE;
                    //end
                    state <= IDLE;
                end
            end
        endcase
    end
    temp_data  <= in_data;
end

hyper_pipe #(
    .WIDTH(1),
    .NUM_PIPES(NUM_PIPES)
) hyper_pipe_valid(
    .clk(clk),
    .din(temp_valid),
    .dout(out_valid)
);

hyper_pipe #(
    .WIDTH(1),
    .NUM_PIPES(NUM_PIPES)
) hyper_pipe_sop(
    .clk(clk),
    .din(temp_sop),
    .dout(out_sop)
);

hyper_pipe #(
    .WIDTH(1),
    .NUM_PIPES(NUM_PIPES)
) hyper_pipe_eop(
    .clk(clk),
    .din(temp_eop),
    .dout(out_eop)
);

hyper_pipe #(
    .WIDTH(EWIDTH),
    .NUM_PIPES(NUM_PIPES)
) hyper_pipe_empty(
    .clk(clk),
    .din(temp_empty),
    .dout(out_empty)
);

hyper_pipe #(
    .WIDTH(DWIDTH),
    .NUM_PIPES(NUM_PIPES)
) hyper_pipe_data(
    .clk(clk),
    .din(temp_data),
    .dout(out_data)
);

endmodule
