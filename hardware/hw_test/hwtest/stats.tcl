set STATS_BASE  0x20000000
set LATENCY_BASE  0x28000000
set TX_TRACKER_BASE  0x30000000
set FT_BASE  0x38000000
set FT_REG_BASE  0x24000000
set TOP_REG_BASE  0x22000000
set RULEID_BASE  0x26000000
set PCIE_BASE    0x2A000000 
set DRAM_BASE    0x2C000000 
#set TEST1_BASE    0x2C000000 
set TEST2_BASE    0x2E000000 
set FT_SIZE 8192

set SCRATCH     0
set REG_CTRL    1

set RX_STATS    2
set RX_MAX_FLIT 3
set RX_CYCLE    4
set RX_FLIT     5
set RX_PKT      6
set RX_BYTE     7
set RX_MAX_PKT     9
set RX_WARMUP_PKT  10
set RX_RECV_PKT  11
set O_RX_RECV_PKT  12
set RX_RECV_NF_PKT  13
set RX_DELAY  14


set TX_STATS    22
set TX_MAX_FLIT 23
set TX_CYCLE    24
set TX_FLIT     25
set TX_PKT      26
set TX_BYTE     27
set TX_LATENCY  28
set TX_MAX_PKT     29
set TX_WARMUP_PKT  30

#FT reg
set FT_CTRL         0
#set FT_IN_PKT       1
#set FT_OUT_PKT      2
set FT_FLOW_INSERT  3
set FT_FLOW_DEQ     4
set FT_LOOKUP_PKT   5
set FT_CONC_FLOW    6
set FT_CURRENT_FLOW 7
set PKT_CNT_FIN     8
set PKT_CNT_ACK     9
set PKT_INSERT_OOO  10

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
set NF_NO_CHECK_PKT     49
set NF_NO_CHECK_1_PKT   50
set NF_MAX_RAW_PKT_FIFO 51
set NF_MAX_PKT_FIFO     52
set NF_MAX_PCIE         53
set NF_MAX_RULE_FIFO    54
set CTRL_REG            55
#set STRING_IN_PKT       16
#set STRING_IN_FLIT      17
#PCIE reg
#set PCIE_CTRL_REG       15
set PCIE_CTRL_REG       64

#DRAM reg
set DRAM_WR_CNT         0
set DRAM_RD_CNT         1
set DRAM_RESP_CNT       2
set DRAM_MAX_RESP       3
set DRAM_RD_SIZE        4

set log 0
#clock period
set cp 2.56
set hist_size 1024

proc show_xput {} {
    set a 0
    while { $a < 10000 } {
        set_clear
        set_up
        sleep 1

        global cp
        set rx_flit [get_rx_flit]
        set rx_flit [expr $rx_flit]
        set byte [expr ($rx_flit * 64) + 24]
        set cycle [get_rx_cycle]
        set cycle [expr $cycle]
        if {$rx_flit ==0 } {
            puts "THROUGHPUT: 0 Gbps"
        } elseif {$cycle ==0 } {
            break
        } else {
            set xput [expr $byte*8.0/($cycle*$cp)]
            puts "THROUGHPUT: $xput Gbps"
        }

        #global cp
        #set tx_flit [get_tx_flit]
        #set tx_flit [expr $tx_flit]
        #set byte [expr $tx_flit * 64]
        #set cycle [get_tx_cycle]
        #set cycle [expr $cycle]
        #set xput [expr $byte*8.0/($cycle*$cp)]
        #puts "TX XPUT: $xput Gbps"

        #puts "valud of a: $a"
        incr a
        puts " "
    }
}

proc set_up {} {
    #set_pkt_size 117
    #load_pkt
    #load_meta
    set_rx_warmup_pkt 10
    set_tx_warmup_pkt 10
    set_rx_max_pkt 9000 
    set_tx_max_pkt 9000
}

#proc set_up {} {
#    #set_pkt_size 117
#    #load_pkt
#    #load_meta
#    set_rx_warmup_pkt 10000
#    set_tx_warmup_pkt 10000
#    set_rx_max_pkt 350000 
#    set_tx_max_pkt 350000
#}

proc get_stats {} {
    rx_stats
    tx_stats
}


proc set_clear {} {
    global STATS_BASE
    global REG_CTRL
    global TX_LATENCY
    global rdata
    global wdata

    #hist states return to write. 
    set rdata [reg_read $STATS_BASE $TX_LATENCY]
    set rdata [expr $rdata & 0x0]
    reg_write $STATS_BASE $TX_LATENCY $rdata

    reg_write $STATS_BASE $REG_CTRL 1
    #sleep 1

    reg_write $STATS_BASE $REG_CTRL 0
}


############RX#####################
proc set_rx_max_flit {MAX_SIZE} {
    global STATS_BASE
    global RX_MAX_FLIT
    global rdata
    global wdata
    reg_write $STATS_BASE $RX_MAX_FLIT $MAX_SIZE
}

proc set_rx_max_pkt {MAX_SIZE} {
    global STATS_BASE
    global RX_MAX_PKT
    global rdata
    global wdata
    reg_write $STATS_BASE $RX_MAX_PKT $MAX_SIZE
}

proc set_rx_warmup_pkt {MAX_SIZE} {
    global STATS_BASE
    global RX_WARMUP_PKT
    global rdata
    global wdata
    reg_write $STATS_BASE $RX_WARMUP_PKT $MAX_SIZE
}

proc set_rx_delay {DELAY} {
    global STATS_BASE
    global RX_DELAY
    global rdata
    global wdata
    #translate usec to cycles
    set cycles [expr $DELAY * 390]
    reg_write $STATS_BASE $RX_DELAY $cycles
}

proc get_rx_max_flit {} {
    global STATS_BASE
    global RX_MAX_FLIT
    #global log
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $RX_MAX_FLIT]
    return $rdata
}

proc check_rx_done {} {
    global STATS_BASE
    global RX_STATS
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $RX_STATS]
    if {$rdata == 1} {
        puts "Done"
    } else {
        puts "Not Done yet"
    }
}

proc get_rx_cycle {} {
    global STATS_BASE
    global RX_CYCLE
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $RX_CYCLE]
    return $rdata
}

proc get_rx_flit {} {
    global STATS_BASE
    global RX_FLIT
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $RX_FLIT]
    return $rdata
}

proc get_rx_pkt {} {
    global STATS_BASE
    global RX_PKT
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $RX_PKT]
    return $rdata
}

proc get_rx_byte {} {
    global STATS_BASE
    global RX_BYTE
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $RX_BYTE]
    return $rdata
}

proc get_rx_recv_pkt {} {
    global STATS_BASE
    global RX_RECV_PKT
    global O_RX_RECV_PKT
    global RX_RECV_NF_PKT
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $RX_RECV_PKT]
    puts "RX_RECV_PKT: $rdata"
    set rdata [reg_read $STATS_BASE $O_RX_RECV_PKT]
    puts "O_RX_RECV_PKT: $rdata"
    set rdata [reg_read $STATS_BASE $RX_RECV_NF_PKT]
    puts "RX_RECV_NF_PKT: $rdata"
}


proc rx_stats {} {
    set fp [open "res.txt" w+]
    global cp
    set a [get_rx_max_flit]
    set a [expr $a]
    puts "RX_MAX_FLITS: $a"
    puts $fp "RX_MAX_FLITS: $a"
    set rx_flit [get_rx_flit]
    set rx_flit [expr $rx_flit]
    puts "RX_FLITS: $rx_flit"
    puts $fp "RX_FLITS: $rx_flit"
    set a [get_rx_pkt]
    set a [expr $a]
    puts "RX_PKT: $a"
    puts $fp "RX_PKT: $a"
    #set byte [get_rx_byte]
    #set byte [expr $byte]
    set byte [expr $rx_flit * 64]
    puts "RX_BYTE: $byte"
    puts $fp "RX_BYTE: $byte"
    set cycle [get_rx_cycle]
    set cycle [expr $cycle]
    puts "RX_CYCLE: $cycle"
    puts $fp "RX_CYCLE: $cycle"
    set xput [expr $byte*8.0/($cycle*$cp)]
    puts "RX XPUT: $xput Gbps"
    puts $fp "RX XPUT: $xput Gbps"
    close $fp
}

############TX#####################

proc set_tx_max_flit {MAX_SIZE} {
    global STATS_BASE
    global TX_MAX_FLIT
    global rdata
    global wdata
    reg_write $STATS_BASE $TX_MAX_FLIT $MAX_SIZE
}

proc set_tx_max_pkt {MAX_SIZE} {
    global STATS_BASE
    global TX_MAX_PKT
    global rdata
    global wdata
    reg_write $STATS_BASE $TX_MAX_PKT $MAX_SIZE
}

proc set_tx_warmup_pkt {MAX_SIZE} {
    global STATS_BASE
    global TX_WARMUP_PKT
    global rdata
    global wdata
    reg_write $STATS_BASE $TX_WARMUP_PKT $MAX_SIZE
}


proc get_tx_max_flit {} {
    global STATS_BASE
    global TX_MAX_FLIT
    #global log
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $TX_MAX_FLIT]
    return $rdata
}

proc check_tx_done {} {
    global STATS_BASE
    global TX_STATS
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $TX_STATS]
    if {$rdata == 1} {
        puts "Done"
    } else {
        puts "Not Done yet"
    }
}

proc get_tx_cycle {} {
    global STATS_BASE
    global TX_CYCLE
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $TX_CYCLE]
    return $rdata
}

proc get_tx_flit {} {
    global STATS_BASE
    global TX_FLIT
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $TX_FLIT]
    return $rdata
}

proc get_tx_pkt {} {
    global STATS_BASE
    global TX_PKT
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $TX_PKT]
    return $rdata
}

proc get_tx_byte {} {
    global STATS_BASE
    global TX_BYTE
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $TX_BYTE]
    return $rdata
}

proc get_tx_latency {} {
    global STATS_BASE
    global TX_LATENCY
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $TX_LATENCY]
    return $rdata
}

proc get_tx_fetch {} {
    global STATS_BASE
    global TX_LATENCY
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $TX_LATENCY]
    set rdata [expr $rdata & 1]
    return $rdata
}

proc set_tx_fetch {} {
    global STATS_BASE
    global TX_LATENCY
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $TX_LATENCY]
    set wdata [expr $rdata | 1]
    reg_write $STATS_BASE $TX_LATENCY $wdata
}


proc get_tx_scale {} {
    global STATS_BASE
    global TX_LATENCY
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $TX_LATENCY]
    set rdata [expr $rdata >> 1]
    return $rdata
}

proc set_tx_scale {tx_scale} {
    global STATS_BASE
    global TX_LATENCY
    global rdata
    global wdata
    set rdata [reg_read $STATS_BASE $TX_LATENCY]
    set fetch [expr $rdata & 1]
    set wdata [expr ($tx_scale << 1) | $fetch]
    reg_write $STATS_BASE $TX_LATENCY $wdata
}

proc tx_stats {} {
    global cp
    set fp [open "res.txt" a+]
    set a [get_tx_max_flit]
    set a [expr $a]
    puts "TX_MAX_FLITS: $a"
    puts $fp "TX_MAX_FLITS: $a"
    set tx_flit [get_tx_flit]
    set tx_flit [expr $tx_flit]
    puts "TX_FLITS: $tx_flit"
    puts $fp "TX_FLITS: $tx_flit"
    set a [get_tx_pkt]
    set a [expr $a]
    puts "TX_PKT: $a"
    puts $fp "TX_PKT: $a"
    #set byte [get_tx_byte]
    #set byte [expr $byte]
    set byte [expr $tx_flit * 64]
    puts "TX_BYTE: $byte"
    puts $fp "TX_BYTE: $byte"
    set cycle [get_tx_cycle]
    set cycle [expr $cycle]
    puts "TX_CYCLE: $cycle"
    puts $fp "TX_CYCLE: $cycle"
    set xput [expr $byte*8.0/($cycle*$cp)]
    puts "TX XPUT: $xput Gbps"
    puts $fp "TX XPUT: $xput Gbps"
    close $fp
}


################## Latency ##################
proc read_hist {} {
    global STATS_BASE
    global LATENCY_BASE
    global rdata
    global wdata
    global hist_size
    global TX_LATENCY

    set rdata [reg_read $STATS_BASE $TX_LATENCY]
    set rdata [expr $rdata | 0x1]
    reg_write $STATS_BASE $TX_LATENCY $rdata

    set fp [open "hist.txt" w+]

    set total 0

    for { set a 0 } { $a < $hist_size } {incr a} {
        set rdata [reg_read $LATENCY_BASE $a]
        set rdata [expr $rdata]
        set total [expr $total + $rdata]
        #puts "$a : $rdata"
        puts $fp "$a : $rdata"
    }
    puts "Total: $total"
    close $fp
}

################## TX_Tracker ##################
proc read_tracker {first_n} {
    global TX_TRACKER_BASE
    global rdata

    for { set a 0 } { $a < $first_n } {incr a} {
        set rdata [reg_read $TX_TRACKER_BASE $a]
        set rdata [expr $rdata]
        puts "$a : $rdata"
    }
}

################## FT ##################
proc get_ft_stats {} {
    global FT_REG_BASE
    #global FT_IN_PKT       
    #global FT_OUT_PKT      
    global FT_FLOW_INSERT  
    global FT_FLOW_DEQ     
    global FT_LOOKUP_PKT   
    global FT_CONC_FLOW   
    global FT_CURRENT_FLOW   
    global PKT_CNT_FIN 
    global PKT_CNT_ACK 
    global PKT_INSERT_OOO
    global rdata
    global wdata
    set fp [open "ft_stats.txt" w+]
    #set rdata [reg_read $FT_REG_BASE $FT_IN_PKT]
    #puts "FT_in_pkt: $rdata"
    #puts $fp "FT_in_pkt: $rdata"
    #set rdata [reg_read $FT_REG_BASE $FT_OUT_PKT]
    #puts "FT_out_pkt: $rdata"
    #puts $fp "FT_out_pkt: $rdata"
    set rdata [reg_read $FT_REG_BASE $FT_FLOW_INSERT]
    puts "FT_flow_insert: $rdata"
    puts $fp "FT_flow_insert: $rdata"
    set rdata [reg_read $FT_REG_BASE $FT_FLOW_DEQ]
    puts "FT_flow_deq: $rdata"
    puts $fp "FT_flow_deq: $rdata"
    set rdata [reg_read $FT_REG_BASE $FT_LOOKUP_PKT]
    puts "FT_lookup_pkt: $rdata"
    puts $fp "FT_lookup_pkt: $rdata"
    set rdata [reg_read $FT_REG_BASE $FT_CONC_FLOW]
    puts "FT_conc_flow: $rdata"
    puts $fp "FT_conc_flow: $rdata"
    set rdata [reg_read $FT_REG_BASE $FT_CURRENT_FLOW]
    puts "FT_current_flow: $rdata"
    puts $fp "FT_current_flow: $rdata"
    set rdata [reg_read $FT_REG_BASE $PKT_CNT_FIN]
    puts "pkt_cnt_fin: $rdata"
    puts $fp "pkt_cnt_fin: $rdata"
    set rdata [reg_read $FT_REG_BASE $PKT_CNT_ACK]
    puts "pkt_cnt_ack: $rdata"
    puts $fp "pkt_cnt_ack: $rdata"
    set rdata [reg_read $FT_REG_BASE $PKT_INSERT_OOO]
    puts "pkt_insert_ooo: $rdata"
    puts $fp "pkt_insert_ooo: $rdata"

    close $fp
}

proc read_ft {} {
    global FT_REG_BASE
    global FT_BASE
    global rdata
    global wdata
    global FT_CTRL
    global FT_SIZE

    reg_write $FT_REG_BASE $FT_CTRL 1

    set fp [open "ft.txt" w+]

    set total_flow 0
    set total_pkt  0

    for { set a 0 } { $a < $FT_SIZE } {incr a} {
        set rdata [reg_read $FT_BASE $a]
        set rdata [expr $rdata]
        set total_pkt [expr $total_pkt + $rdata]
        if {$rdata != 0} {
            set total_flow [expr $total_flow + 1]
            puts $fp "$a : $rdata"
        }
        #puts $fp "$a : $rdata"
    }
    puts "Total_flow: $total_flow"
    puts "Total_pkt: $total_pkt"
    reg_write $FT_REG_BASE $FT_CTRL 0
    close $fp
}

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
    global NF_NO_CHECK_PKT
    global NF_NO_CHECK_1_PKT
    global NF_MAX_RAW_PKT_FIFO
    global NF_MAX_PKT_FIFO
    global NF_MAX_PCIE
    global NF_MAX_RULE_FIFO
    #global STRING_IN_PKT
    #global STRING_IN_FLIT


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
    read_top_reg NF_NO_CHECK_PKT $NF_NO_CHECK_PKT $fp
    read_top_reg NF_NO_CHECK_1_PKT $NF_NO_CHECK_1_PKT $fp
    read_top_reg NF_MAX_RAW_PKT_FIFO $NF_MAX_RAW_PKT_FIFO $fp
    read_top_reg NF_MAX_PKT_FIFO $NF_MAX_PKT_FIFO $fp
    read_top_reg NF_MAX_PCIE $NF_MAX_PCIE $fp
    read_top_reg NF_MAX_RULE_FIFO $NF_MAX_RULE_FIFO $fp

    close $fp
}

proc read_top_reg {reg_name reg_index fp} {
    global TOP_REG_BASE
    set rdata [reg_read $TOP_REG_BASE $reg_index]
    set decimal [expr $rdata]
    puts "$reg_name: $decimal"
    puts $fp "$reg_name: $decimal"

}
proc set_nf_threshold {threshold} {
    global TOP_REG_BASE
    global CTRL_REG
    global rdata
    global wdata


    reg_write $TOP_REG_BASE $CTRL_REG $threshold
}
################## sanity_check ##################

proc sanity_check {} {
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

    global FT_REG_BASE
    global FT_FLOW_INSERT  
    global FT_FLOW_DEQ     
    global FT_LOOKUP_PKT   
    global FT_CONC_FLOW   
    global FT_CURRENT_FLOW   
    global PKT_CNT_FIN 
    global PKT_CNT_ACK 
    global PKT_INSERT_OOO
    global rdata
    global wdata


    # Test 1
    puts "Check bufferred PKTS in FT"
    set rdata [reg_read $TOP_REG_BASE $IN_FT_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $OUT_FT_PKT]
    set result [expr $rdata - $rdata1]

    set rdata [reg_read $FT_REG_BASE $PKT_INSERT_OOO]
    set rdata1 [reg_read $TOP_REG_BASE $PKT_OOO]
    set result1 [expr $rdata - $rdata1]

    puts "in_ft_pkt - out_ft_pkt = $result"
    puts "pkt_insert_ooo - pkt_ooo = $result1"

    if {$result == $result1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    ### Test 2
    puts "Check dropped PKTS in datamover"
    set rdata [reg_read $TOP_REG_BASE $IN_DATAMOVER_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $OUT_DATAMOVER_PKT]
    set result [expr $rdata - $rdata1]

    set rdata [reg_read $TOP_REG_BASE $PKT_DROP]
    set result1 [expr $rdata]

    puts "in_datamover_pkt - out_datamover_pkt = $result"
    puts "pkt_drop = $result1"

    if {$result == $result1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    ### Test 3
    puts "Check Emptylist"
    set rdata [reg_read $TOP_REG_BASE $IN_EMPTYLIST_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $OUT_EMPTYLIST_PKT]
    set result [expr $rdata - $rdata1]

    set rdata [reg_read $FT_REG_BASE $PKT_INSERT_OOO]
    set rdata1 [reg_read $TOP_REG_BASE $PKT_OOO]
    set result1 [expr 1024 - ($rdata - $rdata1)]

    puts "in_empty_pkt - out_empty_pkt = $result"
    puts "1024 - (pkt_insert_ooo - pkt_ooo)= $result1"

    if {$result == $result1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    ### Test 4
    puts "Check datamover in pkts"
    set rdata [reg_read $TOP_REG_BASE $IN_DATAMOVER_PKT]
    set result [expr $rdata]

    set rdata [reg_read $TOP_REG_BASE $PKT_FORWARD]
    set rdata1 [reg_read $TOP_REG_BASE $PKT_DROP]
    set rdata2 [reg_read $TOP_REG_BASE $PKT_CHECK]
    set rdata3 [reg_read $TOP_REG_BASE $PKT_OOO]
    set result1 [expr $rdata + $rdata1 + $rdata2 + $rdata3]

    puts "in_datamover_pkt = $result"
    puts "pkt_forward + pkt_drop + pkt_check + pkt_ooo = $result1"

    if {$result == $result1} {
        puts "Passed"
    } else {
        puts "Failed"
    }


}

################## RuleIDs ##################

proc read_ruleID {} {
    global RULEID_BASE

    set fp [open "ruleID.txt" w+]

    for { set a 0 } { $a < 1024 } {incr a} {
        set rdata [reg_read $RULEID_BASE $a]
        set rdata [expr $rdata]
        set low_data [expr $rdata & 0xFFFF]
        set high_data [expr ($rdata >> 16) & 0xFFFF]
        if {$low_data != 0} {
            puts $fp "$a : $low_data"
            puts "$a : $low_data [format "%04x" $low_data]"
        }
        if {$high_data != 0} {
            puts $fp "$a : $high_data"
            puts "$a : $high_data [format "%04x" $high_data]"
            #puts "$a : $high_data"
        }

        #puts $fp "$a : $rdata"
    }
    close $fp
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

    set_clear
    set_up
}

proc enable_pcie {} {
    global PCIE_BASE
    global PCIE_CTRL_REG
    reg_write $PCIE_BASE $PCIE_CTRL_REG 0x0

    set_clear
    set_up
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

    set_clear
    set_up
}
proc set_buf_size {buf_size} {
    global PCIE_BASE
    global PCIE_CTRL_REG
    global rdata
    global wdata

    set rdata [reg_read $PCIE_BASE $PCIE_CTRL_REG]
    set enable_pcie [expr $rdata & 1]
    set wdata [expr  ($buf_size << 1) | $enable_pcie]

    reg_write $PCIE_BASE $PCIE_CTRL_REG $wdata

    set_clear
    set_up
}
################## DRAM ##################
proc read_dram {} {
    global DRAM_BASE
    global DRAM_WR_CNT             
    global DRAM_RD_CNT
    global DRAM_RESP_CNT
    global DRAM_MAX_RESP           
    global DRAM_RD_SIZE

    read_dram_reg DRAM_WR_CNT $DRAM_WR_CNT
    read_dram_reg DRAM_RD_CNT $DRAM_RD_CNT
    read_dram_reg DRAM_RESP_CNT $DRAM_RESP_CNT
    read_dram_reg DRAM_MAX_RESP $DRAM_MAX_RESP
    read_dram_reg DRAM_RD_SIZE $DRAM_RD_SIZE

}
proc read_dram_reg {reg_name reg_index} {
    global DRAM_BASE
    set rdata [reg_read $DRAM_BASE $reg_index]
    set decimal [expr $rdata]
    puts "$reg_name: $decimal"

}
################## TEST1 ##################
proc read_test1 {} {
    global TEST1_BASE

    for { set a 0 } { $a < 19 } {incr a} {
        set rdata [reg_read $TEST1_BASE $a]
        puts "$a : $rdata"
    }
}

################## TEST2 ##################
proc read_test2 {} {
    global TEST2_BASE

    for { set a 0 } { $a < 29 } {incr a} {
        set rdata [reg_read $TEST2_BASE $a]
        puts "$a : $rdata"
    }
}


