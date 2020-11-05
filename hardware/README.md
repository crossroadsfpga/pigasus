# Pigasus Hardware Files Description

## rtl_sim:

- `input_gen`: Converts `.pcap` files to `.pkt`, which can be used as input for the RTL simulation. Each line represents a "flit" -- the minimum data unit that can be processed in one cycle on the FPGA. Each flit has 512 bits and one packet consists of a variable number of flits, e.g., a 128-byte packet has 2 flits, while a 256-byte packet has 4 flits. For more information, please refer to [Intel Avalon Streaming Interfaces](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/manual/mnl_avalon_spec.pdf). It also contains the example pcap and expected simulation results of that pcap. 
- `run_vsim.sh`: Script for running simulation in Modelsim.


- `common`: Common building block like FIFOs, DSPs, MUXes. This folder is copied from `../scripts/generated_files`.
- `memory_init`: The initialization files of the multi-string pattern matcher.
- `mspm`: Include the fast pattern matcher and non-fast-pattern matcher.

- `struct_s.sv`: The header file that specifies most of the parameters and structs. 
- `tb.sv`: The testbench. It reads the input `.pkt` files and then drive the system by sending the flits cycle-by-cycle. It also provides different clocks for the design-under-test to match up with hardware clock frequency. When the test finishes, it displays the status registers to mimic the JTAG port used in the hardware test. 
  - `stats.sv`: FPGA side performance monitor. It filters out the ARP packets (users have to change `src_mac_filter`).
  - `top.sv`: The top level module with core logic. Various counters are used to monitor the correctness/performance bottlenecks of the datapath. Below, we describe the modules/files in the order that they appear in the datapath. The FIFOs and arbiter between modules are ignored for simplicity.
    - `hyper_pipe_root.sv`: Hyper registers for better retiming.
    - `input_comp.sv`: Store packets to packet buffer and return packet_header for parser stage. 
    - `parser.sv`: Parse packet_header and create metadata for following modules.
    - `flow_table_wrapper.sv`: The block for tracking flow context. Decide whether packet is an in-order or out-of-order (OOO) packet. OOO packets go to the `flow_reassembly` module for further processing. In-order packets update the flow table context and can skip the `flow_reassembly`.
	- `hash_func.sv`: Hash functions that map packet 4-tuples into flow table addresses. 
        - `flow_table.sv`: Cuckoo hash table with 4 subtables. Manages accesses from both the fast path (in-order packets) and slow path (OOO packets). It is implemented using 4 True-two-port BRAMs.
            - `para_Q.sv`: An 8-entry Content-Addressable-Memory that serves as the stash of the Cuckoo hashtable. It is implemented using registers.
        - `flow_reassembly.sv`: Handles OOO packets in the background. It decides where to insert new OOO packets and what packets can be released. 
            - `linked_list.sv`: Stores the OOO packet ID (pointer to the actual packet data stored in the packet buffer).
    - `data_mover.sv`: Takes packet metadata, which contains the packet ID, from `flow_table_wrapper` and fetch the actual packet data from the packet buffer. Then zero-length packets are forwarded to the Ethernet output, while data packet are sent to string matcher.
    - `data_align.sv`: Strips the header to prepare for string matching.
    - `string_matcher_wrapper.sv`: The wrapper module of the multi-string pattern match (MSPM), which also includes data preprocessing.
        - `dc_fifo_wrapper_infill.sv`: Passes wide data from 200MHz clock domain used by most components to 400MHz clock domain used by MSPM.
        - `st_adapter_512_256.sv`: Converts 512-bit flit to 256-bit flit. MSPM runs at a higher clock rate with narrower input to maintain the same rate while nearly halving the amount of resources.
        - `data_shift.sv`: Merges the current packet payload with the boundary bytes from the last packet in the same flow. 
        - `string_matcher.sv`: Top module of MSPM.
            - `frontend.sv`: Includes the shift-or filter (`first_filter.sv`) and 1-bit wide hashtable array (`hashtable_top.sv` and `hashtable.sv`). 
            - `backend.sv`: Rule reduction logic. Takes 256 sparse inputs and generates 8 outputs (`ruleIDs`) at one cycle. It is implemented as a tree where each node is an arbiter (`rr_arbiter_4.sv` and `rr_arbiter.sv`). To save memory, the shallow FIFOs placed between nodes are mapped to LUTRAM/MLAB instead of BRAM.
    - `port_group.sv`: This comes after the rule reduction logic and checks whether packets' port numbers belong to at least one of the port groups associated with the matching rules. A port group consists of either: a single port value, a range of port values, or a list of port values. If a packet matches at least one rule, it needs further checks and is sent to the Full Matcher. This module can check 8 rules per cycle.
        - `rule_unit.sv`: The unit used to test a single rule. First, the `ruleID` will be used to fetch up to 4 port groups (`port_unit.sv`) determined by the ruleset (one rule may belong to up to 4 port-groups). Then for each port-group, there are three possibilities: the port-group has a single port value, or a range of values, or a list of values. We treat the HTTP port group differently as it is the only port group that may have hundreds of ports. 
    - `non_fast_pattern.sv`: This is non-fast-pattern matcher that comes after the port-group module. It checks the packet payload against the non-fast string patterns of the potential rules.
        - `data_align.sv`: Strips the header to prepare for string matching.
        - `data_shift_512.sv`: Merges the current packet payload with the boundary bytes from the last packet in the same flow. 
        - `st_adapter_512_128.sv`: Convert 512 bit data to 128 bit data. 
        - `non_fast_pattern_sm.sv`: String matcher for non-fast pattern. 
            - `non_fast_pattern_shiftor.sv`: Shift-OR filter of non-fast patterns.
            - `non_fast_pattern_ht.sv`: Hashtables of non-fast patterns.
            - `cal_fp.sv`: Calculate the fingerprint of one packet using the hashed values. 
        - `rule_reduction.sv`: Reduce 8-rules per cycle to 2 rules per cycle. The non_fast_pattern matcher can compare two rule's fingerprint with pkt's fingerprint.
        - `rule_packer_32_128.sv`: Pack 2 rules to 8 rules for PCIe transfer. 
    - `pdu_gen.sv`: Receives the packets and potential rules from the `port_group` and decide whether to forward the packet to the Ethernet output or to the CPU through PCIe. If the packet has at least one candidate rule, that was not discarded in the `port_group`, then the packet -- as well as its metadata candidate rule IDs -- are packed as a "block" for PCIe transfer.
    - `pdu_data_mover.sv`: Manage the data movement between `pdu_gen`, Ethernet, PCIe, and DRAM. The packets sent to the CPU Full Matcher are also copied to the FPGA's DRAM. 

  - `esram_wrapper.sv`: The packet buffer. Users can choose to use eSRAM or BRAM as the packet buffer. 

  - `pcie_top.sv`: The top-level module of PCIe logic. In RTL simulation, the PCIe core is bypassed.
    - `fpga2cpu_pcie.sv`: Handles the FPGA to CPU PCIe transfer. 
      - `ring_buffer.sv`: FPGA side ring buffer to allow batch transfer from FPGA to CPU. 
    - `cpu2fpga_pcie.sv`: Handles the CPU to FPGA PCIe transfer. Similar to the FPGA to CPU path, except that the CPU to FPGA path only needs to pass a short message (512-bit) per block. The actual packets are buffered in the FPGA-side DRAM. 
  - `dram_wrapper.sv`: The top-level module of DRAM logic. In RTL simulation, the DRAM core is also bypassed.


## hw_test
Contains scripts for loading the bitstream and invoking System-console. 
  - `load_bitstream.sh`: Copy the latest `alt_ehipc2_hw.sof` from quartus_project to current dir and then load it to Intel MX Dev Kit.
  - `run_console.sh`: Invoke System-console to read FPGA internal counters or pass parameters (e.g. number of cores used for CPU) to FPGA through JTAG.
  - `hwtest`: The tcl script used to communicate with FPGA throught JTAG. After quartus_project is created, the `hwtest` folder from generated example will be copied here. 

## scripts
  - `scr`: The source files needed for quartus_project, including the configuration file `alt_ehipc2_hw.qsf`, timing constraint file `alt_ehipc2_hw.sdc`, and system top-level verilog `alt_ehipc2_hw.sv`. They are both adapted from the generated 100G ethernet example. 
  - `run_ipgen.sh`: Automatically generate the IPs needed by Pigasus. It will create three folders, `generated_files`, `ethernet`, and `pcie`. The `generated_files` will be used in RTL simulation. And all of these three folders will be used for synthesis. 
  - `run_quartus_create.sh`: Automatically create a Quartus project, which will locate at `pigasus/hardware/quartus_project`. You can open the project in Quartus by opening the `pigasus/hardware/quartus_project/hardware_test_system/alt_ehipc2_hw.qpf`. 
  - `run_quartus_synth.sh`: If you want to directly generate the bitstream, just run this script in commond line. Alternatively, you can open the project in Quartus and then manually generate the bitstream. 

