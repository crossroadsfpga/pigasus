//Pace pkt based on almost_full signal
module pkt_almost_full (
        input  logic         clk,                  
        input  logic         rst,                  
        input  logic [511:0] in_data,
        input  logic         in_sop,
        input  logic         in_eop,
        input  logic [5:0]   in_empty,
        input  logic         in_valid,
	output logic         in_ready,

        output logic [511:0] out_data,
        output logic         out_sop,
        output logic         out_eop,
        output logic [5:0]   out_empty,
        output logic         out_valid,
        input  logic         out_almost_full
);

typedef enum{
    IDLE,
    SEND
} state_t;

state_t state;

assign in_ready = (state==SEND);

always@(posedge clk)begin
    if(rst)begin
        state <= IDLE;
	out_sop <= 0;
	out_eop <= 0;
	out_empty <= 0;
	out_valid <= 0;
    end else begin
        case(state)
            IDLE:begin
	        out_sop <= 0;
	        out_eop <= 0;
	        out_empty <= 0;
	        out_valid <= 0;
                if(!out_almost_full)begin
                    state <= SEND;
                end
            end
            SEND:begin
		out_sop <= in_sop;
		out_eop <= in_eop;
		out_valid <= in_valid;
		out_empty <= in_empty;
                if(in_valid & in_eop)begin
		    if(out_almost_full)begin
                        state <= IDLE;
		    end
                end
            end
        endcase
    end
    out_data  <= in_data;
end

endmodule
