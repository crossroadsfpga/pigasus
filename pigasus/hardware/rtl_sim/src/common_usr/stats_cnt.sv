`include "./src/struct_s.sv"

//Count number of packet and flit
module stats_cnt (
    input logic Clk, 
    input logic Rst_n,
    input logic valid,
    input logic ready,
    input logic sop,
    input logic eop,
    output logic [31:0] stats_flit,
    output logic [31:0] stats_pkt,
    output logic [31:0] stats_pkt_sop
);


always @ (posedge Clk) begin
    if (~Rst_n) begin
        stats_flit    <= 0;
        stats_pkt     <= 0;
        stats_pkt_sop <= 0;
    end else begin
        if (valid & ready)begin
            stats_flit <= stats_flit + 1;
            if(eop)begin
                stats_pkt <= stats_pkt + 1;
            end
            if(sop)begin
                stats_pkt_sop <= stats_pkt_sop + 1;
            end
        end
    end
end
endmodule


module stats_cnt_rule #(parameter DEBUG=0)
(
    input logic Clk, 
    input logic Rst_n,
    input logic valid,
    input logic ready,
    input logic [511:0] data,
    input logic sop,
    input logic eop,
    output logic [31:0] stats_rule
);

logic [7:0] ones;

integer i;

always@(*)begin
    ones = 0;
    for (i=0;i<32;i=i+1)
        ones = ones + (data[16*i +: 16]!=0);
end

always@(posedge Clk)begin
    if(~Rst_n)begin
        stats_rule  <= 0;
    end else begin
        if(valid & ready & !eop)begin
            stats_rule <= stats_rule + ones;
        end
    end
end

generate
    if(DEBUG==1)begin
        logic [31:0] pkt_cnt;
        always@(posedge Clk)begin
            if(~Rst_n)begin
                pkt_cnt <= '0;
            end else begin
                if(valid & ready & sop)begin
                    pkt_cnt <= pkt_cnt + 1'b1;
                    $display("=== PKT %d ===",pkt_cnt);
                end
                if(valid & ready)begin
                    for (i=0;i<32;i=i+1)begin
                        if(data[16*i +: 16]!=0)begin
                            $display("rule: %d",data[16*i +: 16]);
                        end
                    end
                end
            end
        end
    end
endgenerate

endmodule
