set STATS_BASE  0x20000000
set TOP_REG_BASE  0x22000000
set PCIE_BASE    0x2A000000 


#TOP reg
set IN_PKT              0
set OUT_INCOMP_PKT      1
set OUT_PARSER_PKT      2
set IN_FT_PKT           3
set OUT_FT_PKT          4
set IN_DATAMOVER_PKT    5
set OUT_PKT             6
set OUT_DATAMOVER_PKT   7
set IN_EMPTYLIST_PKT    8
set OUT_EMPTYLIST_PKT   9
set PKT_FORWARD         10
set PKT_DROP            11
set PKT_CHECK           12
set PKT_OOO             13
set PKT_FORWARD_OOO     14
set PKT_DONE            15
set IN_SM_IN_PKT        16
set OUT_SM_IN_PKT       17
set IN_SM_OUT_PKT       18
set OUT_SM_OUT_PKT      19
set OUT_CHECK_FIFO_PKT  20
set IN_CHECK_MUX_PKT    21
set DMA_PKT             22
set RULE_CNT            23
set MAX_RULE_FIFO       24
set MAX_SM_OUT_META     25
set MAX_SM_INDATA       26
set MAX_PARSER_FIFO     27
set MAX_CHECK_PKT_FIFO  28
set NO_CHECK_PKT        29
set NO_MATCH_PKT        30
set MATCH_PKT           31
set MAX_PDUMETA         32
set PG_RULE_CNT         33
set PG_META_CNT         34
set PG_NO_PG_RULE_CNT   35
set PG_INT_RULE_CNT     36
set MAX_PG_RULE_FIFO    37
set AF_NONPAYLOAD_PKT   38
set AF_CHECK_PKT        39
set AF_SM               40
set MAX_NOCHECKPKT_FIFO    41
set MAX_NONPAYLOAD_FIFO    42
set CURRENT_NOCHECKPKT  43
set NO_CHECK_PKT_SOP    44
set PKT_DONE_SOP        45
set NONPAYLOAD_PKT      46
set NONPAYLOAD_PKT_SOP  47
set CHECK_PKT_ERROR     48

#PCIE reg
set PCIE_CTRL_REG       64

################## TOP ##################
proc get_results {} {
    global TOP_REG_BASE
    global IN_PKT              
    global OUT_INCOMP_PKT      
    global DMA_PKT        
    set fp [open "results_stats.txt" w+]
    read_top_reg IN_PKT $IN_PKT $fp
    read_top_reg PROCESSED_PKT $OUT_INCOMP_PKT $fp
    read_top_reg DMA_PKT $DMA_PKT $fp
    close $fp
}

proc get_top_stats {} {
    global TOP_REG_BASE
    global IN_PKT              
    global OUT_INCOMP_PKT      
    global OUT_PARSER_PKT      
    global IN_FT_PKT           
    global OUT_FT_PKT          
    global IN_DATAMOVER_PKT    
    global OUT_PKT             
    global OUT_DATAMOVER_PKT             
    global IN_EMPTYLIST_PKT             
    global OUT_EMPTYLIST_PKT             
    global PKT_FORWARD             
    global PKT_DROP             
    global PKT_CHECK             
    global PKT_OOO             
    global PKT_FORWARD_OOO             
    global PKT_DONE    
    global IN_SM_IN_PKT        
    global OUT_SM_IN_PKT       
    global IN_SM_OUT_PKT       
    global OUT_SM_OUT_PKT      
    global OUT_CHECK_FIFO_PKT  
    global IN_CHECK_MUX_PKT    
    global DMA_PKT        
    global RULE_CNT       
    global MAX_RULE_FIFO  
    global MAX_SM_OUT_META
    global MAX_SM_INDATA  
    global MAX_PARSER_FIFO
    global MAX_CHECK_PKT_FIFO
    global NO_CHECK_PKT
    global NO_MATCH_PKT
    global MATCH_PKT
    global MAX_PDUMETA
    global PG_RULE_CNT
    global PG_META_CNT
    global PG_NO_PG_RULE_CNT
    global PG_INT_RULE_CNT  
    global MAX_PG_RULE_FIFO
    global AF_NONPAYLOAD_PKT
    global AF_CHECK_PKT
    global AF_SM
    global MAX_NOCHECKPKT_FIFO
    global MAX_NONPAYLOAD_FIFO
    global CURRENT_NOCHECKPKT
    global NO_CHECK_PKT_SOP
    global PKT_DONE_SOP
    global NONPAYLOAD_PKT
    global NONPAYLOAD_PKT_SOP
    global CHECK_PKT_ERROR


    set fp [open "top_stats.txt" w+]
    read_top_reg IN_PKT $IN_PKT $fp
    read_top_reg OUT_INCOMP_PKT $OUT_INCOMP_PKT $fp
    read_top_reg OUT_PARSER_PKT $OUT_PARSER_PKT $fp
    read_top_reg IN_FT_PKT $IN_FT_PKT $fp
    read_top_reg OUT_FT_PKT $OUT_FT_PKT $fp
    read_top_reg IN_DATAMOVER_PKT $IN_DATAMOVER_PKT $fp
    read_top_reg OUT_PKT $OUT_PKT $fp
    read_top_reg OUT_DATAMOVER_PKT $OUT_DATAMOVER_PKT $fp
    read_top_reg IN_EMPTYLIST_PKT $IN_EMPTYLIST_PKT $fp
    read_top_reg OUT_EMPTYLIST_PKT $OUT_EMPTYLIST_PKT $fp
    read_top_reg PKT_FORWARD $PKT_FORWARD $fp
    read_top_reg PKT_DROP $PKT_DROP $fp
    read_top_reg PKT_CHECK $PKT_CHECK $fp
    read_top_reg PKT_OOO $PKT_OOO $fp
    read_top_reg PKT_FORWARD_OOO $PKT_FORWARD_OOO $fp
    read_top_reg PKT_DONE $PKT_DONE $fp
    read_top_reg IN_SM_IN_PKT $IN_SM_IN_PKT $fp
    read_top_reg OUT_SM_IN_PKT $OUT_SM_IN_PKT $fp
    read_top_reg IN_SM_OUT_PKT $IN_SM_OUT_PKT $fp
    read_top_reg OUT_SM_OUT_PKT $OUT_SM_OUT_PKT $fp
    read_top_reg OUT_CHECK_FIFO_PKT $OUT_CHECK_FIFO_PKT $fp
    read_top_reg IN_CHECK_MUX_PKT $IN_CHECK_MUX_PKT $fp
    read_top_reg DMA_PKT $DMA_PKT $fp
    read_top_reg RULE_CNT $RULE_CNT $fp
    read_top_reg MAX_RULE_FIFO $MAX_RULE_FIFO $fp
    read_top_reg MAX_SM_OUT_META $MAX_SM_OUT_META $fp
    read_top_reg MAX_SM_INDATA $MAX_SM_INDATA $fp
    read_top_reg MAX_PARSER_FIFO $MAX_PARSER_FIFO $fp
    read_top_reg MAX_CHECK_PKT_FIFO $MAX_CHECK_PKT_FIFO $fp
    read_top_reg NO_CHECK_PKT $NO_CHECK_PKT $fp
    read_top_reg NO_MATCH_PKT $NO_MATCH_PKT $fp
    read_top_reg MATCH_PKT $MATCH_PKT $fp
    read_top_reg MAX_PDUMETA $MAX_PDUMETA $fp
    read_top_reg PG_RULE_CNT $PG_RULE_CNT $fp
    read_top_reg PG_META_CNT $PG_META_CNT $fp
    read_top_reg PG_NO_PG_RULE_CNT $PG_NO_PG_RULE_CNT $fp
    read_top_reg PG_INT_RULE_CNT $PG_INT_RULE_CNT $fp
    read_top_reg MAX_PG_RULE_FIFO $MAX_PG_RULE_FIFO $fp
    read_top_reg AF_NONPAYLOAD_PKT $AF_NONPAYLOAD_PKT $fp
    read_top_reg AF_CHECK_PKT $AF_CHECK_PKT $fp
    read_top_reg AF_SM $AF_SM $fp
    read_top_reg MAX_NOCHECKPKT_FIFO $MAX_NOCHECKPKT_FIFO $fp
    read_top_reg MAX_NONPAYLOAD_FIFO $MAX_NONPAYLOAD_FIFO $fp
    read_top_reg CURRENT_NOCHECKPKT $CURRENT_NOCHECKPKT $fp
    read_top_reg NO_CHECK_PKT_SOP $NO_CHECK_PKT_SOP $fp
    read_top_reg PKT_DONE_SOP $PKT_DONE_SOP $fp
    read_top_reg NONPAYLOAD_PKT $NONPAYLOAD_PKT $fp
    read_top_reg NONPAYLOAD_PKT_SOP $NONPAYLOAD_PKT_SOP $fp
    read_top_reg CHECK_PKT_ERROR $CHECK_PKT_ERROR $fp

    close $fp
}

proc read_top_reg {reg_name reg_index fp} {
    global TOP_REG_BASE
    set rdata [reg_read $TOP_REG_BASE $reg_index]
    set decimal [expr $rdata]
    puts "$reg_name: $decimal"
    puts $fp "$reg_name: $decimal"

}

################## PCIE ##################

proc read_pcie {} {
    global PCIE_BASE


    for { set a 0 } { $a < 65 } {incr a} {
        set rdata [reg_read $PCIE_BASE $a]
        puts "$a : $rdata"
    }
}
proc disable_pcie {} {
    global PCIE_BASE
    global PCIE_CTRL_REG
    reg_write $PCIE_BASE $PCIE_CTRL_REG 0x1

}

proc enable_pcie {} {
    global PCIE_BASE
    global PCIE_CTRL_REG
    reg_write $PCIE_BASE $PCIE_CTRL_REG 0x0

}

proc set_core_num {core_num} {
    global PCIE_BASE
    global PCIE_CTRL_REG
    global rdata
    global wdata

    set rdata [reg_read $PCIE_BASE $PCIE_CTRL_REG]
    set enable_pcie [expr $rdata & 1]
    set buf_size [expr $rdata & 0xFFFFFFE]
    set wdata [expr (($core_num << 27) | $buf_size | $enable_pcie)]

    reg_write $PCIE_BASE $PCIE_CTRL_REG $wdata

}
proc set_buf_size {buf_size} {
    global PCIE_BASE
    global PCIE_CTRL_REG
    global rdata
    global wdata

    set rdata [reg_read $PCIE_BASE $PCIE_CTRL_REG]
    set enable_pcie [expr $rdata & 1]
    set wdata [expr ($buf_size << 1) | $enable_pcie]

    reg_write $PCIE_BASE $PCIE_CTRL_REG $wdata

}

