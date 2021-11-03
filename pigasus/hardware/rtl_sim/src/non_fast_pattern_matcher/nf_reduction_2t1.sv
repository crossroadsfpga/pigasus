`include "./src/struct_s.sv"
//2 to 1 rule reduction logic, contains internal output FIFO. 
module nf_reduction_2t1(
    input           clk,
    input           rst,
    input rule_nf_t  in_data_0,
    input           in_valid_0,
    output logic    in_ready_0,
    input rule_nf_t  in_data_1,
    input           in_valid_1,
    output logic    in_ready_1,
    output rule_nf_t out_data,
    output logic    out_valid,
    input           out_ready
);

localparam FIFO_DEPTH = 32;
localparam FULL_LEVEL = 20;

logic [1:0]  req;
logic [1:0]  grant;
logic        all_last;
logic        same_data;
rule_nf_t     cache_0;
rule_nf_t     cache_1;
logic        cache_valid_0;
logic        cache_valid_1;
logic        not_cached_0;
logic        not_cached_1;

logic [31:0] int_csr_readdata;
logic        int_almost_full;
rule_nf_t     int_data;
logic        int_valid;
logic        int_ready;

typedef enum{
    SYNC,
    MERGE,
    MERGE_CACHE,
    ARB
} state_t;
state_t state;

//When both inputs are the "last" empty rule
assign all_last = in_data_0.last & in_data_1.last & in_valid_0 & in_valid_1;
//When the inputs are same with each other
assign same_data = (in_data_0.data == in_data_1.data) & in_valid_0 & in_valid_1;
//When the inputs are same as cached data
assign cached_0 = (in_data_0 == cache_0) & in_valid_0 & cache_valid_0;
assign cached_1 = (in_data_1 == cache_1) & in_valid_1 & cache_valid_1;

//state transition
always@(*)begin
    state = ARB;
    if(all_last)begin
        state = SYNC;
    end else if (same_data) begin
        if(cached_0 | cached_1)begin
            state = MERGE_CACHE;
        end else begin
            state = MERGE;
        end
    end else begin
        state = ARB;
    end
end

//Generate request and deq signals
always@(*)begin
    req = 0;
    in_ready_0 = 1'b0;
    in_ready_1 = 1'b0;
    case(state)
        SYNC:begin
            in_ready_0 = !int_almost_full;
            in_ready_1 = !int_almost_full;
        end
        MERGE:begin
            in_ready_0 = !int_almost_full;
            in_ready_1 = !int_almost_full;
        end
        MERGE_CACHE:begin
            in_ready_0 = 1'b1;
            in_ready_1 = 1'b1;
        end
        ARB:begin
            req[0] = in_valid_0 & !in_data_0.last & !cached_0 & !int_almost_full;
            req[1] = in_valid_1 & !in_data_1.last & !cached_1 & !int_almost_full;
            in_ready_0 = grant[0] | cached_0;
            in_ready_1 = grant[1] | cached_1;
        end
    endcase
end

//Enqueue data, update cache
always@(posedge clk)begin
    if(rst)begin
        int_valid <= 1'b0;
        int_data  <= 0;
        cache_valid_0 <= 1'b0;
        cache_valid_1 <= 1'b0;
        cache_0 <= 0;
        cache_1 <= 0;
    end else begin
        int_valid <= 0;
        case(state)
            SYNC:begin
                int_valid <= !int_almost_full;
                int_data  <= in_data_0;

                //clean cache
                cache_0 <= 0;
                cache_1 <= 0;
                cache_valid_0 <= 1'b0;
                cache_valid_1 <= 1'b0;
            end 
            MERGE:begin
                int_valid <= !int_almost_full;
                int_data  <= in_data_0;

                //update 0 cache
                cache_0 <= in_data_0;
                cache_valid_0 <= 1'b1;
            end
            MERGE_CACHE:begin
                //does not generate any data for downstream
                //does not affect cache
                int_valid <= 1'b0;
            end
            ARB:begin
                int_valid <= grant[0] | grant[1];
                int_data <= grant[0] ? in_data_0 : in_data_1;

                //update cache when either input is granted
                if(grant[0])begin
                    cache_valid_0 <= 1'b1;
                    cache_0 <= in_data_0;
                end
                if(grant[1])begin
                    cache_valid_1 <= 1'b1;
                    cache_1 <= in_data_1;
                end
            end
        endcase
    end
end

unified_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] reduction_2t1_FIFO"),
    .MEM_TYPE         ("MLAB"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (FULL_LEVEL),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (RULE_NF_WIDTH),
    .FIFO_DEPTH       (FIFO_DEPTH)
) output_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (int_data),
    .in_valid          (int_valid),
    .in_ready          (int_ready),
    .out_data          (out_data),
    .out_valid         (out_valid),
    .out_ready         (out_ready),
    .fill_level        (int_csr_readdata),
    .almost_full       (int_almost_full),
    .overflow          ()
);

rr_arbiter #(
    .DWIDTH(2)
)
arb_2_inst(
    .clk    (clk),
    .rst    (rst),
    .req    (req),
    .grant  (grant)
);

endmodule

