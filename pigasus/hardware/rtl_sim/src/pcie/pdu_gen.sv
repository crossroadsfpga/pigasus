`timescale 1 ps / 1 ps
`include "./src/struct_s.sv"
module pdu_gen(
    input   logic                   clk,
    input   logic                   rst,
    input   logic                   in_sop,
    input   logic                   in_eop,
    input   logic [511:0]           in_data,
    input   logic [5:0]             in_empty,
    input   logic                   in_valid,
    output  logic                   in_ready,
    input   logic                   in_match_sop,
    input   logic                   in_match_eop,
    input   logic [511:0]           in_match_data,
    input   logic [5:0]             in_match_empty,
    input   logic                   in_match_valid,
    output  logic                   in_match_ready,
    input   logic                   in_meta_valid,
    input   metadata_t              in_meta_data,
    output  logic                   in_meta_ready,
    output  flit_lite_t             pcie_rb_wr_data,
    output  logic [PDU_AWIDTH-1:0]  pcie_rb_wr_addr,
    output  logic                   pcie_rb_wr_en,
    input   logic [PDU_AWIDTH-1:0]  pcie_rb_wr_base_addr,
    input   logic                   pcie_rb_almost_full,
    output  logic                   pcie_rb_update_valid,
    output  logic [PDU_AWIDTH-1:0]  pcie_rb_update_size,
    input   logic                   disable_pcie,
    input   logic [PDUID_WIDTH-1:0] pdu_emptylist_out_data,
    input   logic                   pdu_emptylist_out_valid,
    output  logic                   pdu_emptylist_out_ready,
    output  logic [511:0]           pdu_gen_data,
    output  logic                   pdu_gen_sop,
    output  logic                   pdu_gen_eop,
    output  logic [5:0]             pdu_gen_empty,
    output  logic                   pdu_gen_valid,
    input   logic                   pdu_gen_ready,
    input   logic                   pdu_gen_almost_full,
    output  pdu_metadata_t          pdumeta_gen_data,
    output  logic                   pdumeta_gen_valid,
    input   logic                   pdumeta_gen_ready
);

typedef enum {
    START,
    WRITE,
    WRITE_RULEID,
    WRITE_HEAD,
    WAIT
} state_t;
state_t state;

logic                   pdu_wren_r;
logic [511:0]           pdu_data_r;
logic                   pdu_sop_r;
logic                   pdu_eop_r;

logic [PDU_AWIDTH-1:0]  pdu_addr_r;
logic [511:0]           last_flit;
logic [511:0]           pdu_data_swap;
logic                   swap;
logic [5:0]             offset;
logic [15:0]            pdu_size;
logic [15:0]            pdu_flit;
logic [PDU_AWIDTH-1:0]  rule_cnt;
pdu_hdr_t               pdu_hdr;
tuple_t                 tuple;
logic [31:0]            prot;
logic [PDUID_WIDTH-1:0] pdu_id;
logic [PDUID_WIDTH-1:0] check_pkt_cnt;

assign in_ready = (state == WRITE);

assign pdu_hdr.tuple        = in_meta_data.tuple;
assign pdu_hdr.prot         = in_meta_data.prot;
assign pdu_hdr.pdu_id       = pdu_id;
assign pdu_hdr.num_ruleID   = rule_cnt;
assign pdu_hdr.pdu_size     = pdu_size;
assign pdu_hdr.pdu_flit     = pdu_flit;
assign pdu_hdr.action       = ACTION_CHECK;
assign pdu_hdr.padding      = 0;

assign pdu_data_swap = {pdu_data_r[7:0],        pdu_data_r[15:8],       pdu_data_r[23:16],
                        pdu_data_r[31:24],      pdu_data_r[39:32],      pdu_data_r[47:40],
                        pdu_data_r[55:48],      pdu_data_r[63:56],      pdu_data_r[71:64],
                        pdu_data_r[79:72],      pdu_data_r[87:80],      pdu_data_r[95:88],
                        pdu_data_r[103:96],     pdu_data_r[111:104],    pdu_data_r[119:112],
                        pdu_data_r[127:120],    pdu_data_r[135:128],    pdu_data_r[143:136],
                        pdu_data_r[151:144],    pdu_data_r[159:152],    pdu_data_r[167:160],
                        pdu_data_r[175:168],    pdu_data_r[183:176],    pdu_data_r[191:184],
                        pdu_data_r[199:192],    pdu_data_r[207:200],    pdu_data_r[215:208],
                        pdu_data_r[223:216],    pdu_data_r[231:224],    pdu_data_r[239:232],
                        pdu_data_r[247:240],    pdu_data_r[255:248],    pdu_data_r[263:256],
                        pdu_data_r[271:264],    pdu_data_r[279:272],    pdu_data_r[287:280],
                        pdu_data_r[295:288],    pdu_data_r[303:296],    pdu_data_r[311:304],
                        pdu_data_r[319:312],    pdu_data_r[327:320],    pdu_data_r[335:328],
                        pdu_data_r[343:336],    pdu_data_r[351:344],    pdu_data_r[359:352],
                        pdu_data_r[367:360],    pdu_data_r[375:368],    pdu_data_r[383:376],
                        pdu_data_r[391:384],    pdu_data_r[399:392],    pdu_data_r[407:400],
                        pdu_data_r[415:408],    pdu_data_r[423:416],    pdu_data_r[431:424],
                        pdu_data_r[439:432],    pdu_data_r[447:440],    pdu_data_r[455:448],
                        pdu_data_r[463:456],    pdu_data_r[471:464],    pdu_data_r[479:472],
                        pdu_data_r[487:480],    pdu_data_r[495:488],    pdu_data_r[503:496],
                        pdu_data_r[511:504]};

always @(posedge clk) begin
    if (rst) begin
        state                   <= START;
        in_meta_ready           <= 0;
        in_match_ready          <= 1'b0;
        pdu_wren_r              <= 0;
        pdu_sop_r               <= 0;
        pdu_eop_r               <= 0;
        pdu_addr_r              <= 0;
        rule_cnt                <= 0;
        swap                    <= 0;
        pcie_rb_update_valid    <= 0;
        pcie_rb_update_size     <= 0;
        pdu_flit                <= 0;
        pdu_emptylist_out_ready <= 0;
        pdu_gen_valid           <= 1'b0;
        pdumeta_gen_valid       <= 0;
        check_pkt_cnt           <= 0;
    end
    else begin
        case (state)
            START: begin
                in_meta_ready <= 0;
                in_match_ready <= 1'b0;
                pdu_sop_r <= 0;
                pdu_eop_r <= 0;
                pdu_wren_r <= 0;
                pdu_addr_r <= 0;
                rule_cnt <= 0;
                swap <= 0;
                pcie_rb_update_valid <= 0;
                pcie_rb_update_size <= 0;
                pdu_flit <= 0;
                pdu_emptylist_out_ready <= 0;
                pdu_gen_valid <= 1'b0;
                pdumeta_gen_valid <= 0;

                if (in_meta_valid & !in_meta_ready & !pcie_rb_almost_full &
                    pdu_emptylist_out_valid & !pdu_gen_almost_full) begin
                    state <= WRITE;
                end
            end
            WRITE: begin
                pdu_sop_r <= 0;
                pdu_eop_r <= 0;
                pdu_wren_r <= 0;
                pdu_emptylist_out_ready <= 0;

                if (in_valid) begin
                    swap <= 1;
                    pdu_wren_r <= 1;
                    pdu_gen_valid <= 1;
                    pdu_data_r <= in_data;
                    pdu_gen_data <= in_data;
                    pdu_flit <= pdu_flit + 1;

                    // Regular flit
                    if (!in_eop) begin
                        // Assume 0th entry is for hdr.
                        // RuleID is written after pkt.
                        if (in_sop) begin
                            pdu_addr_r <= pcie_rb_wr_base_addr + 1;
                            pdu_size <= 64;
                            pdu_gen_sop  <= 1;
                         end
                         else begin
                            pdu_addr_r <= pdu_addr_r + 1;
                            pdu_size <= pdu_size + 64;
                            pdu_gen_sop  <= 0;
                        end

                        pdu_gen_eop  <= 0;
                        pdu_gen_empty <= 0;
                   end
                   else begin
                        if (in_sop) begin
                            pdu_addr_r <= pcie_rb_wr_base_addr + 1;
                            pdu_size <= 64 - in_empty;
                            pdu_gen_sop  <= 1;
                        end
                        else begin
                            pdu_size <= pdu_size + (64 - in_empty);
                            pdu_addr_r <= pdu_addr_r + 1;
                            pdu_gen_sop  <= 0;
                        end

                        state <= WRITE_RULEID;
                        in_match_ready <= 1;

                        pdu_gen_eop  <= 1;
                        pdu_gen_empty <= in_empty;
                    end
                end
            end
            WRITE_RULEID: begin
                pdu_gen_valid <= 0;
                swap <= 0;
                // Wait until the last rule of current pkt
                if (in_match_valid) begin
                    // The last rule is empty rule, we still need to write the "eop" to
                    // indicate this is the last flit. However, we do not increase addr.
                    // We still add one even when there is an empty rule as we haven't
                    // counted the pdu_hdr flit yet.
                    pdu_flit <= pdu_flit + 1;
                    if (in_match_eop) begin
                        pdu_eop_r <= 1;
                        pdu_sop_r <= 0;
                        pdu_wren_r <= 1;
                        in_match_ready <= 1'b0;

                        // This pkt is a check-pkt
                        if (rule_cnt > 0) begin
                            state <= WRITE_HEAD;
                            if (!disable_pcie) begin
                                pdu_emptylist_out_ready <= 1;
                            end
                            //pdu_id <= pdu_emptylist_out_data;
                            //Debug
                            pdu_id <= check_pkt_cnt;
                            check_pkt_cnt <= check_pkt_cnt + 1'b1;
                        end
                        // This pkt is not a check-pkt
                        else begin
                            state <= WAIT;
                            in_meta_ready <= 1;

                            pdumeta_gen_data.flits <= in_meta_data.flits;
                            pdumeta_gen_data.action <= ACTION_NOCHECK;
                            pdumeta_gen_data.pdu_size <= pdu_size;
                            pdumeta_gen_data.pdu_id <= 0;
                            pdumeta_gen_valid <= 1;
                        end
                    end
                    else begin
                        pdu_addr_r <= pdu_addr_r + 1;
                        pdu_data_r <= in_match_data;
                        rule_cnt <= rule_cnt + 1;
                        pdu_wren_r <= 1;
                    end
                end
                // Wait if there is no rule
                else begin
                    pdu_wren_r <= 0;
                end
            end
            WRITE_HEAD: begin
                swap <= 0;
                pdu_wren_r <= 1;
                pdu_addr_r <= pcie_rb_wr_base_addr;
                pdu_data_r <= pdu_hdr;
                pdu_sop_r <= 1;
                pdu_eop_r <= 0;
                in_meta_ready <= 1;
                pcie_rb_update_valid <= 1;
                pcie_rb_update_size <= pdu_flit;
                pdu_emptylist_out_ready <= 0;

                pdumeta_gen_valid <= 1;
                pdumeta_gen_data.pdu_id <= pdu_id;
                pdumeta_gen_data.pdu_size <= pdu_size;
                pdumeta_gen_data.flits  <= in_meta_data.flits;

                state <= WAIT;
                if (disable_pcie) begin
                    pdumeta_gen_data.action <= ACTION_NOCHECK;
                end
                else begin
                    pdumeta_gen_data.action <= ACTION_CHECK;
                end
            end
            WAIT: begin
                pdu_wren_r <= 0;
                in_meta_ready <= 0;
                pcie_rb_update_valid <= 0;
                if (pdumeta_gen_ready) begin
                    state <= START;
                    pdumeta_gen_valid <= 0;
                end
            end
            default: begin
                $display("Error state!");
                $finish;
            end
        endcase
    end
end

always @(posedge clk) begin
    pcie_rb_wr_en <= pdu_wren_r;
    if (swap) begin
        pcie_rb_wr_data.data <= pdu_data_swap;
    end
    else begin
        pcie_rb_wr_data.data <= pdu_data_r;
    end
    pcie_rb_wr_data.sop <= pdu_sop_r;
    pcie_rb_wr_data.eop <= pdu_eop_r;
    pcie_rb_wr_addr <= pdu_addr_r;
end

endmodule
