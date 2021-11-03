`include "./src/struct_s.sv"
`timescale 1 ps / 1 ps
//If there are potential rule matches, uses channel 1.
//Else uses channel 0.
module traffic_manager (
    // Clk & rst
    input   logic         clk,
    input   logic         rst,

    // In Pkt data
    input   logic [511:0]   in_pkt_data,
    input   logic           in_pkt_valid,
    input   logic           in_pkt_sop,
    input   logic           in_pkt_eop,
    input   logic [5:0]     in_pkt_empty,
    output  logic           in_pkt_ready,

    // In Meta data
    input   metadata_t      in_meta_data,
    input   logic           in_meta_valid,
    output  logic           in_meta_ready,

    // In User data
    input   logic [511:0]   in_usr_data,
    input   logic           in_usr_valid,
    input   logic           in_usr_sop,
    input   logic           in_usr_eop,
    input   logic [5:0]     in_usr_empty,
    output  logic           in_usr_ready,

    // Out Pkt data
    output  logic [511:0]   out_pkt_data,
    output  logic           out_pkt_valid,
    output  logic           out_pkt_sop,
    output  logic           out_pkt_eop,
    output  logic [5:0]     out_pkt_empty,
    input   logic           out_pkt_ready,
    input   logic           out_pkt_almost_full,
    output  logic [1:0]     out_pkt_channel,

    // Out Meta data
    output  metadata_t      out_meta_data,
    output  logic           out_meta_valid,
    input   logic           out_meta_ready,
    input   logic           out_meta_almost_full,
    output  logic           out_meta_channel,

    // Out User data
    output  logic [511:0]   out_usr_data,
    output  logic           out_usr_valid,
    output  logic           out_usr_sop,
    output  logic           out_usr_eop,
    output  logic [5:0]     out_usr_empty,
    input   logic           out_usr_ready,
    input   logic           out_usr_almost_full,
    output  logic [1:0]     out_usr_channel
);

typedef enum {
    IDLE,
    RULE,
    NO_CHECK,
    CHECK
} state_t;
state_t state;
state_t next_state;

logic not_almost_full;
logic rule_done;
logic pkt_done;
logic rule_done_r;
logic pkt_done_r;
logic transit;
logic no_check_done;
logic check_done;
metadata_t in_meta_data_r;

assign not_almost_full = !out_pkt_almost_full & !out_meta_almost_full & !out_usr_almost_full;

assign transit = not_almost_full & in_meta_valid & in_usr_valid;

//state transition
always@(*)begin
    next_state = state;
    case(state)
        IDLE:begin
            if(transit)begin
                next_state = in_usr_eop ? NO_CHECK : CHECK;
            end else begin
                next_state = IDLE;
            end
        end
        NO_CHECK:begin
            if(no_check_done)begin
                //if(transit)begin
                //    next_state = in_usr_eop ? NO_CHECK : CHECK;
                //end else begin
                //    next_state = IDLE;
                //end
                next_state = IDLE;
            end else begin
                next_state = NO_CHECK;
            end
        end
        CHECK:begin
            if(check_done)begin
                //if(transit)begin
                //    next_state = in_usr_eop ? NO_CHECK : CHECK;
                //end else begin
                //    next_state = IDLE;
                //end
                next_state = IDLE;
            end else begin
                next_state = CHECK;
            end
        end
    endcase
end

always@(posedge clk)begin
    if(rst)begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

//ready signal, order matters
always@(*)begin
    in_usr_ready = 1'b0;
    in_pkt_ready = 1'b0;

    if(state == NO_CHECK)begin
        in_pkt_ready = 1'b1;
        //only deque one flit from rule queue
        in_usr_ready = in_pkt_eop & in_pkt_valid;
    end else if (state == CHECK)begin
        in_pkt_ready = !pkt_done_r;
        in_usr_ready = !rule_done_r;
    end

    pkt_done = (state==CHECK) & in_pkt_eop & in_pkt_valid & in_pkt_ready;
    rule_done = (state==CHECK) & in_usr_eop & in_usr_valid & in_usr_ready;
    check_done = (state==CHECK) & (rule_done | rule_done_r) & (pkt_done | pkt_done_r);
    no_check_done = (state==NO_CHECK) & in_pkt_eop & in_pkt_valid & in_pkt_ready;

    in_meta_ready = check_done | no_check_done;
end

always@(posedge clk)begin
    if(rst)begin
        pkt_done_r <= 1'b0;
        rule_done_r <= 1'b0;
    end else begin
        if(check_done)begin
            pkt_done_r <= 1'b0;
            rule_done_r <= 1'b0;
        end else begin
            if(pkt_done)begin
                pkt_done_r <= 1'b1;
            end
            if(rule_done)begin
                rule_done_r <= 1'b1;
            end
        end
    end
end

//Logic to decide which packet should be forwarded
always @(posedge clk) begin
    if (rst) begin
        out_pkt_valid <= 0;
        out_meta_valid <= 0;
        out_usr_valid <= 0;
        out_pkt_channel <= 0;
    end else begin
        out_pkt_valid <= in_pkt_valid & in_pkt_ready;
        out_usr_valid <= in_usr_valid & in_usr_ready & (state==CHECK);
        out_meta_valid <= check_done;
        out_pkt_channel <= (state==CHECK);
    end
    out_pkt_sop   <= in_pkt_sop;
    out_pkt_eop   <= in_pkt_eop;
    out_pkt_empty <= in_pkt_empty;
    out_pkt_data  <= in_pkt_data;

    //rule
    out_usr_sop   <= in_usr_sop;
    out_usr_eop   <= in_usr_eop;
    out_usr_empty <= in_usr_empty;
    out_usr_data  <= in_usr_data;

    //meta
    out_meta_data  <= in_meta_data;
end

//Only the channel 1 needs the meta/usr data. 
assign out_usr_channel = 1;
assign out_meta_channel = 1;


endmodule
