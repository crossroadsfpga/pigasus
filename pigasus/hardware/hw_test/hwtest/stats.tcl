set STATS_BASE  0x20000000
set LATENCY_BASE  0x28000000
set TX_TRACKER_BASE  0x30000000
set FT_BASE  0x38000000
set FT_REG_BASE  0x24000000
set TOP_REG_BASE  0x22000000
set PCIE_BASE    0x2A000000 
#set FC_0_REG_BASE  0x28000000
#set FC_1_REG_BASE  0x2a000000

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
set REG_IN_PKT                  0
set REG_OUT_PKT                 1
set REG_INCOMP_OUT_META         2
set REG_PARSER_OUT_META         3
set REG_FT_IN_META              4
set REG_FT_OUT_META             5
set REG_EMPTYLIST_IN            6
set REG_EMPTYLIST_OUT           7
set REG_DM_IN_META              8
set REG_DM_OUT_META             9
set REG_DM_IN_FORWARD_META      10 
set REG_DM_IN_DROP_META         11
set REG_DM_IN_CHECK_META        12
set REG_DM_IN_OOO_META          13
set REG_DM_IN_FORWARD_OOO_META  14
set REG_NOPAYLOAD_PKT           15
set REG_DM_CHECK_PKT            16
set REG_SM_PKT                  17
set REG_SM_META                 18
set REG_SM_RULE                 19
set REG_SM_CHECK_PKT            20
set REG_SM_CHECK_PKT_SOP        21
set REG_SM_NOCHECK_PKT          22
set REG_PG_PKT                  23
set REG_PG_META                 24
set REG_PG_RULE                 25
set REG_PG_CHECK_PKT            26
set REG_PG_CHECK_PKT_SOP        27
set REG_PG_NOCHECK_PKT          28
set REG_BYPASS_PKT              29
set REG_BYPASS_PKT_SOP          30
set REG_BYPASS_META             31
set REG_BYPASS_RULE             32
set REG_NF_PKT                  33
set REG_NF_META                 34
set REG_NF_RULE                 35
set REG_NF_CHECK_PKT            36
set REG_NF_CHECK_PKT_SOP        37
set REG_NF_NOCHECK_PKT          38
set REG_MERGE_PKT               39
set REG_MERGE_PKT_SOP           40
set REG_MERGE_META              41
set REG_MERGE_RULE              42
set REG_DMA_PKT                 43
set REG_CPU_NOMATCH_PKT         44
set REG_CPU_MATCH_PKT           45
set REG_CTRL                    46
set REG_MAX_DM2SM               47
set REG_MAX_SM2PG               48
set REG_MAX_PG2NF               49
set REG_MAX_BYPASS2NF           50
set REG_MAX_NF2PDU              51
set REG_SM_BYPASS_AF            52
set REG_SM_CDC_AF               53


#Flow Control reg
set FC_IN_PKT                 0
set FC_IN_FLIT                1
set FC_OUT_PKT                2
set FC_OUT_FLIT               3
set FC_USER_IN_PKT            4
set FC_USER_IN_FLIT           5
set FC_USER_OUT_PKT           6
set FC_USER_OUT_FLIT          7
set FC_ACK_PKT                8
set FC_TX_CREDIT              9

#
#
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
    global REG_IN_PKT                  
    global REG_OUT_PKT                 
    global REG_INCOMP_OUT_META         
    global REG_PARSER_OUT_META         
    global REG_FT_IN_META              
    global REG_FT_OUT_META             
    global REG_EMPTYLIST_IN            
    global REG_EMPTYLIST_OUT           
    global REG_DM_IN_META              
    global REG_DM_OUT_META             
    global REG_DM_IN_FORWARD_META      
    global REG_DM_IN_DROP_META         
    global REG_DM_IN_CHECK_META        
    global REG_DM_IN_OOO_META          
    global REG_DM_IN_FORWARD_OOO_META  
    global REG_NOPAYLOAD_PKT           
    global REG_DM_CHECK_PKT            
    global REG_SM_PKT                  
    global REG_SM_META                 
    global REG_SM_RULE                 
    global REG_SM_CHECK_PKT   
    global REG_SM_CHECK_PKT_SOP
    global REG_SM_NOCHECK_PKT 
    global REG_PG_PKT         
    global REG_PG_META        
    global REG_PG_RULE        
    global REG_PG_CHECK_PKT   
    global REG_PG_CHECK_PKT_SOP   
    global REG_PG_NOCHECK_PKT 
    global REG_BYPASS_PKT     
    global REG_BYPASS_PKT_SOP     
    global REG_BYPASS_META    
    global REG_BYPASS_RULE    
    global REG_NF_PKT         
    global REG_NF_META        
    global REG_NF_RULE        
    global REG_NF_CHECK_PKT   
    global REG_NF_CHECK_PKT_SOP   
    global REG_NF_NOCHECK_PKT 
    global REG_MERGE_PKT      
    global REG_MERGE_PKT_SOP      
    global REG_MERGE_META     
    global REG_MERGE_RULE     
    global REG_DMA_PKT        
    global REG_CPU_NOMATCH_PKT
    global REG_CPU_MATCH_PKT  
    global REG_CTRL           
    global REG_MAX_DM2SM   
    global REG_MAX_SM2PG      
    global REG_MAX_PG2NF      
    global REG_MAX_BYPASS2NF
    global REG_MAX_NF2PDU     
    global REG_SM_BYPASS_AF 
    global REG_SM_CDC_AF    

    set fp [open "top_stats.txt" w+]
    read_top_reg REG_IN_PKT                 $REG_IN_PKT                 $fp  
    read_top_reg REG_OUT_PKT                $REG_OUT_PKT                $fp  
    read_top_reg REG_INCOMP_OUT_META        $REG_INCOMP_OUT_META        $fp  
    read_top_reg REG_PARSER_OUT_META        $REG_PARSER_OUT_META        $fp  
    read_top_reg REG_FT_IN_META             $REG_FT_IN_META             $fp  
    read_top_reg REG_FT_OUT_META            $REG_FT_OUT_META            $fp  
    read_top_reg REG_EMPTYLIST_IN           $REG_EMPTYLIST_IN           $fp  
    read_top_reg REG_EMPTYLIST_OUT          $REG_EMPTYLIST_OUT          $fp  
    read_top_reg REG_DM_IN_META             $REG_DM_IN_META             $fp  
    read_top_reg REG_DM_OUT_META            $REG_DM_OUT_META            $fp  
    read_top_reg REG_DM_IN_FORWARD_META     $REG_DM_IN_FORWARD_META     $fp  
    read_top_reg REG_DM_IN_DROP_META        $REG_DM_IN_DROP_META        $fp  
    read_top_reg REG_DM_IN_CHECK_META       $REG_DM_IN_CHECK_META       $fp  
    read_top_reg REG_DM_IN_OOO_META         $REG_DM_IN_OOO_META         $fp  
    read_top_reg REG_DM_IN_FORWARD_OOO_META $REG_DM_IN_FORWARD_OOO_META $fp 
    read_top_reg REG_NOPAYLOAD_PKT          $REG_NOPAYLOAD_PKT          $fp  
    read_top_reg REG_DM_CHECK_PKT           $REG_DM_CHECK_PKT           $fp  
    read_top_reg REG_SM_PKT                 $REG_SM_PKT                 $fp  
    read_top_reg REG_SM_META                $REG_SM_META                $fp  
    read_top_reg REG_SM_RULE                $REG_SM_RULE                $fp  
    read_top_reg REG_SM_CHECK_PKT           $REG_SM_CHECK_PKT           $fp    
    read_top_reg REG_SM_CHECK_PKT_SOP       $REG_SM_CHECK_PKT_SOP       $fp    
    read_top_reg REG_SM_NOCHECK_PKT         $REG_SM_NOCHECK_PKT         $fp 
    read_top_reg REG_PG_PKT                 $REG_PG_PKT                 $fp 
    read_top_reg REG_PG_META                $REG_PG_META                $fp 
    read_top_reg REG_PG_RULE                $REG_PG_RULE                $fp 
    read_top_reg REG_PG_CHECK_PKT           $REG_PG_CHECK_PKT           $fp 
    read_top_reg REG_PG_CHECK_PKT_SOP       $REG_PG_CHECK_PKT_SOP       $fp 
    read_top_reg REG_PG_NOCHECK_PKT         $REG_PG_NOCHECK_PKT         $fp 
    read_top_reg REG_BYPASS_PKT             $REG_BYPASS_PKT             $fp 
    read_top_reg REG_BYPASS_PKT_SOP         $REG_BYPASS_PKT_SOP         $fp 
    read_top_reg REG_BYPASS_META            $REG_BYPASS_META            $fp 
    read_top_reg REG_BYPASS_RULE            $REG_BYPASS_RULE            $fp 
    read_top_reg REG_NF_PKT                 $REG_NF_PKT                 $fp 
    read_top_reg REG_NF_META                $REG_NF_META                $fp 
    read_top_reg REG_NF_RULE                $REG_NF_RULE                $fp 
    read_top_reg REG_NF_CHECK_PKT           $REG_NF_CHECK_PKT           $fp 
    read_top_reg REG_NF_CHECK_PKT_SOP       $REG_NF_CHECK_PKT_SOP       $fp 
    read_top_reg REG_NF_NOCHECK_PKT         $REG_NF_NOCHECK_PKT         $fp 
    read_top_reg REG_MERGE_PKT              $REG_MERGE_PKT              $fp 
    read_top_reg REG_MERGE_PKT_SOP          $REG_MERGE_PKT_SOP          $fp 
    read_top_reg REG_MERGE_META             $REG_MERGE_META             $fp 
    read_top_reg REG_MERGE_RULE             $REG_MERGE_RULE             $fp 
    read_top_reg REG_DMA_PKT                $REG_DMA_PKT                $fp 
    read_top_reg REG_CPU_NOMATCH_PKT        $REG_CPU_NOMATCH_PKT        $fp 
    read_top_reg REG_CPU_MATCH_PKT          $REG_CPU_MATCH_PKT          $fp 
    read_top_reg REG_CTRL                   $REG_CTRL                   $fp 
    read_top_reg REG_MAX_DM2SM              $REG_MAX_DM2SM              $fp 
    read_top_reg REG_MAX_SM2PG              $REG_MAX_SM2PG              $fp 
    read_top_reg REG_MAX_PG2NF              $REG_MAX_PG2NF              $fp 
    read_top_reg REG_MAX_BYPASS2NF          $REG_MAX_BYPASS2NF          $fp 
    read_top_reg REG_MAX_NF2PDU             $REG_MAX_NF2PDU             $fp 
    read_top_reg REG_SM_BYPASS_AF           $REG_SM_BYPASS_AF           $fp 
    read_top_reg REG_SM_CDC_AF              $REG_SM_CDC_AF              $fp 
                                                                      
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
    global REG_IN_PKT                  
    global REG_OUT_PKT                 
    global REG_INCOMP_OUT_META         
    global REG_PARSER_OUT_META         
    global REG_FT_IN_META              
    global REG_FT_OUT_META             
    global REG_EMPTYLIST_IN            
    global REG_EMPTYLIST_OUT           
    global REG_DM_IN_META              
    global REG_DM_OUT_META             
    global REG_DM_IN_FORWARD_META      
    global REG_DM_IN_DROP_META         
    global REG_DM_IN_CHECK_META        
    global REG_DM_IN_OOO_META          
    global REG_DM_IN_FORWARD_OOO_META  
    global REG_NOPAYLOAD_PKT           
    global REG_DM_CHECK_PKT            
    global REG_SM_PKT                  
    global REG_SM_META                 
    global REG_SM_RULE                 
    global REG_SM_CHECK_PKT   
    global REG_SM_CHECK_PKT_SOP
    global REG_SM_NOCHECK_PKT 
    global REG_PG_PKT         
    global REG_PG_META        
    global REG_PG_RULE        
    global REG_PG_CHECK_PKT   
    global REG_PG_CHECK_PKT_SOP   
    global REG_PG_NOCHECK_PKT 
    global REG_BYPASS_PKT     
    global REG_BYPASS_PKT_SOP     
    global REG_BYPASS_META    
    global REG_BYPASS_RULE    
    global REG_NF_PKT         
    global REG_NF_META        
    global REG_NF_RULE        
    global REG_NF_CHECK_PKT   
    global REG_NF_CHECK_PKT_SOP   
    global REG_NF_NOCHECK_PKT 
    global REG_MERGE_PKT      
    global REG_MERGE_PKT_SOP      
    global REG_MERGE_META     
    global REG_MERGE_RULE     
    global REG_DMA_PKT        
    global REG_CPU_NOMATCH_PKT
    global REG_CPU_MATCH_PKT  
    global REG_CTRL           
    global REG_MAX_DM2SM   
    global REG_MAX_SM2PG      
    global REG_MAX_PG2NF      
    global REG_MAX_BYPASS2NF
    global REG_MAX_NF2PDU     
    global REG_SM_BYPASS_AF 
    global REG_SM_CDC_AF    

    # Test 1
    puts "Check pkt_eop cnt and pkt_sop cnt"
    set rdata [reg_read $TOP_REG_BASE $REG_SM_CHECK_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_SM_CHECK_PKT_SOP]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_PG_CHECK_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_PG_CHECK_PKT_SOP]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_BYPASS_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_BYPASS_PKT_SOP]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_NF_CHECK_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_NF_CHECK_PKT_SOP]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_MERGE_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_MERGE_PKT_SOP]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    # Test 2
    puts "Check pkt_eop cnt and meta cnt"

    set rdata [reg_read $TOP_REG_BASE $REG_DM_IN_CHECK_META]
    set rdata1 [reg_read $TOP_REG_BASE $REG_DM_CHECK_PKT]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_SM_META]
    set rdata1 [reg_read $TOP_REG_BASE $REG_SM_CHECK_PKT]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_PG_META]
    set rdata1 [reg_read $TOP_REG_BASE $REG_PG_CHECK_PKT]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_BYPASS_META]
    set rdata1 [reg_read $TOP_REG_BASE $REG_BYPASS_PKT]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_NF_META]
    set rdata1 [reg_read $TOP_REG_BASE $REG_NF_CHECK_PKT]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_MERGE_META]
    set rdata1 [reg_read $TOP_REG_BASE $REG_MERGE_PKT]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    # Test 3
    puts "Check check_pkt + non_check_pkt"
    set rdata [reg_read $TOP_REG_BASE $REG_SM_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_SM_CHECK_PKT]
    set rdata2 [reg_read $TOP_REG_BASE $REG_SM_NOCHECK_PKT]
    set sum [expr $rdata1 + $rdata2]
    if {$rdata == $sum} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_PG_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_PG_CHECK_PKT]
    set rdata2 [reg_read $TOP_REG_BASE $REG_PG_NOCHECK_PKT]
    set sum [expr $rdata1 + $rdata2]
    if {$rdata == $sum} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_NF_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_NF_CHECK_PKT]
    set rdata2 [reg_read $TOP_REG_BASE $REG_NF_NOCHECK_PKT]
    set sum [expr $rdata1 + $rdata2]
    if {$rdata == $sum} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    # Test 4
    puts "Check pkts across modules"
    set rdata [reg_read $TOP_REG_BASE $REG_DM_CHECK_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_SM_PKT]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_SM_CHECK_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_PG_PKT]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_PG_CHECK_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_BYPASS_PKT]
    set rdata2 [reg_read $TOP_REG_BASE $REG_NF_PKT]
    set sum [expr $rdata1 + $rdata2]
    if {$rdata == $sum} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_MERGE_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_BYPASS_PKT]
    set rdata2 [reg_read $TOP_REG_BASE $REG_NF_CHECK_PKT]
    set sum [expr $rdata1 + $rdata2]
    if {$rdata == $sum} {
        puts "Passed"
    } else {
        puts "Failed"
    }

    set rdata [reg_read $TOP_REG_BASE $REG_MERGE_PKT]
    set rdata1 [reg_read $TOP_REG_BASE $REG_DMA_PKT]
    if {$rdata == $rdata1} {
        puts "Passed"
    } else {
        puts "Failed"
    }
}



################## FC ##################
#proc get_fc_stats {} {
#    global FC_0_REG_BASE
#    global FC_1_REG_BASE
#
#    global FC_IN_PKT       
#    global FC_IN_FLIT      
#    global FC_OUT_PKT      
#    global FC_OUT_FLIT     
#    global FC_USER_IN_PKT  
#    global FC_USER_IN_FLIT 
#    global FC_USER_OUT_PKT 
#    global FC_USER_OUT_FLIT
#    global FC_ACK_PKT      
#    global FC_TX_CREDIT    
#
#    puts "Flow control 0:"
#    read_fc_reg $FC_0_REG_BASE FC_IN_PKT $FC_IN_PKT     
#    read_fc_reg $FC_0_REG_BASE FC_IN_FLIT $FC_IN_FLIT     
#    read_fc_reg $FC_0_REG_BASE FC_OUT_PKT $FC_OUT_PKT     
#    read_fc_reg $FC_0_REG_BASE FC_OUT_FLIT $FC_OUT_FLIT    
#    read_fc_reg $FC_0_REG_BASE FC_USER_IN_PKT $FC_USER_IN_PKT 
#    read_fc_reg $FC_0_REG_BASE FC_USER_IN_FLIT $FC_USER_IN_FLIT
#    read_fc_reg $FC_0_REG_BASE FC_USER_OUT_PKT $FC_USER_OUT_PKT
#    read_fc_reg $FC_0_REG_BASE FC_USER_OUT_FLIT $FC_USER_OUT_FLIT
#    read_fc_reg $FC_0_REG_BASE FC_ACK_PKT $FC_ACK_PKT     
#    read_fc_reg $FC_0_REG_BASE FC_TX_CREDIT $FC_TX_CREDIT   
#
#    puts "Flow control 1:"
#    read_fc_reg $FC_1_REG_BASE FC_IN_PKT $FC_IN_PKT     
#    read_fc_reg $FC_1_REG_BASE FC_IN_FLIT $FC_IN_FLIT     
#    read_fc_reg $FC_1_REG_BASE FC_OUT_PKT $FC_OUT_PKT     
#    read_fc_reg $FC_1_REG_BASE FC_OUT_FLIT $FC_OUT_FLIT    
#    read_fc_reg $FC_1_REG_BASE FC_USER_IN_PKT $FC_USER_IN_PKT 
#    read_fc_reg $FC_1_REG_BASE FC_USER_IN_FLIT $FC_USER_IN_FLIT
#    read_fc_reg $FC_1_REG_BASE FC_USER_OUT_PKT $FC_USER_OUT_PKT
#    read_fc_reg $FC_1_REG_BASE FC_USER_OUT_FLIT $FC_USER_OUT_FLIT
#    read_fc_reg $FC_1_REG_BASE FC_ACK_PKT $FC_ACK_PKT     
#    read_fc_reg $FC_1_REG_BASE FC_TX_CREDIT $FC_TX_CREDIT   
#}
#
#proc read_fc_reg {fc_reg_base reg_name reg_index} {
#    set rdata [reg_read $fc_reg_base $reg_index]
#    set decimal [expr $rdata]
#    puts "$reg_name: $decimal"
#}
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
