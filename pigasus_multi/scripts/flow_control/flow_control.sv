`timescale 1 ps / 1 ps
`include "../struct_s.sv"
module flow_control #(
    parameter STATS_REG = FC_0_REG
   )(
    //clk & rst   
    input  logic         clk,                                     
    input  logic         rst,                                  
    //Ethernet In & out
    input  logic         in_sop,          
    input  logic         in_eop,            
    input  logic [511:0] in_data,                    
    input  logic [5:0]   in_empty,                    
    input  logic         in_valid, 
    output logic         in_ready,
    output logic [511:0] out_data,       
    output logic         out_valid,       
    output logic         out_sop,       
    output logic         out_eop,       
    output logic [5:0]   out_empty,       
    input  logic         out_ready,       
    //User In & out
    output logic         user_in_sop,          
    output logic         user_in_eop,            
    output logic [511:0] user_in_data,                    
    output logic [5:0]   user_in_empty,                    
    output logic         user_in_valid, 
    input  logic         user_in_ready,
    input  logic [511:0] user_out_data,       
    input  logic         user_out_valid,       
    input  logic         user_out_sop,       
    input  logic         user_out_eop,       
    input  logic [5:0]   user_out_empty,       
    output logic         user_out_ready,
    //JTAG
    input   logic           clk_status,
    input   logic   [29:0]  status_addr,
    input   logic           status_read,
    input   logic           status_write,
    input   logic   [31:0]  status_writedata,
    output  logic   [31:0]  status_readdata,
    output  logic           status_readdata_valid
);


logic         user_fifo_sop;  
logic         user_fifo_eop;  
logic [511:0] user_fifo_data; 
logic [5:0]   user_fifo_empty;
logic         user_fifo_valid;
logic         user_fifo_ready;
logic         user_fifo_almost_full;

logic         ack_gen_sop;  
logic         ack_gen_eop;  
logic [511:0] ack_gen_data; 
logic [5:0]   ack_gen_empty;
logic         ack_gen_valid;
logic         ack_gen_ready;

logic         ack_out_sop;  
logic         ack_out_eop;  
ack_pkt_t     ack_out_data; 
logic [5:0]   ack_out_empty;
logic         ack_out_valid;
logic         ack_out_ready;
logic         ack_out_fifo_sop;  
logic         ack_out_fifo_eop;  
logic [511:0] ack_out_fifo_data; 
logic [5:0]   ack_out_fifo_empty;
logic         ack_out_fifo_valid;
logic         ack_out_fifo_ready;

logic         int_user_out_sop;  
logic         int_user_out_eop;  
logic [511:0] int_user_out_data; 
logic [5:0]   int_user_out_empty;
logic         int_user_out_valid;
logic         int_user_out_ready;
logic         int_user_out_almost_full;

logic         user_out_fifo_sop;  
logic         user_out_fifo_eop;  
logic [511:0] user_out_fifo_data; 
logic [5:0]   user_out_fifo_empty;
logic         user_out_fifo_valid;
logic         user_out_fifo_ready;


logic [31:0]  csr_readdata;
logic [31:0]  ack_out_csr_readdata;
logic [31:0]  user_fifo_csr_readdata;
logic [31:0]  int_user_out_csr_readdata;
logic [31:0]  free_space;

logic [31:0]  tx_credit;

ack_pkt_t     ack_pkt;
logic         ack_valid;
logic [31:0]  ds_consumed_flit;
logic         ds_valid;

typedef enum{
    IDLE,
    SEND,
    WAIT
} send_state_t;

send_state_t send_state;

//counters
logic [31:0]  in_flit_cnt;
logic [31:0]  in_pkt_cnt;
logic [31:0]  out_flit_cnt;
logic [31:0]  out_pkt_cnt;
logic [31:0]  user_in_flit_cnt;
logic [31:0]  user_in_pkt_cnt;
logic [31:0]  user_in_pkt_sop_cnt;
logic [31:0]  user_out_flit_cnt;
logic [31:0]  user_out_pkt_cnt;
logic [31:0]  ack_pkt_cnt;
logic [31:0]  min_free_space;
logic [31:0]  user_fifo_pkt_sop_cnt;
logic [31:0]  user_fifo_pkt_eop_cnt;

//JTAG
logic   [29:0]           status_addr_r;
logic                    status_read_r;
logic                    status_write_r;
logic   [31:0]           status_writedata_r;
logic [STAT_AWIDTH-1:0]  status_addr_sel_r = 0;

logic [31:0]  in_flit_cnt_status;
logic [31:0]  in_pkt_cnt_status;
logic [31:0]  out_flit_cnt_status;
logic [31:0]  out_pkt_cnt_status;
logic [31:0]  user_in_flit_cnt_status;
logic [31:0]  user_in_pkt_cnt_status;
logic [31:0]  user_in_pkt_sop_cnt_status;
logic [31:0]  user_out_flit_cnt_status;
logic [31:0]  user_out_pkt_cnt_status;
logic [31:0]  ack_pkt_cnt_status;
logic [31:0]  tx_credit_status;
logic [31:0]  min_free_space_status;
logic [31:0]  user_fifo_pkt_sop_cnt_status;
logic [31:0]  user_fifo_pkt_eop_cnt_status;

logic [31:0]  in_flit_cnt_r1;
logic [31:0]  in_pkt_cnt_r1;
logic [31:0]  out_flit_cnt_r1;
logic [31:0]  out_pkt_cnt_r1;
logic [31:0]  user_in_flit_cnt_r1;
logic [31:0]  user_in_pkt_cnt_r1;
logic [31:0]  user_in_pkt_sop_cnt_r1;
logic [31:0]  user_out_flit_cnt_r1;
logic [31:0]  user_out_pkt_cnt_r1;
logic [31:0]  ack_pkt_cnt_r1;
logic [31:0]  tx_credit_r1;
logic [31:0]  min_free_space_r1;
logic [31:0]  user_fifo_pkt_sop_cnt_r1;
logic [31:0]  user_fifo_pkt_eop_cnt_r1;

//input buffer free space
assign free_space = IN_BUF_DEPTH - user_fifo_csr_readdata;
//assign user_fifo_almost_full = free_space < DS_THRESH;
//Generate ack
always@(posedge clk)begin
    if(rst)begin
        ack_out_valid <= 0;
        ack_out_sop   <= 0;
        ack_out_eop   <= 0;
    end else begin
        ack_out_valid <= 0;
        ack_out_sop   <= 0;
        ack_out_eop   <= 0;
        if(ack_valid)begin
            ack_out_valid <= 1;
            ack_out_sop   <= 1;
            ack_out_eop   <= 1;
        end
    end

    ack_out_empty <= 0;
    ack_out_data.udp_hdr <= ack_pkt.udp_hdr;
    ack_out_data.data <= ack_pkt.data;
    ack_out_data.padding <= 0;

    //assume ack FIFO won't overflow
    if(!ack_out_ready & ack_out_valid)begin
        $display("ack FIFO overflow!");
        $finish;
    end
end


//Send state
always@(posedge clk)begin
    if(rst)begin
        send_state <= IDLE;
        tx_credit <= IN_BUF_DEPTH;
        int_user_out_almost_full <= 0;
    end else begin
        //generate back-pressure for user logic. 
        int_user_out_almost_full <= (tx_credit < DS_THRESH) | 
                                (int_user_out_csr_readdata > 460) |
                                (ack_out_csr_readdata > 460);

        //Update tx credit
        if(ds_valid)begin
            if (int_user_out_valid)begin
                tx_credit <= tx_credit + ds_consumed_flit - 1;
            end else begin
                tx_credit <= tx_credit + ds_consumed_flit;
            end
        end else begin
            if (int_user_out_valid)begin
                tx_credit <= tx_credit - 1;
            end
        end

        //if(int_user_out_valid & ds_valid)begin
        //    $display("update tx credit at the same time!");
        //    $finish;
        //end
    end
end

//counters
always @(posedge clk)begin
    if(rst)begin
        in_flit_cnt <= 0;
        in_pkt_cnt  <= 0;
        out_flit_cnt <= 0;
        out_pkt_cnt  <= 0;
        user_in_flit_cnt <= 0;
        user_in_pkt_cnt  <= 0;
        user_in_pkt_sop_cnt  <= 0;
        user_out_flit_cnt <= 0;
        user_out_pkt_cnt  <= 0;

        out_pkt_cnt <= 0;
        ack_pkt_cnt <= 0;

        min_free_space <= IN_BUF_DEPTH;
        user_fifo_pkt_sop_cnt <= 0;
        user_fifo_pkt_eop_cnt <= 0;
    end else begin
        if (in_valid & in_ready)begin
            in_flit_cnt <= in_flit_cnt + 1;
            if(in_eop)begin
                in_pkt_cnt <= in_pkt_cnt + 1;
            end
        end
        if (out_valid & out_ready)begin
            out_flit_cnt <= out_flit_cnt + 1;
            if(out_eop)begin
                out_pkt_cnt <= out_pkt_cnt + 1;
            end
        end
        if (user_in_valid & user_in_ready)begin
            user_in_flit_cnt <= user_in_flit_cnt + 1;
            if(user_in_eop)begin
                user_in_pkt_cnt <= user_in_pkt_cnt + 1;
            end
            if(user_in_sop)begin
                user_in_pkt_sop_cnt <= user_in_pkt_sop_cnt + 1;
            end
        end
        if (user_out_valid & user_out_ready)begin
            user_out_flit_cnt <= user_out_flit_cnt + 1;
            if(user_out_eop)begin
                user_out_pkt_cnt <= user_out_pkt_cnt + 1;
            end
        end
        if (ack_out_valid & ack_out_ready)begin
            ack_pkt_cnt <= ack_pkt_cnt + 1;
        end

        if(user_fifo_ready == 0)begin
            $display("flow_control fifo is full!");
            $finish;
        end

        if(free_space < min_free_space)begin
            min_free_space <= free_space;
        end

        if (user_fifo_valid & user_fifo_ready)begin
            if(user_fifo_eop)begin
                user_fifo_pkt_eop_cnt <= user_fifo_pkt_eop_cnt + 1;
            end
            if(user_fifo_sop)begin
                user_fifo_pkt_sop_cnt <= user_fifo_pkt_sop_cnt + 1;
            end
        end
    end
end

//user clk -> clk_status
always @(posedge clk_status) begin
    in_flit_cnt_r1      <= in_flit_cnt;
    in_flit_cnt_status  <= in_flit_cnt_r1;
    in_pkt_cnt_r1       <= in_pkt_cnt;
    in_pkt_cnt_status   <= in_pkt_cnt_r1;
    out_flit_cnt_r1     <= out_flit_cnt;
    out_flit_cnt_status <= out_flit_cnt_r1;
    out_pkt_cnt_r1      <= out_pkt_cnt;
    out_pkt_cnt_status  <= out_pkt_cnt_r1;
    user_in_flit_cnt_r1      <= user_in_flit_cnt;
    user_in_flit_cnt_status  <= user_in_flit_cnt_r1;
    user_in_pkt_cnt_r1       <= user_in_pkt_cnt;
    user_in_pkt_cnt_status   <= user_in_pkt_cnt_r1;
    user_in_pkt_sop_cnt_r1       <= user_in_pkt_sop_cnt;
    user_in_pkt_sop_cnt_status   <= user_in_pkt_sop_cnt_r1;
    user_out_flit_cnt_r1     <= user_out_flit_cnt;
    user_out_flit_cnt_status <= user_out_flit_cnt_r1;
    user_out_pkt_cnt_r1      <= user_out_pkt_cnt;
    user_out_pkt_cnt_status  <= user_out_pkt_cnt_r1;
    ack_pkt_cnt_r1      <= ack_pkt_cnt;
    ack_pkt_cnt_status  <= ack_pkt_cnt_r1;
    tx_credit_r1      <= tx_credit;
    tx_credit_status  <= tx_credit_r1;
    min_free_space_r1      <= min_free_space;
    min_free_space_status  <= min_free_space_r1;
    user_fifo_pkt_eop_cnt_r1       <= user_fifo_pkt_eop_cnt;
    user_fifo_pkt_eop_cnt_status   <= user_fifo_pkt_eop_cnt_r1;
    user_fifo_pkt_sop_cnt_r1       <= user_fifo_pkt_sop_cnt;
    user_fifo_pkt_sop_cnt_status   <= user_fifo_pkt_sop_cnt_r1;
end

//registers
always @(posedge clk_status) begin
    status_addr_r           <= status_addr[7:0];
    status_addr_sel_r       <= status_addr[29:30-STAT_AWIDTH];

    status_read_r           <= status_read;
    status_write_r          <= status_write;
    status_writedata_r      <= status_writedata;
    status_readdata_valid   <= 1'b0;

    if (status_read_r) begin
        if (status_addr_sel_r == STATS_REG) begin
            status_readdata_valid <= 1'b1;
            case (status_addr_r)
                8'd0  : status_readdata <= in_pkt_cnt_status;
                8'd1  : status_readdata <= in_flit_cnt_status;
                8'd2  : status_readdata <= out_pkt_cnt_status;
                8'd3  : status_readdata <= out_flit_cnt_status;
                8'd4  : status_readdata <= user_in_pkt_cnt_status;
                8'd5  : status_readdata <= user_in_flit_cnt_status;
                8'd6  : status_readdata <= user_out_pkt_cnt_status;
                8'd7  : status_readdata <= user_out_flit_cnt_status;
                8'd8  : status_readdata <= ack_pkt_cnt_status;
                8'd9  : status_readdata <= tx_credit_status;
                8'd10  : status_readdata <= user_in_pkt_sop_cnt_status;
                8'd11  : status_readdata <= min_free_space_status;
                8'd12  : status_readdata <= user_fifo_pkt_sop_cnt_status;
                8'd13  : status_readdata <= user_fifo_pkt_eop_cnt_status;

                default : status_readdata <= 32'hdeadbeef;
            endcase
        end
    end
end

//Instantiation

flow_control_parser parser_inst (
    .clk               (clk),    
    .rst               (rst),      
    .in_data           (in_data),
    .in_valid          (in_valid),
    .in_ready          (in_ready),
    .in_sop            (in_sop),
    .in_eop            (in_eop),
    .in_empty          (in_empty),
    .out_data          (user_fifo_data),
    .out_valid         (user_fifo_valid),
    .out_ready         (user_fifo_ready),//Should always be 1.
    //.out_almost_full   (user_fifo_almost_full),
    .out_sop           (user_fifo_sop),
    .out_eop           (user_fifo_eop),
    .out_empty         (user_fifo_empty),
    .ds_consumed_flit  (ds_consumed_flit),
    .ds_valid          (ds_valid)
);

fifo_pkt_wrapper_infill  #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(IN_BUF_DEPTH)
)
user_in_fifo (
    .clk               (clk),
    .reset             (rst),
    .csr_address       (0),
    .csr_read          (1'b1),
    .csr_write         (1'b0),
    .csr_readdata      (user_fifo_csr_readdata),
    .csr_writedata     (32'b0),
    .in_data           (user_fifo_data),
    .in_valid          (user_fifo_valid),
    .in_ready          (user_fifo_ready),
    .in_startofpacket  (user_fifo_sop),
    .in_endofpacket    (user_fifo_eop),
    .in_empty          (user_fifo_empty),
    .out_data          (ack_gen_data),
    .out_valid         (ack_gen_valid),
    .out_ready         (ack_gen_ready),
    .out_startofpacket (ack_gen_sop),
    .out_endofpacket   (ack_gen_eop),
    .out_empty         (ack_gen_empty)
);


ack_gen ack_gen_inst (
    .clk               (clk),    
    .rst               (rst),      
    .in_data           (ack_gen_data),
    .in_valid          (ack_gen_valid),
    .in_ready          (ack_gen_ready),
    .in_sop            (ack_gen_sop),
    .in_eop            (ack_gen_eop),
    .in_empty          (ack_gen_empty),
    .out_data          (user_in_data),
    .out_valid         (user_in_valid),
    .out_ready         (user_in_ready),
    .out_sop           (user_in_sop),
    .out_eop           (user_in_eop),
    .out_empty         (user_in_empty),
    .ack_pkt           (ack_pkt),
    .ack_valid         (ack_valid)
);

fifo_pkt_wrapper_infill  #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512)
)
ack_fifo (
    .clk               (clk),
    .reset             (rst),
    .csr_address       (0),
    .csr_read          (1'b1),
    .csr_write         (1'b0),
    .csr_readdata      (ack_out_csr_readdata),
    .csr_writedata     (32'b0),
    .in_data           (ack_out_data),
    .in_valid          (ack_out_valid),
    .in_ready          (ack_out_ready),
    .in_startofpacket  (ack_out_sop),
    .in_endofpacket    (ack_out_eop),
    .in_empty          (ack_out_empty),
    .out_data          (ack_out_fifo_data),
    .out_valid         (ack_out_fifo_valid),
    .out_ready         (ack_out_fifo_ready),
    .out_startofpacket (ack_out_fifo_sop),
    .out_endofpacket   (ack_out_fifo_eop),
    .out_empty         (ack_out_fifo_empty)
);

pkt_almost_full pkt_almost_full_inst(
    .clk               (clk),    
    .rst               (rst),      
    .in_data           (user_out_data),           
    .in_valid          (user_out_valid),          
    .in_ready          (user_out_ready),           
    .in_sop            (user_out_sop),  
    .in_eop            (user_out_eop),
    .in_empty          (user_out_empty), 
    .out_data          (int_user_out_data),          
    .out_valid         (int_user_out_valid),         
    .out_almost_full   (int_user_out_almost_full),         
    .out_sop           (int_user_out_sop), 
    .out_eop           (int_user_out_eop),   
    .out_empty         (int_user_out_empty)          
);

fifo_pkt_wrapper_infill  #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512)
)
user_out_fifo (
    .clk               (clk),
    .reset             (rst),
    .csr_address       (0),
    .csr_read          (1'b1),
    .csr_write         (1'b0),
    .csr_readdata      (int_user_out_csr_readdata),
    .csr_writedata     (32'b0),
    .in_data           (int_user_out_data),
    .in_valid          (int_user_out_valid),
    .in_ready          (int_user_out_ready),
    .in_startofpacket  (int_user_out_sop),
    .in_endofpacket    (int_user_out_eop),
    .in_empty          (int_user_out_empty),
    .out_data          (user_out_fifo_data),
    .out_valid         (user_out_fifo_valid),
    .out_ready         (user_out_fifo_ready),
    .out_startofpacket (user_out_fifo_sop),
    .out_endofpacket   (user_out_fifo_eop),
    .out_empty         (user_out_fifo_empty)
);

st_multiplexer_pkt multiplexer_pkt (
    .clk               (clk),
    .reset_n           (!rst),
    .out_data          (out_data),
    .out_valid         (out_valid),
    .out_ready         (out_ready),
    .out_startofpacket (out_sop),
    .out_endofpacket   (out_eop),
    .out_empty         (out_empty),
    .out_channel       (),
    .in0_data          (user_out_fifo_data),
    .in0_valid         (user_out_fifo_valid),
    .in0_ready         (user_out_fifo_ready),
    .in0_startofpacket (user_out_fifo_sop),
    .in0_endofpacket   (user_out_fifo_eop),
    .in0_empty         (user_out_fifo_empty),
    .in1_data          (ack_out_fifo_data),
    .in1_valid         (ack_out_fifo_valid),
    .in1_ready         (ack_out_fifo_ready),
    .in1_startofpacket (ack_out_fifo_sop),
    .in1_endofpacket   (ack_out_fifo_eop),
    .in1_empty         (ack_out_fifo_empty)
);

endmodule
