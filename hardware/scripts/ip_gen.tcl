package require -exact qsys 18.0

# create the system "ip_gen"
proc do_create_ip_gen {} {
	# create the system
	create_system ip_gen
	set_project_property DEVICE {1SM21BHU2F53E1VG}
	set_project_property DEVICE_FAMILY {Stratix 10}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

	# add the components
	add_component bram_1port ip/ip_gen/bram_1port.ip ram_1port bram_1port 19.2.0
	load_component bram_1port
	set_component_parameter_value GUI_ADDRESSSTALL_A {0}
	set_component_parameter_value GUI_AclrAddr {0}
	set_component_parameter_value GUI_AclrByte {0}
	set_component_parameter_value GUI_AclrData {0}
	set_component_parameter_value GUI_AclrOutput {0}
	set_component_parameter_value GUI_BYTE_ENABLE {0}
	set_component_parameter_value GUI_BYTE_SIZE {8}
	set_component_parameter_value GUI_BlankMemory {0}
	set_component_parameter_value GUI_CLOCK_ENABLE_INPUT_A {0}
	set_component_parameter_value GUI_CLOCK_ENABLE_OUTPUT_A {0}
	set_component_parameter_value GUI_Clken {0}
	set_component_parameter_value GUI_FILE_REFERENCE {0}
	set_component_parameter_value GUI_FORCE_TO_ZERO {0}
	set_component_parameter_value GUI_IMPLEMENT_IN_LES {0}
	set_component_parameter_value GUI_INIT_FILE_LAYOUT {PORT_A}
	set_component_parameter_value GUI_INIT_TO_SIM_X {0}
	set_component_parameter_value GUI_JTAG_ENABLED {0}
	set_component_parameter_value GUI_JTAG_ID {NONE}
	set_component_parameter_value GUI_MAXIMUM_DEPTH {0}
	set_component_parameter_value GUI_MIFfilename {}
	set_component_parameter_value GUI_NUMWORDS_A {512}
	set_component_parameter_value GUI_OPTIMIZATION_OPTION {0}
	set_component_parameter_value GUI_PR {0}
	set_component_parameter_value GUI_RAM_BLOCK_TYPE {Auto}
	set_component_parameter_value GUI_READ_DURING_WRITE_MODE_PORT_A {0}
	set_component_parameter_value GUI_RegAddr {1}
	set_component_parameter_value GUI_RegData {1}
	set_component_parameter_value GUI_RegOutput {1}
	set_component_parameter_value GUI_SclrOutput {0}
	set_component_parameter_value GUI_SingleClock {0}
	set_component_parameter_value GUI_TBENCH {0}
	set_component_parameter_value GUI_WIDTH_A {16}
	set_component_parameter_value GUI_WRCONTROL_ACLR_A {0}
	set_component_parameter_value GUI_X_MASK {0}
	set_component_parameter_value GUI_rden {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation bram_1port
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface data conduit INPUT
	set_instantiation_interface_parameter_value data associatedClock {}
	set_instantiation_interface_parameter_value data associatedReset {}
	set_instantiation_interface_parameter_value data prSafe {false}
	set_instantiation_interface_assignment_value data ui.blockdiagram.direction {input}
	add_instantiation_interface_port data data datain 16 STD_LOGIC_VECTOR Input
	add_instantiation_interface q conduit INPUT
	set_instantiation_interface_parameter_value q associatedClock {}
	set_instantiation_interface_parameter_value q associatedReset {}
	set_instantiation_interface_parameter_value q prSafe {false}
	set_instantiation_interface_assignment_value q ui.blockdiagram.direction {output}
	add_instantiation_interface_port q q dataout 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface address conduit INPUT
	set_instantiation_interface_parameter_value address associatedClock {}
	set_instantiation_interface_parameter_value address associatedReset {}
	set_instantiation_interface_parameter_value address prSafe {false}
	set_instantiation_interface_assignment_value address ui.blockdiagram.direction {input}
	add_instantiation_interface_port address address address 9 STD_LOGIC_VECTOR Input
	add_instantiation_interface wren conduit INPUT
	set_instantiation_interface_parameter_value wren associatedClock {}
	set_instantiation_interface_parameter_value wren associatedReset {}
	set_instantiation_interface_parameter_value wren prSafe {false}
	set_instantiation_interface_assignment_value wren ui.blockdiagram.direction {input}
	add_instantiation_interface_port wren wren wren 1 STD_LOGIC Input
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	set_instantiation_interface_assignment_value clock ui.blockdiagram.direction {input}
	add_instantiation_interface_port clock clock clk 1 STD_LOGIC Input
	add_instantiation_interface rden conduit INPUT
	set_instantiation_interface_parameter_value rden associatedClock {}
	set_instantiation_interface_parameter_value rden associatedReset {}
	set_instantiation_interface_parameter_value rden prSafe {false}
	set_instantiation_interface_assignment_value rden ui.blockdiagram.direction {input}
	add_instantiation_interface_port rden rden rden 1 STD_LOGIC Input
	save_instantiation
	add_component bram_dc_diff_width ip/ip_gen/bram_dc_diff_width.ip ram_2port bram_dc_diff_width 19.2.0
	load_component bram_dc_diff_width
	set_component_parameter_value GUI_ACLR_READ_INPUT_RDADDRESS {0}
	set_component_parameter_value GUI_ACLR_READ_OUTPUT_QA {0}
	set_component_parameter_value GUI_ACLR_READ_OUTPUT_QB {0}
	set_component_parameter_value GUI_BLANK_MEMORY {0}
	set_component_parameter_value GUI_BYTE_ENABLE_A {0}
	set_component_parameter_value GUI_BYTE_ENABLE_B {0}
	set_component_parameter_value GUI_BYTE_ENABLE_WIDTH {8}
	set_component_parameter_value GUI_CLKEN_ADDRESS_STALL_A {0}
	set_component_parameter_value GUI_CLKEN_ADDRESS_STALL_B {0}
	set_component_parameter_value GUI_CLKEN_INPUT_REG_A {0}
	set_component_parameter_value GUI_CLKEN_INPUT_REG_B {0}
	set_component_parameter_value GUI_CLKEN_OUTPUT_REG_A {0}
	set_component_parameter_value GUI_CLKEN_OUTPUT_REG_B {0}
	set_component_parameter_value GUI_CLKEN_RDADDRESSSTALL {0}
	set_component_parameter_value GUI_CLKEN_READ_INPUT_REG {0}
	set_component_parameter_value GUI_CLKEN_READ_OUTPUT_REG {0}
	set_component_parameter_value GUI_CLKEN_WRADDRESSSTALL {0}
	set_component_parameter_value GUI_CLKEN_WRITE_INPUT_REG {0}
	set_component_parameter_value GUI_CLOCK_TYPE {1}
	set_component_parameter_value GUI_COHERENT_READ {0}
	set_component_parameter_value GUI_CONSTRAINED_DONT_CARE {1}
	set_component_parameter_value GUI_DATAA_WIDTH {512}
	set_component_parameter_value GUI_DIFFERENT_CLKENS {0}
	set_component_parameter_value GUI_ECCENCBYPASS {0}
	set_component_parameter_value GUI_ECC_DOUBLE {0}
	set_component_parameter_value GUI_ECC_PIPELINE {0}
	set_component_parameter_value GUI_ECC_TRIPLE {0}
	set_component_parameter_value GUI_FILE_REFERENCE {0}
	set_component_parameter_value GUI_FORCE_TO_ZERO {0}
	set_component_parameter_value GUI_INIT_FILE_LAYOUT {PORT_B}
	set_component_parameter_value GUI_INIT_SIM_TO_X {0}
	set_component_parameter_value GUI_LC_IMPLEMENTION_OPTIONS {0}
	set_component_parameter_value GUI_MAX_DEPTH {Auto}
	set_component_parameter_value GUI_MEMSIZE_BITS {256}
	set_component_parameter_value GUI_MEMSIZE_WORDS {512}
	set_component_parameter_value GUI_MEM_IN_BITS {0}
	set_component_parameter_value GUI_MIF_FILENAME {}
	set_component_parameter_value GUI_MODE {0}
	set_component_parameter_value GUI_NBE_A {1}
	set_component_parameter_value GUI_NBE_B {1}
	set_component_parameter_value GUI_OPTIMIZATION_OPTION {0}
	set_component_parameter_value GUI_PR {0}
	set_component_parameter_value GUI_QA_WIDTH {512}
	set_component_parameter_value GUI_QB_WIDTH {32}
	set_component_parameter_value GUI_Q_PORT_MODE {2}
	set_component_parameter_value GUI_RAM_BLOCK_TYPE {M20K}
	set_component_parameter_value GUI_RDEN_DOUBLE {0}
	set_component_parameter_value GUI_RDEN_SINGLE {1}
	set_component_parameter_value GUI_RDW_A_MODE {New Data}
	set_component_parameter_value GUI_RDW_B_MODE {New Data}
	set_component_parameter_value GUI_READ_INPUT_RDADDRESS {1}
	set_component_parameter_value GUI_READ_OUTPUT_QA {1}
	set_component_parameter_value GUI_READ_OUTPUT_QB {1}
	set_component_parameter_value GUI_SCLR_READ_OUTPUT_QA {0}
	set_component_parameter_value GUI_SCLR_READ_OUTPUT_QB {0}
	set_component_parameter_value GUI_TBENCH {0}
	set_component_parameter_value GUI_TDP_EMULATE {0}
	set_component_parameter_value GUI_VAR_WIDTH {1}
	set_component_parameter_value GUI_WIDTH_ECCENCPARITY {8}
	set_component_parameter_value GUI_WRITE_INPUT_PORTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation bram_dc_diff_width
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface data conduit INPUT
	set_instantiation_interface_parameter_value data associatedClock {}
	set_instantiation_interface_parameter_value data associatedReset {}
	set_instantiation_interface_parameter_value data prSafe {false}
	set_instantiation_interface_assignment_value data ui.blockdiagram.direction {input}
	add_instantiation_interface_port data data datain 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface q conduit INPUT
	set_instantiation_interface_parameter_value q associatedClock {}
	set_instantiation_interface_parameter_value q associatedReset {}
	set_instantiation_interface_parameter_value q prSafe {false}
	set_instantiation_interface_assignment_value q ui.blockdiagram.direction {output}
	add_instantiation_interface_port q q dataout 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface wraddress conduit INPUT
	set_instantiation_interface_parameter_value wraddress associatedClock {}
	set_instantiation_interface_parameter_value wraddress associatedReset {}
	set_instantiation_interface_parameter_value wraddress prSafe {false}
	set_instantiation_interface_assignment_value wraddress ui.blockdiagram.direction {input}
	add_instantiation_interface_port wraddress wraddress wraddress 9 STD_LOGIC_VECTOR Input
	add_instantiation_interface rdaddress conduit INPUT
	set_instantiation_interface_parameter_value rdaddress associatedClock {}
	set_instantiation_interface_parameter_value rdaddress associatedReset {}
	set_instantiation_interface_parameter_value rdaddress prSafe {false}
	set_instantiation_interface_assignment_value rdaddress ui.blockdiagram.direction {input}
	add_instantiation_interface_port rdaddress rdaddress rdaddress 13 STD_LOGIC_VECTOR Input
	add_instantiation_interface wren conduit INPUT
	set_instantiation_interface_parameter_value wren associatedClock {}
	set_instantiation_interface_parameter_value wren associatedReset {}
	set_instantiation_interface_parameter_value wren prSafe {false}
	set_instantiation_interface_assignment_value wren ui.blockdiagram.direction {input}
	add_instantiation_interface_port wren wren wren 1 STD_LOGIC Input
	add_instantiation_interface wrclock clock INPUT
	set_instantiation_interface_parameter_value wrclock clockRate {0}
	set_instantiation_interface_parameter_value wrclock externallyDriven {false}
	set_instantiation_interface_parameter_value wrclock ptfSchematicName {}
	set_instantiation_interface_assignment_value wrclock ui.blockdiagram.direction {input}
	add_instantiation_interface_port wrclock wrclock clk 1 STD_LOGIC Input
	add_instantiation_interface rdclock clock INPUT
	set_instantiation_interface_parameter_value rdclock clockRate {0}
	set_instantiation_interface_parameter_value rdclock externallyDriven {false}
	set_instantiation_interface_parameter_value rdclock ptfSchematicName {}
	set_instantiation_interface_assignment_value rdclock ui.blockdiagram.direction {input}
	add_instantiation_interface_port rdclock rdclock clk 1 STD_LOGIC Input
	add_instantiation_interface rden conduit INPUT
	set_instantiation_interface_parameter_value rden associatedClock {}
	set_instantiation_interface_parameter_value rden associatedReset {}
	set_instantiation_interface_parameter_value rden prSafe {false}
	set_instantiation_interface_assignment_value rden ui.blockdiagram.direction {input}
	add_instantiation_interface_port rden rden rden 1 STD_LOGIC Input
	save_instantiation
	add_component bram_simple2port ip/ip_gen/bram_simple2port.ip ram_2port bram_simple2port 19.2.0
	load_component bram_simple2port
	set_component_parameter_value GUI_ACLR_READ_INPUT_RDADDRESS {0}
	set_component_parameter_value GUI_ACLR_READ_OUTPUT_QA {0}
	set_component_parameter_value GUI_ACLR_READ_OUTPUT_QB {0}
	set_component_parameter_value GUI_BLANK_MEMORY {0}
	set_component_parameter_value GUI_BYTE_ENABLE_A {0}
	set_component_parameter_value GUI_BYTE_ENABLE_B {0}
	set_component_parameter_value GUI_BYTE_ENABLE_WIDTH {8}
	set_component_parameter_value GUI_CLKEN_ADDRESS_STALL_A {0}
	set_component_parameter_value GUI_CLKEN_ADDRESS_STALL_B {0}
	set_component_parameter_value GUI_CLKEN_INPUT_REG_A {0}
	set_component_parameter_value GUI_CLKEN_INPUT_REG_B {0}
	set_component_parameter_value GUI_CLKEN_OUTPUT_REG_A {0}
	set_component_parameter_value GUI_CLKEN_OUTPUT_REG_B {0}
	set_component_parameter_value GUI_CLKEN_RDADDRESSSTALL {0}
	set_component_parameter_value GUI_CLKEN_READ_INPUT_REG {0}
	set_component_parameter_value GUI_CLKEN_READ_OUTPUT_REG {0}
	set_component_parameter_value GUI_CLKEN_WRADDRESSSTALL {0}
	set_component_parameter_value GUI_CLKEN_WRITE_INPUT_REG {0}
	set_component_parameter_value GUI_CLOCK_TYPE {0}
	set_component_parameter_value GUI_COHERENT_READ {0}
	set_component_parameter_value GUI_CONSTRAINED_DONT_CARE {1}
	set_component_parameter_value GUI_DATAA_WIDTH {16}
	set_component_parameter_value GUI_DIFFERENT_CLKENS {0}
	set_component_parameter_value GUI_ECCENCBYPASS {0}
	set_component_parameter_value GUI_ECC_DOUBLE {0}
	set_component_parameter_value GUI_ECC_PIPELINE {0}
	set_component_parameter_value GUI_ECC_TRIPLE {0}
	set_component_parameter_value GUI_FILE_REFERENCE {0}
	set_component_parameter_value GUI_FORCE_TO_ZERO {0}
	set_component_parameter_value GUI_INIT_FILE_LAYOUT {PORT_B}
	set_component_parameter_value GUI_INIT_SIM_TO_X {0}
	set_component_parameter_value GUI_LC_IMPLEMENTION_OPTIONS {0}
	set_component_parameter_value GUI_MAX_DEPTH {Auto}
	set_component_parameter_value GUI_MEMSIZE_BITS {256}
	set_component_parameter_value GUI_MEMSIZE_WORDS {512}
	set_component_parameter_value GUI_MEM_IN_BITS {0}
	set_component_parameter_value GUI_MIF_FILENAME {}
	set_component_parameter_value GUI_MODE {0}
	set_component_parameter_value GUI_NBE_A {1}
	set_component_parameter_value GUI_NBE_B {1}
	set_component_parameter_value GUI_OPTIMIZATION_OPTION {0}
	set_component_parameter_value GUI_PR {0}
	set_component_parameter_value GUI_QA_WIDTH {16}
	set_component_parameter_value GUI_QB_WIDTH {16}
	set_component_parameter_value GUI_Q_PORT_MODE {2}
	set_component_parameter_value GUI_RAM_BLOCK_TYPE {M20K}
	set_component_parameter_value GUI_RDEN_DOUBLE {0}
	set_component_parameter_value GUI_RDEN_SINGLE {1}
	set_component_parameter_value GUI_RDW_A_MODE {New Data}
	set_component_parameter_value GUI_RDW_B_MODE {New Data}
	set_component_parameter_value GUI_READ_INPUT_RDADDRESS {1}
	set_component_parameter_value GUI_READ_OUTPUT_QA {1}
	set_component_parameter_value GUI_READ_OUTPUT_QB {1}
	set_component_parameter_value GUI_SCLR_READ_OUTPUT_QA {0}
	set_component_parameter_value GUI_SCLR_READ_OUTPUT_QB {0}
	set_component_parameter_value GUI_TBENCH {0}
	set_component_parameter_value GUI_TDP_EMULATE {0}
	set_component_parameter_value GUI_VAR_WIDTH {0}
	set_component_parameter_value GUI_WIDTH_ECCENCPARITY {8}
	set_component_parameter_value GUI_WRITE_INPUT_PORTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation bram_simple2port
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface data conduit INPUT
	set_instantiation_interface_parameter_value data associatedClock {}
	set_instantiation_interface_parameter_value data associatedReset {}
	set_instantiation_interface_parameter_value data prSafe {false}
	set_instantiation_interface_assignment_value data ui.blockdiagram.direction {input}
	add_instantiation_interface_port data data datain 16 STD_LOGIC_VECTOR Input
	add_instantiation_interface q conduit INPUT
	set_instantiation_interface_parameter_value q associatedClock {}
	set_instantiation_interface_parameter_value q associatedReset {}
	set_instantiation_interface_parameter_value q prSafe {false}
	set_instantiation_interface_assignment_value q ui.blockdiagram.direction {output}
	add_instantiation_interface_port q q dataout 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface wraddress conduit INPUT
	set_instantiation_interface_parameter_value wraddress associatedClock {}
	set_instantiation_interface_parameter_value wraddress associatedReset {}
	set_instantiation_interface_parameter_value wraddress prSafe {false}
	set_instantiation_interface_assignment_value wraddress ui.blockdiagram.direction {input}
	add_instantiation_interface_port wraddress wraddress wraddress 9 STD_LOGIC_VECTOR Input
	add_instantiation_interface rdaddress conduit INPUT
	set_instantiation_interface_parameter_value rdaddress associatedClock {}
	set_instantiation_interface_parameter_value rdaddress associatedReset {}
	set_instantiation_interface_parameter_value rdaddress prSafe {false}
	set_instantiation_interface_assignment_value rdaddress ui.blockdiagram.direction {input}
	add_instantiation_interface_port rdaddress rdaddress rdaddress 9 STD_LOGIC_VECTOR Input
	add_instantiation_interface wren conduit INPUT
	set_instantiation_interface_parameter_value wren associatedClock {}
	set_instantiation_interface_parameter_value wren associatedReset {}
	set_instantiation_interface_parameter_value wren prSafe {false}
	set_instantiation_interface_assignment_value wren ui.blockdiagram.direction {input}
	add_instantiation_interface_port wren wren wren 1 STD_LOGIC Input
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	set_instantiation_interface_assignment_value clock ui.blockdiagram.direction {input}
	add_instantiation_interface_port clock clock clk 1 STD_LOGIC Input
	add_instantiation_interface rden conduit INPUT
	set_instantiation_interface_parameter_value rden associatedClock {}
	set_instantiation_interface_parameter_value rden associatedReset {}
	set_instantiation_interface_parameter_value rden prSafe {false}
	set_instantiation_interface_assignment_value rden ui.blockdiagram.direction {input}
	add_instantiation_interface_port rden rden rden 1 STD_LOGIC Input
	save_instantiation
	add_component bram_true2port ip/ip_gen/bram_true2port.ip ram_2port bram_true2port 19.2.0
	load_component bram_true2port
	set_component_parameter_value GUI_ACLR_READ_INPUT_RDADDRESS {0}
	set_component_parameter_value GUI_ACLR_READ_OUTPUT_QA {0}
	set_component_parameter_value GUI_ACLR_READ_OUTPUT_QB {0}
	set_component_parameter_value GUI_BLANK_MEMORY {0}
	set_component_parameter_value GUI_BYTE_ENABLE_A {0}
	set_component_parameter_value GUI_BYTE_ENABLE_B {0}
	set_component_parameter_value GUI_BYTE_ENABLE_WIDTH {8}
	set_component_parameter_value GUI_CLKEN_ADDRESS_STALL_A {0}
	set_component_parameter_value GUI_CLKEN_ADDRESS_STALL_B {0}
	set_component_parameter_value GUI_CLKEN_INPUT_REG_A {0}
	set_component_parameter_value GUI_CLKEN_INPUT_REG_B {0}
	set_component_parameter_value GUI_CLKEN_OUTPUT_REG_A {0}
	set_component_parameter_value GUI_CLKEN_OUTPUT_REG_B {0}
	set_component_parameter_value GUI_CLKEN_RDADDRESSSTALL {0}
	set_component_parameter_value GUI_CLKEN_READ_INPUT_REG {0}
	set_component_parameter_value GUI_CLKEN_READ_OUTPUT_REG {0}
	set_component_parameter_value GUI_CLKEN_WRADDRESSSTALL {0}
	set_component_parameter_value GUI_CLKEN_WRITE_INPUT_REG {0}
	set_component_parameter_value GUI_CLOCK_TYPE {0}
	set_component_parameter_value GUI_COHERENT_READ {0}
	set_component_parameter_value GUI_CONSTRAINED_DONT_CARE {1}
	set_component_parameter_value GUI_DATAA_WIDTH {16}
	set_component_parameter_value GUI_DIFFERENT_CLKENS {0}
	set_component_parameter_value GUI_ECCENCBYPASS {0}
	set_component_parameter_value GUI_ECC_DOUBLE {0}
	set_component_parameter_value GUI_ECC_PIPELINE {0}
	set_component_parameter_value GUI_ECC_TRIPLE {0}
	set_component_parameter_value GUI_FILE_REFERENCE {0}
	set_component_parameter_value GUI_FORCE_TO_ZERO {0}
	set_component_parameter_value GUI_INIT_FILE_LAYOUT {PORT_B}
	set_component_parameter_value GUI_INIT_SIM_TO_X {0}
	set_component_parameter_value GUI_LC_IMPLEMENTION_OPTIONS {0}
	set_component_parameter_value GUI_MAX_DEPTH {Auto}
	set_component_parameter_value GUI_MEMSIZE_BITS {256}
	set_component_parameter_value GUI_MEMSIZE_WORDS {512}
	set_component_parameter_value GUI_MEM_IN_BITS {0}
	set_component_parameter_value GUI_MIF_FILENAME {}
	set_component_parameter_value GUI_MODE {1}
	set_component_parameter_value GUI_NBE_A {1}
	set_component_parameter_value GUI_NBE_B {1}
	set_component_parameter_value GUI_OPTIMIZATION_OPTION {0}
	set_component_parameter_value GUI_PR {0}
	set_component_parameter_value GUI_QA_WIDTH {16}
	set_component_parameter_value GUI_QB_WIDTH {16}
	set_component_parameter_value GUI_Q_PORT_MODE {2}
	set_component_parameter_value GUI_RAM_BLOCK_TYPE {M20K}
	set_component_parameter_value GUI_RDEN_DOUBLE {1}
	set_component_parameter_value GUI_RDEN_SINGLE {0}
	set_component_parameter_value GUI_RDW_A_MODE {New Data}
	set_component_parameter_value GUI_RDW_B_MODE {New Data}
	set_component_parameter_value GUI_READ_INPUT_RDADDRESS {1}
	set_component_parameter_value GUI_READ_OUTPUT_QA {1}
	set_component_parameter_value GUI_READ_OUTPUT_QB {1}
	set_component_parameter_value GUI_SCLR_READ_OUTPUT_QA {0}
	set_component_parameter_value GUI_SCLR_READ_OUTPUT_QB {0}
	set_component_parameter_value GUI_TBENCH {0}
	set_component_parameter_value GUI_TDP_EMULATE {0}
	set_component_parameter_value GUI_VAR_WIDTH {0}
	set_component_parameter_value GUI_WIDTH_ECCENCPARITY {8}
	set_component_parameter_value GUI_WRITE_INPUT_PORTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation bram_true2port
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface data_a conduit INPUT
	set_instantiation_interface_parameter_value data_a associatedClock {}
	set_instantiation_interface_parameter_value data_a associatedReset {}
	set_instantiation_interface_parameter_value data_a prSafe {false}
	set_instantiation_interface_assignment_value data_a ui.blockdiagram.direction {input}
	add_instantiation_interface_port data_a data_a datain_a 16 STD_LOGIC_VECTOR Input
	add_instantiation_interface q_a conduit INPUT
	set_instantiation_interface_parameter_value q_a associatedClock {}
	set_instantiation_interface_parameter_value q_a associatedReset {}
	set_instantiation_interface_parameter_value q_a prSafe {false}
	set_instantiation_interface_assignment_value q_a ui.blockdiagram.direction {output}
	add_instantiation_interface_port q_a q_a dataout_a 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface data_b conduit INPUT
	set_instantiation_interface_parameter_value data_b associatedClock {}
	set_instantiation_interface_parameter_value data_b associatedReset {}
	set_instantiation_interface_parameter_value data_b prSafe {false}
	set_instantiation_interface_assignment_value data_b ui.blockdiagram.direction {input}
	add_instantiation_interface_port data_b data_b datain_b 16 STD_LOGIC_VECTOR Input
	add_instantiation_interface q_b conduit INPUT
	set_instantiation_interface_parameter_value q_b associatedClock {}
	set_instantiation_interface_parameter_value q_b associatedReset {}
	set_instantiation_interface_parameter_value q_b prSafe {false}
	set_instantiation_interface_assignment_value q_b ui.blockdiagram.direction {output}
	add_instantiation_interface_port q_b q_b dataout_b 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface address_a conduit INPUT
	set_instantiation_interface_parameter_value address_a associatedClock {}
	set_instantiation_interface_parameter_value address_a associatedReset {}
	set_instantiation_interface_parameter_value address_a prSafe {false}
	set_instantiation_interface_assignment_value address_a ui.blockdiagram.direction {input}
	add_instantiation_interface_port address_a address_a address_a 9 STD_LOGIC_VECTOR Input
	add_instantiation_interface address_b conduit INPUT
	set_instantiation_interface_parameter_value address_b associatedClock {}
	set_instantiation_interface_parameter_value address_b associatedReset {}
	set_instantiation_interface_parameter_value address_b prSafe {false}
	set_instantiation_interface_assignment_value address_b ui.blockdiagram.direction {input}
	add_instantiation_interface_port address_b address_b address_b 9 STD_LOGIC_VECTOR Input
	add_instantiation_interface wren_a conduit INPUT
	set_instantiation_interface_parameter_value wren_a associatedClock {}
	set_instantiation_interface_parameter_value wren_a associatedReset {}
	set_instantiation_interface_parameter_value wren_a prSafe {false}
	set_instantiation_interface_assignment_value wren_a ui.blockdiagram.direction {input}
	add_instantiation_interface_port wren_a wren_a wren_a 1 STD_LOGIC Input
	add_instantiation_interface wren_b conduit INPUT
	set_instantiation_interface_parameter_value wren_b associatedClock {}
	set_instantiation_interface_parameter_value wren_b associatedReset {}
	set_instantiation_interface_parameter_value wren_b prSafe {false}
	set_instantiation_interface_assignment_value wren_b ui.blockdiagram.direction {input}
	add_instantiation_interface_port wren_b wren_b wren_b 1 STD_LOGIC Input
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	set_instantiation_interface_assignment_value clock ui.blockdiagram.direction {input}
	add_instantiation_interface_port clock clock clk 1 STD_LOGIC Input
	add_instantiation_interface rden_a conduit INPUT
	set_instantiation_interface_parameter_value rden_a associatedClock {}
	set_instantiation_interface_parameter_value rden_a associatedReset {}
	set_instantiation_interface_parameter_value rden_a prSafe {false}
	set_instantiation_interface_assignment_value rden_a ui.blockdiagram.direction {input}
	add_instantiation_interface_port rden_a rden_a rden_a 1 STD_LOGIC Input
	add_instantiation_interface rden_b conduit INPUT
	set_instantiation_interface_parameter_value rden_b associatedClock {}
	set_instantiation_interface_parameter_value rden_b associatedReset {}
	set_instantiation_interface_parameter_value rden_b prSafe {false}
	set_instantiation_interface_assignment_value rden_b ui.blockdiagram.direction {input}
	add_instantiation_interface_port rden_b rden_b rden_b 1 STD_LOGIC Input
	save_instantiation
	add_component clock_in ip/ip_gen/ip_gen_clock_in.ip altera_clock_bridge clock_in 19.1
	load_component clock_in
	set_component_parameter_value EXPLICIT_CLOCK_RATE {50000000.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation clock_in
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {0}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock OUTPUT
	set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
	set_instantiation_interface_parameter_value out_clk clockRate {50000000}
	set_instantiation_interface_parameter_value out_clk clockRateKnown {true}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {50000000}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
	save_instantiation
	add_component dc_fifo_wrapper ip/ip_gen/dc_fifo_wrapper.ip altera_avalon_dc_fifo dc_fifo_wrapper 19.1
	load_component dc_fifo_wrapper
	set_component_parameter_value BITS_PER_SYMBOL {8}
	set_component_parameter_value CHANNEL_WIDTH {0}
	set_component_parameter_value ENABLE_EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value ERROR_WIDTH {0}
	set_component_parameter_value EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value FIFO_DEPTH {512}
	set_component_parameter_value RD_SYNC_DEPTH {3}
	set_component_parameter_value SYMBOLS_PER_BEAT {64}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_IN_FILL_LEVEL {0}
	set_component_parameter_value USE_OUT_FILL_LEVEL {0}
	set_component_parameter_value USE_PACKETS {1}
	set_component_parameter_value WR_SYNC_DEPTH {3}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dc_fifo_wrapper
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {0}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_clk_reset reset INPUT
	set_instantiation_interface_parameter_value in_clk_reset associatedClock {in_clk}
	set_instantiation_interface_parameter_value in_clk_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_clk_reset in_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock INPUT
	set_instantiation_interface_parameter_value out_clk clockRate {0}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk_reset reset INPUT
	set_instantiation_interface_parameter_value out_clk_reset associatedClock {out_clk}
	set_instantiation_interface_parameter_value out_clk_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port out_clk_reset out_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface in avalon_streaming INPUT
	set_instantiation_interface_parameter_value in associatedClock {in_clk}
	set_instantiation_interface_parameter_value in associatedReset {in_clk_reset}
	set_instantiation_interface_parameter_value in beatsPerCycle {1}
	set_instantiation_interface_parameter_value in dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in errorDescriptor {}
	set_instantiation_interface_parameter_value in firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in maxChannel {0}
	set_instantiation_interface_parameter_value in packetDescription {}
	set_instantiation_interface_parameter_value in prSafe {false}
	set_instantiation_interface_parameter_value in readyAllowance {0}
	set_instantiation_interface_parameter_value in readyLatency {0}
	set_instantiation_interface_parameter_value in symbolsPerBeat {64}
	add_instantiation_interface_port in in_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in in_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in in_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in in_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in in_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in in_empty empty 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface out avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out associatedClock {out_clk}
	set_instantiation_interface_parameter_value out associatedReset {out_clk_reset}
	set_instantiation_interface_parameter_value out beatsPerCycle {1}
	set_instantiation_interface_parameter_value out dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out errorDescriptor {}
	set_instantiation_interface_parameter_value out firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out maxChannel {0}
	set_instantiation_interface_parameter_value out packetDescription {}
	set_instantiation_interface_parameter_value out prSafe {false}
	set_instantiation_interface_parameter_value out readyAllowance {0}
	set_instantiation_interface_parameter_value out readyLatency {0}
	set_instantiation_interface_parameter_value out symbolsPerBeat {64}
	add_instantiation_interface_port out out_data data 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out out_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out out_ready ready 1 STD_LOGIC Input
	add_instantiation_interface_port out out_startofpacket startofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_endofpacket endofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_empty empty 6 STD_LOGIC_VECTOR Output
	save_instantiation
	add_component dc_fifo_wrapper_infill ip/ip_gen/dc_fifo_wrapper_infill.ip altera_avalon_dc_fifo dc_fifo_wrapper_infill 19.1
	load_component dc_fifo_wrapper_infill
	set_component_parameter_value BITS_PER_SYMBOL {8}
	set_component_parameter_value CHANNEL_WIDTH {0}
	set_component_parameter_value ENABLE_EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value ERROR_WIDTH {0}
	set_component_parameter_value EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value FIFO_DEPTH {512}
	set_component_parameter_value RD_SYNC_DEPTH {3}
	set_component_parameter_value SYMBOLS_PER_BEAT {64}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_IN_FILL_LEVEL {1}
	set_component_parameter_value USE_OUT_FILL_LEVEL {0}
	set_component_parameter_value USE_PACKETS {1}
	set_component_parameter_value WR_SYNC_DEPTH {3}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dc_fifo_wrapper_infill
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {0}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_clk_reset reset INPUT
	set_instantiation_interface_parameter_value in_clk_reset associatedClock {in_clk}
	set_instantiation_interface_parameter_value in_clk_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_clk_reset in_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock INPUT
	set_instantiation_interface_parameter_value out_clk clockRate {0}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk_reset reset INPUT
	set_instantiation_interface_parameter_value out_clk_reset associatedClock {out_clk}
	set_instantiation_interface_parameter_value out_clk_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port out_clk_reset out_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface in_csr avalon INPUT
	set_instantiation_interface_parameter_value in_csr addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value in_csr addressGroup {0}
	set_instantiation_interface_parameter_value in_csr addressSpan {8}
	set_instantiation_interface_parameter_value in_csr addressUnits {WORDS}
	set_instantiation_interface_parameter_value in_csr alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value in_csr associatedClock {in_clk}
	set_instantiation_interface_parameter_value in_csr associatedReset {in_clk_reset}
	set_instantiation_interface_parameter_value in_csr bitsPerSymbol {8}
	set_instantiation_interface_parameter_value in_csr bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value in_csr bridgesToMaster {}
	set_instantiation_interface_parameter_value in_csr burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value in_csr burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value in_csr constantBurstBehavior {false}
	set_instantiation_interface_parameter_value in_csr explicitAddressSpan {0}
	set_instantiation_interface_parameter_value in_csr holdTime {0}
	set_instantiation_interface_parameter_value in_csr interleaveBursts {false}
	set_instantiation_interface_parameter_value in_csr isBigEndian {false}
	set_instantiation_interface_parameter_value in_csr isFlash {false}
	set_instantiation_interface_parameter_value in_csr isMemoryDevice {false}
	set_instantiation_interface_parameter_value in_csr isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value in_csr linewrapBursts {false}
	set_instantiation_interface_parameter_value in_csr maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value in_csr maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value in_csr minimumReadLatency {1}
	set_instantiation_interface_parameter_value in_csr minimumResponseLatency {1}
	set_instantiation_interface_parameter_value in_csr minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value in_csr prSafe {false}
	set_instantiation_interface_parameter_value in_csr printableDevice {false}
	set_instantiation_interface_parameter_value in_csr readLatency {1}
	set_instantiation_interface_parameter_value in_csr readWaitStates {0}
	set_instantiation_interface_parameter_value in_csr readWaitTime {0}
	set_instantiation_interface_parameter_value in_csr registerIncomingSignals {false}
	set_instantiation_interface_parameter_value in_csr registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value in_csr setupTime {0}
	set_instantiation_interface_parameter_value in_csr timingUnits {Cycles}
	set_instantiation_interface_parameter_value in_csr transparentBridge {false}
	set_instantiation_interface_parameter_value in_csr waitrequestAllowance {0}
	set_instantiation_interface_parameter_value in_csr wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value in_csr writeLatency {0}
	set_instantiation_interface_parameter_value in_csr writeWaitStates {0}
	set_instantiation_interface_parameter_value in_csr writeWaitTime {0}
	set_instantiation_interface_assignment_value in_csr embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value in_csr embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value in_csr embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value in_csr embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value in_csr address_map {<address-map><slave name='in_csr' start='0x0' end='0x8' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value in_csr address_width {3}
	set_instantiation_interface_sysinfo_parameter_value in_csr max_slave_data_width {32}
	add_instantiation_interface_port in_csr in_csr_address address 1 STD_LOGIC Input
	add_instantiation_interface_port in_csr in_csr_read read 1 STD_LOGIC Input
	add_instantiation_interface_port in_csr in_csr_write write 1 STD_LOGIC Input
	add_instantiation_interface_port in_csr in_csr_readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port in_csr in_csr_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface in avalon_streaming INPUT
	set_instantiation_interface_parameter_value in associatedClock {in_clk}
	set_instantiation_interface_parameter_value in associatedReset {in_clk_reset}
	set_instantiation_interface_parameter_value in beatsPerCycle {1}
	set_instantiation_interface_parameter_value in dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in errorDescriptor {}
	set_instantiation_interface_parameter_value in firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in maxChannel {0}
	set_instantiation_interface_parameter_value in packetDescription {}
	set_instantiation_interface_parameter_value in prSafe {false}
	set_instantiation_interface_parameter_value in readyAllowance {0}
	set_instantiation_interface_parameter_value in readyLatency {0}
	set_instantiation_interface_parameter_value in symbolsPerBeat {64}
	add_instantiation_interface_port in in_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in in_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in in_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in in_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in in_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in in_empty empty 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface out avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out associatedClock {out_clk}
	set_instantiation_interface_parameter_value out associatedReset {out_clk_reset}
	set_instantiation_interface_parameter_value out beatsPerCycle {1}
	set_instantiation_interface_parameter_value out dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out errorDescriptor {}
	set_instantiation_interface_parameter_value out firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out maxChannel {0}
	set_instantiation_interface_parameter_value out packetDescription {}
	set_instantiation_interface_parameter_value out prSafe {false}
	set_instantiation_interface_parameter_value out readyAllowance {0}
	set_instantiation_interface_parameter_value out readyLatency {0}
	set_instantiation_interface_parameter_value out symbolsPerBeat {64}
	add_instantiation_interface_port out out_data data 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out out_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out out_ready ready 1 STD_LOGIC Input
	add_instantiation_interface_port out out_startofpacket startofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_endofpacket endofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_empty empty 6 STD_LOGIC_VECTOR Output
	save_instantiation
	add_component dsp ip/ip_gen/dsp.ip altera_s10_native_fixed_point_dsp dsp 19.1.0
	load_component dsp
	set_component_parameter_value accum_2nd_pipeline_clock {0}
	set_component_parameter_value accum_pipeline_clock {0}
	set_component_parameter_value accumulate_clock {0}
	set_component_parameter_value ax_clock {0}
	set_component_parameter_value ax_width {18}
	set_component_parameter_value ay_scan_in_clock {0}
	set_component_parameter_value ay_scan_in_width {18}
	set_component_parameter_value ay_use_scan_in {false}
	set_component_parameter_value az_clock {0}
	set_component_parameter_value az_width {0}
	set_component_parameter_value bx_clock {0}
	set_component_parameter_value bx_width {18}
	set_component_parameter_value by_clock {0}
	set_component_parameter_value by_use_scan_in {false}
	set_component_parameter_value by_width {18}
	set_component_parameter_value bz_clock {0}
	set_component_parameter_value bz_width {0}
	set_component_parameter_value chainout_enable {false}
	set_component_parameter_value clear_type {none}
	set_component_parameter_value clock0_show {true}
	set_component_parameter_value clock1_show {false}
	set_component_parameter_value clock2_show {false}
	set_component_parameter_value coef_a_0 {0}
	set_component_parameter_value coef_a_1 {0}
	set_component_parameter_value coef_a_2 {0}
	set_component_parameter_value coef_a_3 {0}
	set_component_parameter_value coef_a_4 {0}
	set_component_parameter_value coef_a_5 {0}
	set_component_parameter_value coef_a_6 {0}
	set_component_parameter_value coef_a_7 {0}
	set_component_parameter_value coef_b_0 {0}
	set_component_parameter_value coef_b_1 {0}
	set_component_parameter_value coef_b_2 {0}
	set_component_parameter_value coef_b_3 {0}
	set_component_parameter_value coef_b_4 {0}
	set_component_parameter_value coef_b_5 {0}
	set_component_parameter_value coef_b_6 {0}
	set_component_parameter_value coef_b_7 {0}
	set_component_parameter_value coef_sel_a_clock {0}
	set_component_parameter_value coef_sel_b_clock {0}
	set_component_parameter_value delay_scan_out_ay {false}
	set_component_parameter_value delay_scan_out_by {false}
	set_component_parameter_value enable_accumulate {false}
	set_component_parameter_value enable_chainin {false}
	set_component_parameter_value enable_clkena0 {false}
	set_component_parameter_value enable_clkena1 {false}
	set_component_parameter_value enable_clkena2 {false}
	set_component_parameter_value enable_clr0 {false}
	set_component_parameter_value enable_clr1 {false}
	set_component_parameter_value enable_double_accum {false}
	set_component_parameter_value enable_loadconst {false}
	set_component_parameter_value enable_negate {false}
	set_component_parameter_value enable_scanout {false}
	set_component_parameter_value enable_sub {false}
	set_component_parameter_value input_pipeline_clock {0}
	set_component_parameter_value input_systolic_clock {0}
	set_component_parameter_value load_const_2nd_pipeline_clock {0}
	set_component_parameter_value load_const_clock {0}
	set_component_parameter_value load_const_pipeline_clock {0}
	set_component_parameter_value load_const_value {0}
	set_component_parameter_value negate_clock {0}
	set_component_parameter_value operand_source_max {input}
	set_component_parameter_value operand_source_may {input}
	set_component_parameter_value operand_source_mbx {input}
	set_component_parameter_value operand_source_mby {input}
	set_component_parameter_value operation_mode {m18x18_sumof2}
	set_component_parameter_value output_clock {0}
	set_component_parameter_value preadder_subtract_a {+}
	set_component_parameter_value preadder_subtract_b {+}
	set_component_parameter_value result_a_width {37}
	set_component_parameter_value result_b_width {0}
	set_component_parameter_value scan_out_width {0}
	set_component_parameter_value second_pipeline_clock {0}
	set_component_parameter_value signed_max {Unsigned}
	set_component_parameter_value signed_may {Unsigned}
	set_component_parameter_value signed_mbx {Unsigned}
	set_component_parameter_value signed_mby {Unsigned}
	set_component_parameter_value sub_clock {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dsp
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface ay conduit INPUT
	set_instantiation_interface_parameter_value ay associatedClock {}
	set_instantiation_interface_parameter_value ay associatedReset {}
	set_instantiation_interface_parameter_value ay prSafe {false}
	set_instantiation_interface_assignment_value ay ui.blockdiagram.direction {input}
	add_instantiation_interface_port ay ay ay 18 STD_LOGIC_VECTOR Input
	add_instantiation_interface by conduit INPUT
	set_instantiation_interface_parameter_value by associatedClock {}
	set_instantiation_interface_parameter_value by associatedReset {}
	set_instantiation_interface_parameter_value by prSafe {false}
	set_instantiation_interface_assignment_value by ui.blockdiagram.direction {input}
	add_instantiation_interface_port by by by 18 STD_LOGIC_VECTOR Input
	add_instantiation_interface ax conduit INPUT
	set_instantiation_interface_parameter_value ax associatedClock {}
	set_instantiation_interface_parameter_value ax associatedReset {}
	set_instantiation_interface_parameter_value ax prSafe {false}
	set_instantiation_interface_assignment_value ax ui.blockdiagram.direction {input}
	add_instantiation_interface_port ax ax ax 18 STD_LOGIC_VECTOR Input
	add_instantiation_interface bx conduit INPUT
	set_instantiation_interface_parameter_value bx associatedClock {}
	set_instantiation_interface_parameter_value bx associatedReset {}
	set_instantiation_interface_parameter_value bx prSafe {false}
	set_instantiation_interface_assignment_value bx ui.blockdiagram.direction {input}
	add_instantiation_interface_port bx bx bx 18 STD_LOGIC_VECTOR Input
	add_instantiation_interface resulta conduit INPUT
	set_instantiation_interface_parameter_value resulta associatedClock {}
	set_instantiation_interface_parameter_value resulta associatedReset {}
	set_instantiation_interface_parameter_value resulta prSafe {false}
	set_instantiation_interface_assignment_value resulta ui.blockdiagram.direction {output}
	add_instantiation_interface_port resulta resulta resulta 37 STD_LOGIC_VECTOR Output
	add_instantiation_interface clk0 clock INPUT
	set_instantiation_interface_parameter_value clk0 clockRate {0}
	set_instantiation_interface_parameter_value clk0 externallyDriven {false}
	set_instantiation_interface_parameter_value clk0 ptfSchematicName {}
	set_instantiation_interface_assignment_value clk0 ui.blockdiagram.direction {input}
	add_instantiation_interface_port clk0 clk0 clk 1 STD_LOGIC Input
	add_instantiation_interface clk1 clock INPUT
	set_instantiation_interface_parameter_value clk1 clockRate {0}
	set_instantiation_interface_parameter_value clk1 externallyDriven {false}
	set_instantiation_interface_parameter_value clk1 ptfSchematicName {}
	set_instantiation_interface_assignment_value clk1 ui.blockdiagram.direction {input}
	add_instantiation_interface_port clk1 clk1 clk 1 STD_LOGIC Input
	add_instantiation_interface clk2 clock INPUT
	set_instantiation_interface_parameter_value clk2 clockRate {0}
	set_instantiation_interface_parameter_value clk2 externallyDriven {false}
	set_instantiation_interface_parameter_value clk2 ptfSchematicName {}
	set_instantiation_interface_assignment_value clk2 ui.blockdiagram.direction {input}
	add_instantiation_interface_port clk2 clk2 clk 1 STD_LOGIC Input
	add_instantiation_interface ena conduit INPUT
	set_instantiation_interface_parameter_value ena associatedClock {}
	set_instantiation_interface_parameter_value ena associatedReset {}
	set_instantiation_interface_parameter_value ena prSafe {false}
	set_instantiation_interface_assignment_value ena ui.blockdiagram.direction {input}
	add_instantiation_interface_port ena ena ena 3 STD_LOGIC_VECTOR Input
	save_instantiation
	add_component fifo_pkt_wrapper ip/ip_gen/fifo_pkt_wrapper.ip altera_avalon_sc_fifo fifo_pkt_wrapper 19.1
	load_component fifo_pkt_wrapper
	set_component_parameter_value BITS_PER_SYMBOL {8}
	set_component_parameter_value CHANNEL_WIDTH {0}
	set_component_parameter_value EMPTY_LATENCY {3}
	set_component_parameter_value ENABLE_EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value ERROR_WIDTH {0}
	set_component_parameter_value EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value FIFO_DEPTH {512}
	set_component_parameter_value SYMBOLS_PER_BEAT {64}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_ALMOST_EMPTY_IF {0}
	set_component_parameter_value USE_ALMOST_FULL_IF {0}
	set_component_parameter_value USE_FILL_LEVEL {0}
	set_component_parameter_value USE_MEMORY_BLOCKS {1}
	set_component_parameter_value USE_PACKETS {1}
	set_component_parameter_value USE_STORE_FORWARD {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation fifo_pkt_wrapper
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value debug.isTransparent {1}
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface clk_reset reset INPUT
	set_instantiation_interface_parameter_value clk_reset associatedClock {clk}
	set_instantiation_interface_parameter_value clk_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port clk_reset reset reset 1 STD_LOGIC Input
	add_instantiation_interface in avalon_streaming INPUT
	set_instantiation_interface_parameter_value in associatedClock {clk}
	set_instantiation_interface_parameter_value in associatedReset {clk_reset}
	set_instantiation_interface_parameter_value in beatsPerCycle {1}
	set_instantiation_interface_parameter_value in dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in errorDescriptor {}
	set_instantiation_interface_parameter_value in firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in maxChannel {0}
	set_instantiation_interface_parameter_value in packetDescription {}
	set_instantiation_interface_parameter_value in prSafe {false}
	set_instantiation_interface_parameter_value in readyAllowance {0}
	set_instantiation_interface_parameter_value in readyLatency {0}
	set_instantiation_interface_parameter_value in symbolsPerBeat {64}
	add_instantiation_interface_port in in_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in in_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in in_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in in_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in in_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in in_empty empty 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface out avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out associatedClock {clk}
	set_instantiation_interface_parameter_value out associatedReset {clk_reset}
	set_instantiation_interface_parameter_value out beatsPerCycle {1}
	set_instantiation_interface_parameter_value out dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out errorDescriptor {}
	set_instantiation_interface_parameter_value out firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out maxChannel {0}
	set_instantiation_interface_parameter_value out packetDescription {}
	set_instantiation_interface_parameter_value out prSafe {false}
	set_instantiation_interface_parameter_value out readyAllowance {0}
	set_instantiation_interface_parameter_value out readyLatency {0}
	set_instantiation_interface_parameter_value out symbolsPerBeat {64}
	set_instantiation_interface_assignment_value out debug.controlledBy {in}
	add_instantiation_interface_port out out_data data 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out out_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out out_ready ready 1 STD_LOGIC Input
	add_instantiation_interface_port out out_startofpacket startofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_endofpacket endofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_empty empty 6 STD_LOGIC_VECTOR Output
	save_instantiation
	add_component fifo_pkt_wrapper_infill ip/ip_gen/fifo_pkt_wrapper_infill.ip altera_avalon_sc_fifo fifo_pkt_wrapper_infill 19.1
	load_component fifo_pkt_wrapper_infill
	set_component_parameter_value BITS_PER_SYMBOL {8}
	set_component_parameter_value CHANNEL_WIDTH {0}
	set_component_parameter_value EMPTY_LATENCY {3}
	set_component_parameter_value ENABLE_EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value ERROR_WIDTH {0}
	set_component_parameter_value EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value FIFO_DEPTH {512}
	set_component_parameter_value SYMBOLS_PER_BEAT {64}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_ALMOST_EMPTY_IF {0}
	set_component_parameter_value USE_ALMOST_FULL_IF {0}
	set_component_parameter_value USE_FILL_LEVEL {1}
	set_component_parameter_value USE_MEMORY_BLOCKS {1}
	set_component_parameter_value USE_PACKETS {1}
	set_component_parameter_value USE_STORE_FORWARD {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation fifo_pkt_wrapper_infill
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value debug.isTransparent {1}
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface clk_reset reset INPUT
	set_instantiation_interface_parameter_value clk_reset associatedClock {clk}
	set_instantiation_interface_parameter_value clk_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port clk_reset reset reset 1 STD_LOGIC Input
	add_instantiation_interface csr avalon INPUT
	set_instantiation_interface_parameter_value csr addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value csr addressGroup {0}
	set_instantiation_interface_parameter_value csr addressSpan {16}
	set_instantiation_interface_parameter_value csr addressUnits {WORDS}
	set_instantiation_interface_parameter_value csr alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value csr associatedClock {clk}
	set_instantiation_interface_parameter_value csr associatedReset {clk_reset}
	set_instantiation_interface_parameter_value csr bitsPerSymbol {8}
	set_instantiation_interface_parameter_value csr bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value csr bridgesToMaster {}
	set_instantiation_interface_parameter_value csr burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value csr burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value csr constantBurstBehavior {false}
	set_instantiation_interface_parameter_value csr explicitAddressSpan {0}
	set_instantiation_interface_parameter_value csr holdTime {0}
	set_instantiation_interface_parameter_value csr interleaveBursts {false}
	set_instantiation_interface_parameter_value csr isBigEndian {false}
	set_instantiation_interface_parameter_value csr isFlash {false}
	set_instantiation_interface_parameter_value csr isMemoryDevice {false}
	set_instantiation_interface_parameter_value csr isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value csr linewrapBursts {false}
	set_instantiation_interface_parameter_value csr maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value csr maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value csr minimumReadLatency {1}
	set_instantiation_interface_parameter_value csr minimumResponseLatency {1}
	set_instantiation_interface_parameter_value csr minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value csr prSafe {false}
	set_instantiation_interface_parameter_value csr printableDevice {false}
	set_instantiation_interface_parameter_value csr readLatency {1}
	set_instantiation_interface_parameter_value csr readWaitStates {0}
	set_instantiation_interface_parameter_value csr readWaitTime {0}
	set_instantiation_interface_parameter_value csr registerIncomingSignals {false}
	set_instantiation_interface_parameter_value csr registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value csr setupTime {0}
	set_instantiation_interface_parameter_value csr timingUnits {Cycles}
	set_instantiation_interface_parameter_value csr transparentBridge {false}
	set_instantiation_interface_parameter_value csr waitrequestAllowance {0}
	set_instantiation_interface_parameter_value csr wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value csr writeLatency {0}
	set_instantiation_interface_parameter_value csr writeWaitStates {0}
	set_instantiation_interface_parameter_value csr writeWaitTime {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value csr address_map {<address-map><slave name='csr' start='0x0' end='0x10' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value csr address_width {4}
	set_instantiation_interface_sysinfo_parameter_value csr max_slave_data_width {32}
	add_instantiation_interface_port csr csr_address address 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr csr_read read 1 STD_LOGIC Input
	add_instantiation_interface_port csr csr_write write 1 STD_LOGIC Input
	add_instantiation_interface_port csr csr_readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port csr csr_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface in avalon_streaming INPUT
	set_instantiation_interface_parameter_value in associatedClock {clk}
	set_instantiation_interface_parameter_value in associatedReset {clk_reset}
	set_instantiation_interface_parameter_value in beatsPerCycle {1}
	set_instantiation_interface_parameter_value in dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in errorDescriptor {}
	set_instantiation_interface_parameter_value in firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in maxChannel {0}
	set_instantiation_interface_parameter_value in packetDescription {}
	set_instantiation_interface_parameter_value in prSafe {false}
	set_instantiation_interface_parameter_value in readyAllowance {0}
	set_instantiation_interface_parameter_value in readyLatency {0}
	set_instantiation_interface_parameter_value in symbolsPerBeat {64}
	add_instantiation_interface_port in in_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in in_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in in_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in in_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in in_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in in_empty empty 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface out avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out associatedClock {clk}
	set_instantiation_interface_parameter_value out associatedReset {clk_reset}
	set_instantiation_interface_parameter_value out beatsPerCycle {1}
	set_instantiation_interface_parameter_value out dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out errorDescriptor {}
	set_instantiation_interface_parameter_value out firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out maxChannel {0}
	set_instantiation_interface_parameter_value out packetDescription {}
	set_instantiation_interface_parameter_value out prSafe {false}
	set_instantiation_interface_parameter_value out readyAllowance {0}
	set_instantiation_interface_parameter_value out readyLatency {0}
	set_instantiation_interface_parameter_value out symbolsPerBeat {64}
	set_instantiation_interface_assignment_value out debug.controlledBy {in}
	add_instantiation_interface_port out out_data data 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out out_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out out_ready ready 1 STD_LOGIC Input
	add_instantiation_interface_port out out_startofpacket startofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_endofpacket endofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_empty empty 6 STD_LOGIC_VECTOR Output
	save_instantiation
	add_component fifo_wrapper ip/ip_gen/fifo_wrapper.ip altera_avalon_sc_fifo fifo_wrapper 19.1
	load_component fifo_wrapper
	set_component_parameter_value BITS_PER_SYMBOL {8}
	set_component_parameter_value CHANNEL_WIDTH {0}
	set_component_parameter_value EMPTY_LATENCY {3}
	set_component_parameter_value ENABLE_EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value ERROR_WIDTH {0}
	set_component_parameter_value EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value FIFO_DEPTH {512}
	set_component_parameter_value SYMBOLS_PER_BEAT {64}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_ALMOST_EMPTY_IF {0}
	set_component_parameter_value USE_ALMOST_FULL_IF {0}
	set_component_parameter_value USE_FILL_LEVEL {0}
	set_component_parameter_value USE_MEMORY_BLOCKS {1}
	set_component_parameter_value USE_PACKETS {0}
	set_component_parameter_value USE_STORE_FORWARD {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation fifo_wrapper
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value debug.isTransparent {1}
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface clk_reset reset INPUT
	set_instantiation_interface_parameter_value clk_reset associatedClock {clk}
	set_instantiation_interface_parameter_value clk_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port clk_reset reset reset 1 STD_LOGIC Input
	add_instantiation_interface in avalon_streaming INPUT
	set_instantiation_interface_parameter_value in associatedClock {clk}
	set_instantiation_interface_parameter_value in associatedReset {clk_reset}
	set_instantiation_interface_parameter_value in beatsPerCycle {1}
	set_instantiation_interface_parameter_value in dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in errorDescriptor {}
	set_instantiation_interface_parameter_value in firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in maxChannel {0}
	set_instantiation_interface_parameter_value in packetDescription {}
	set_instantiation_interface_parameter_value in prSafe {false}
	set_instantiation_interface_parameter_value in readyAllowance {0}
	set_instantiation_interface_parameter_value in readyLatency {0}
	set_instantiation_interface_parameter_value in symbolsPerBeat {64}
	add_instantiation_interface_port in in_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in in_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in in_ready ready 1 STD_LOGIC Output
	add_instantiation_interface out avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out associatedClock {clk}
	set_instantiation_interface_parameter_value out associatedReset {clk_reset}
	set_instantiation_interface_parameter_value out beatsPerCycle {1}
	set_instantiation_interface_parameter_value out dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out errorDescriptor {}
	set_instantiation_interface_parameter_value out firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out maxChannel {0}
	set_instantiation_interface_parameter_value out packetDescription {}
	set_instantiation_interface_parameter_value out prSafe {false}
	set_instantiation_interface_parameter_value out readyAllowance {0}
	set_instantiation_interface_parameter_value out readyLatency {0}
	set_instantiation_interface_parameter_value out symbolsPerBeat {64}
	set_instantiation_interface_assignment_value out debug.controlledBy {in}
	add_instantiation_interface_port out out_data data 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out out_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out out_ready ready 1 STD_LOGIC Input
	save_instantiation
	add_component fifo_wrapper_infill ip/ip_gen/fifo_wrapper_infill.ip altera_avalon_sc_fifo fifo_wrapper_infill 19.1
	load_component fifo_wrapper_infill
	set_component_parameter_value BITS_PER_SYMBOL {8}
	set_component_parameter_value CHANNEL_WIDTH {0}
	set_component_parameter_value EMPTY_LATENCY {3}
	set_component_parameter_value ENABLE_EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value ERROR_WIDTH {0}
	set_component_parameter_value EXPLICIT_MAXCHANNEL {0}
	set_component_parameter_value FIFO_DEPTH {512}
	set_component_parameter_value SYMBOLS_PER_BEAT {64}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_ALMOST_EMPTY_IF {0}
	set_component_parameter_value USE_ALMOST_FULL_IF {0}
	set_component_parameter_value USE_FILL_LEVEL {1}
	set_component_parameter_value USE_MEMORY_BLOCKS {1}
	set_component_parameter_value USE_PACKETS {0}
	set_component_parameter_value USE_STORE_FORWARD {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation fifo_wrapper_infill
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value debug.isTransparent {1}
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface clk_reset reset INPUT
	set_instantiation_interface_parameter_value clk_reset associatedClock {clk}
	set_instantiation_interface_parameter_value clk_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port clk_reset reset reset 1 STD_LOGIC Input
	add_instantiation_interface csr avalon INPUT
	set_instantiation_interface_parameter_value csr addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value csr addressGroup {0}
	set_instantiation_interface_parameter_value csr addressSpan {16}
	set_instantiation_interface_parameter_value csr addressUnits {WORDS}
	set_instantiation_interface_parameter_value csr alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value csr associatedClock {clk}
	set_instantiation_interface_parameter_value csr associatedReset {clk_reset}
	set_instantiation_interface_parameter_value csr bitsPerSymbol {8}
	set_instantiation_interface_parameter_value csr bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value csr bridgesToMaster {}
	set_instantiation_interface_parameter_value csr burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value csr burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value csr constantBurstBehavior {false}
	set_instantiation_interface_parameter_value csr explicitAddressSpan {0}
	set_instantiation_interface_parameter_value csr holdTime {0}
	set_instantiation_interface_parameter_value csr interleaveBursts {false}
	set_instantiation_interface_parameter_value csr isBigEndian {false}
	set_instantiation_interface_parameter_value csr isFlash {false}
	set_instantiation_interface_parameter_value csr isMemoryDevice {false}
	set_instantiation_interface_parameter_value csr isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value csr linewrapBursts {false}
	set_instantiation_interface_parameter_value csr maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value csr maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value csr minimumReadLatency {1}
	set_instantiation_interface_parameter_value csr minimumResponseLatency {1}
	set_instantiation_interface_parameter_value csr minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value csr prSafe {false}
	set_instantiation_interface_parameter_value csr printableDevice {false}
	set_instantiation_interface_parameter_value csr readLatency {1}
	set_instantiation_interface_parameter_value csr readWaitStates {0}
	set_instantiation_interface_parameter_value csr readWaitTime {0}
	set_instantiation_interface_parameter_value csr registerIncomingSignals {false}
	set_instantiation_interface_parameter_value csr registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value csr setupTime {0}
	set_instantiation_interface_parameter_value csr timingUnits {Cycles}
	set_instantiation_interface_parameter_value csr transparentBridge {false}
	set_instantiation_interface_parameter_value csr waitrequestAllowance {0}
	set_instantiation_interface_parameter_value csr wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value csr writeLatency {0}
	set_instantiation_interface_parameter_value csr writeWaitStates {0}
	set_instantiation_interface_parameter_value csr writeWaitTime {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value csr address_map {<address-map><slave name='csr' start='0x0' end='0x10' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value csr address_width {4}
	set_instantiation_interface_sysinfo_parameter_value csr max_slave_data_width {32}
	add_instantiation_interface_port csr csr_address address 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr csr_read read 1 STD_LOGIC Input
	add_instantiation_interface_port csr csr_write write 1 STD_LOGIC Input
	add_instantiation_interface_port csr csr_readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port csr csr_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface in avalon_streaming INPUT
	set_instantiation_interface_parameter_value in associatedClock {clk}
	set_instantiation_interface_parameter_value in associatedReset {clk_reset}
	set_instantiation_interface_parameter_value in beatsPerCycle {1}
	set_instantiation_interface_parameter_value in dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in errorDescriptor {}
	set_instantiation_interface_parameter_value in firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in maxChannel {0}
	set_instantiation_interface_parameter_value in packetDescription {}
	set_instantiation_interface_parameter_value in prSafe {false}
	set_instantiation_interface_parameter_value in readyAllowance {0}
	set_instantiation_interface_parameter_value in readyLatency {0}
	set_instantiation_interface_parameter_value in symbolsPerBeat {64}
	add_instantiation_interface_port in in_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in in_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in in_ready ready 1 STD_LOGIC Output
	add_instantiation_interface out avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out associatedClock {clk}
	set_instantiation_interface_parameter_value out associatedReset {clk_reset}
	set_instantiation_interface_parameter_value out beatsPerCycle {1}
	set_instantiation_interface_parameter_value out dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out errorDescriptor {}
	set_instantiation_interface_parameter_value out firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out maxChannel {0}
	set_instantiation_interface_parameter_value out packetDescription {}
	set_instantiation_interface_parameter_value out prSafe {false}
	set_instantiation_interface_parameter_value out readyAllowance {0}
	set_instantiation_interface_parameter_value out readyLatency {0}
	set_instantiation_interface_parameter_value out symbolsPerBeat {64}
	set_instantiation_interface_assignment_value out debug.controlledBy {in}
	add_instantiation_interface_port out out_data data 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out out_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out out_ready ready 1 STD_LOGIC Input
	save_instantiation
	add_component reset_in ip/ip_gen/ip_gen_reset_in.ip altera_reset_bridge reset_in 19.1
	load_component reset_in
	set_component_parameter_value ACTIVE_LOW_RESET {0}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation reset_in
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_reset reset INPUT
	set_instantiation_interface_parameter_value in_reset associatedClock {clk}
	set_instantiation_interface_parameter_value in_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_reset in_reset reset 1 STD_LOGIC Input
	add_instantiation_interface out_reset reset OUTPUT
	set_instantiation_interface_parameter_value out_reset associatedClock {clk}
	set_instantiation_interface_parameter_value out_reset associatedDirectReset {in_reset}
	set_instantiation_interface_parameter_value out_reset associatedResetSinks {in_reset}
	set_instantiation_interface_parameter_value out_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port out_reset out_reset reset 1 STD_LOGIC Output
	save_instantiation
	add_component rom_1port_mlab ip/ip_gen/rom_1port_mlab.ip rom_1port rom_1port_mlab 19.2.0
	load_component rom_1port_mlab
	set_component_parameter_value GUI_ADDRESSSTALL_A {0}
	set_component_parameter_value GUI_AclrAddr {0}
	set_component_parameter_value GUI_AclrOutput {0}
	set_component_parameter_value GUI_BlankMemory {1}
	set_component_parameter_value GUI_CLOCK_ENABLE_INPUT_A {0}
	set_component_parameter_value GUI_CLOCK_ENABLE_OUTPUT_A {0}
	set_component_parameter_value GUI_FILE_REFERENCE {0}
	set_component_parameter_value GUI_FORCE_TO_ZERO {0}
	set_component_parameter_value GUI_INIT_FILE_LAYOUT {PORT_A}
	set_component_parameter_value GUI_INIT_TO_SIM_X {0}
	set_component_parameter_value GUI_JTAG_ENABLED {0}
	set_component_parameter_value GUI_JTAG_ID {NONE}
	set_component_parameter_value GUI_MAXIMUM_DEPTH {0}
	set_component_parameter_value GUI_MIFfilename {}
	set_component_parameter_value GUI_NUMWORDS_A {32}
	set_component_parameter_value GUI_OPTIMIZATION_OPTION {0}
	set_component_parameter_value GUI_RAM_BLOCK_TYPE {MLAB}
	set_component_parameter_value GUI_RegAddr {1}
	set_component_parameter_value GUI_RegOutput {1}
	set_component_parameter_value GUI_SclrOutput {0}
	set_component_parameter_value GUI_SingleClock {0}
	set_component_parameter_value GUI_TBENCH {0}
	set_component_parameter_value GUI_WIDTH_A {16}
	set_component_parameter_value GUI_rden {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation rom_1port_mlab
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface q conduit INPUT
	set_instantiation_interface_parameter_value q associatedClock {}
	set_instantiation_interface_parameter_value q associatedReset {}
	set_instantiation_interface_parameter_value q prSafe {false}
	set_instantiation_interface_assignment_value q ui.blockdiagram.direction {output}
	add_instantiation_interface_port q q dataout 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface address conduit INPUT
	set_instantiation_interface_parameter_value address associatedClock {}
	set_instantiation_interface_parameter_value address associatedReset {}
	set_instantiation_interface_parameter_value address prSafe {false}
	set_instantiation_interface_assignment_value address ui.blockdiagram.direction {input}
	add_instantiation_interface_port address address address 5 STD_LOGIC_VECTOR Input
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	set_instantiation_interface_assignment_value clock ui.blockdiagram.direction {input}
	add_instantiation_interface_port clock clock clk 1 STD_LOGIC Input
	save_instantiation
	add_component rom_2port ip/ip_gen/rom_2port.ip rom_2port rom_2port 19.2.0
	load_component rom_2port
	set_component_parameter_value GUI_ACLR_READ_OUTPUT_QA {0}
	set_component_parameter_value GUI_ACLR_READ_OUTPUT_QB {0}
	set_component_parameter_value GUI_BLANK_MEMORY {1}
	set_component_parameter_value GUI_CLKEN_ADDRESS_STALL_A {0}
	set_component_parameter_value GUI_CLKEN_ADDRESS_STALL_B {0}
	set_component_parameter_value GUI_CLKEN_INPUT_REG_A {0}
	set_component_parameter_value GUI_CLKEN_INPUT_REG_B {0}
	set_component_parameter_value GUI_CLKEN_OUTPUT_REG_A {0}
	set_component_parameter_value GUI_CLKEN_OUTPUT_REG_B {0}
	set_component_parameter_value GUI_CLOCK_TYPE {0}
	set_component_parameter_value GUI_FILE_LAYOUT {PORT_B}
	set_component_parameter_value GUI_FILE_REFERENCE {0}
	set_component_parameter_value GUI_FORCE_TO_ZERO {0}
	set_component_parameter_value GUI_MAX_DEPTH {Auto}
	set_component_parameter_value GUI_MEMSIZE_BITS {256}
	set_component_parameter_value GUI_MEMSIZE_WORDS {32768}
	set_component_parameter_value GUI_MEM_IN_BITS {0}
	set_component_parameter_value GUI_MIF_FILENAME {}
	set_component_parameter_value GUI_OPTIMIZATION_OPTION {0}
	set_component_parameter_value GUI_QA_WIDTH {16}
	set_component_parameter_value GUI_QB_WIDTH {16}
	set_component_parameter_value GUI_RAM_BLOCK_TYPE {Auto}
	set_component_parameter_value GUI_RDEN_DOUBLE {0}
	set_component_parameter_value GUI_READ_OUTPUT_PORTS {1}
	set_component_parameter_value GUI_READ_OUTPUT_QA {1}
	set_component_parameter_value GUI_READ_OUTPUT_QB {1}
	set_component_parameter_value GUI_SCLR_READ_OUTPUT_QA {0}
	set_component_parameter_value GUI_SCLR_READ_OUTPUT_QB {0}
	set_component_parameter_value GUI_TBENCH {0}
	set_component_parameter_value GUI_VAR_WIDTH {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation rom_2port
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface q_a conduit INPUT
	set_instantiation_interface_parameter_value q_a associatedClock {}
	set_instantiation_interface_parameter_value q_a associatedReset {}
	set_instantiation_interface_parameter_value q_a prSafe {false}
	set_instantiation_interface_assignment_value q_a ui.blockdiagram.direction {output}
	add_instantiation_interface_port q_a q_a q_a 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface q_b conduit INPUT
	set_instantiation_interface_parameter_value q_b associatedClock {}
	set_instantiation_interface_parameter_value q_b associatedReset {}
	set_instantiation_interface_parameter_value q_b prSafe {false}
	set_instantiation_interface_assignment_value q_b ui.blockdiagram.direction {output}
	add_instantiation_interface_port q_b q_b q_b 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface address_a conduit INPUT
	set_instantiation_interface_parameter_value address_a associatedClock {}
	set_instantiation_interface_parameter_value address_a associatedReset {}
	set_instantiation_interface_parameter_value address_a prSafe {false}
	set_instantiation_interface_assignment_value address_a ui.blockdiagram.direction {input}
	add_instantiation_interface_port address_a address_a address_a 15 STD_LOGIC_VECTOR Input
	add_instantiation_interface address_b conduit INPUT
	set_instantiation_interface_parameter_value address_b associatedClock {}
	set_instantiation_interface_parameter_value address_b associatedReset {}
	set_instantiation_interface_parameter_value address_b prSafe {false}
	set_instantiation_interface_assignment_value address_b ui.blockdiagram.direction {input}
	add_instantiation_interface_port address_b address_b address_b 15 STD_LOGIC_VECTOR Input
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	set_instantiation_interface_assignment_value clock ui.blockdiagram.direction {input}
	add_instantiation_interface_port clock clock clk 1 STD_LOGIC Input
	save_instantiation
	add_component rom_2port_noreg ip/ip_gen/rom_2port_noreg.ip rom_2port rom_2port_noreg 19.2.0
	load_component rom_2port_noreg
	set_component_parameter_value GUI_ACLR_READ_OUTPUT_QA {0}
	set_component_parameter_value GUI_ACLR_READ_OUTPUT_QB {0}
	set_component_parameter_value GUI_BLANK_MEMORY {1}
	set_component_parameter_value GUI_CLKEN_ADDRESS_STALL_A {0}
	set_component_parameter_value GUI_CLKEN_ADDRESS_STALL_B {0}
	set_component_parameter_value GUI_CLKEN_INPUT_REG_A {0}
	set_component_parameter_value GUI_CLKEN_INPUT_REG_B {0}
	set_component_parameter_value GUI_CLKEN_OUTPUT_REG_A {0}
	set_component_parameter_value GUI_CLKEN_OUTPUT_REG_B {0}
	set_component_parameter_value GUI_CLOCK_TYPE {0}
	set_component_parameter_value GUI_FILE_LAYOUT {PORT_B}
	set_component_parameter_value GUI_FILE_REFERENCE {0}
	set_component_parameter_value GUI_FORCE_TO_ZERO {0}
	set_component_parameter_value GUI_MAX_DEPTH {Auto}
	set_component_parameter_value GUI_MEMSIZE_BITS {256}
	set_component_parameter_value GUI_MEMSIZE_WORDS {32768}
	set_component_parameter_value GUI_MEM_IN_BITS {0}
	set_component_parameter_value GUI_MIF_FILENAME {}
	set_component_parameter_value GUI_OPTIMIZATION_OPTION {0}
	set_component_parameter_value GUI_QA_WIDTH {16}
	set_component_parameter_value GUI_QB_WIDTH {16}
	set_component_parameter_value GUI_RAM_BLOCK_TYPE {Auto}
	set_component_parameter_value GUI_RDEN_DOUBLE {0}
	set_component_parameter_value GUI_READ_OUTPUT_PORTS {0}
	set_component_parameter_value GUI_READ_OUTPUT_QA {0}
	set_component_parameter_value GUI_READ_OUTPUT_QB {0}
	set_component_parameter_value GUI_SCLR_READ_OUTPUT_QA {0}
	set_component_parameter_value GUI_SCLR_READ_OUTPUT_QB {0}
	set_component_parameter_value GUI_TBENCH {0}
	set_component_parameter_value GUI_VAR_WIDTH {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation rom_2port_noreg
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface q_a conduit INPUT
	set_instantiation_interface_parameter_value q_a associatedClock {}
	set_instantiation_interface_parameter_value q_a associatedReset {}
	set_instantiation_interface_parameter_value q_a prSafe {false}
	set_instantiation_interface_assignment_value q_a ui.blockdiagram.direction {output}
	add_instantiation_interface_port q_a q_a q_a 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface q_b conduit INPUT
	set_instantiation_interface_parameter_value q_b associatedClock {}
	set_instantiation_interface_parameter_value q_b associatedReset {}
	set_instantiation_interface_parameter_value q_b prSafe {false}
	set_instantiation_interface_assignment_value q_b ui.blockdiagram.direction {output}
	add_instantiation_interface_port q_b q_b q_b 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface address_a conduit INPUT
	set_instantiation_interface_parameter_value address_a associatedClock {}
	set_instantiation_interface_parameter_value address_a associatedReset {}
	set_instantiation_interface_parameter_value address_a prSafe {false}
	set_instantiation_interface_assignment_value address_a ui.blockdiagram.direction {input}
	add_instantiation_interface_port address_a address_a address_a 15 STD_LOGIC_VECTOR Input
	add_instantiation_interface address_b conduit INPUT
	set_instantiation_interface_parameter_value address_b associatedClock {}
	set_instantiation_interface_parameter_value address_b associatedReset {}
	set_instantiation_interface_parameter_value address_b prSafe {false}
	set_instantiation_interface_assignment_value address_b ui.blockdiagram.direction {input}
	add_instantiation_interface_port address_b address_b address_b 15 STD_LOGIC_VECTOR Input
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	set_instantiation_interface_assignment_value clock ui.blockdiagram.direction {input}
	add_instantiation_interface_port clock clock clk 1 STD_LOGIC Input
	save_instantiation
	add_component singledsp ip/ip_gen/singledsp.ip altera_s10_native_fixed_point_dsp singledsp 19.1.0
	load_component singledsp
	set_component_parameter_value accum_2nd_pipeline_clock {0}
	set_component_parameter_value accum_pipeline_clock {0}
	set_component_parameter_value accumulate_clock {0}
	set_component_parameter_value ax_clock {0}
	set_component_parameter_value ax_width {18}
	set_component_parameter_value ay_scan_in_clock {0}
	set_component_parameter_value ay_scan_in_width {18}
	set_component_parameter_value ay_use_scan_in {false}
	set_component_parameter_value az_clock {0}
	set_component_parameter_value az_width {0}
	set_component_parameter_value bx_clock {0}
	set_component_parameter_value bx_width {0}
	set_component_parameter_value by_clock {0}
	set_component_parameter_value by_use_scan_in {false}
	set_component_parameter_value by_width {0}
	set_component_parameter_value bz_clock {0}
	set_component_parameter_value bz_width {0}
	set_component_parameter_value chainout_enable {false}
	set_component_parameter_value clear_type {none}
	set_component_parameter_value clock0_show {true}
	set_component_parameter_value clock1_show {false}
	set_component_parameter_value clock2_show {false}
	set_component_parameter_value coef_a_0 {0}
	set_component_parameter_value coef_a_1 {0}
	set_component_parameter_value coef_a_2 {0}
	set_component_parameter_value coef_a_3 {0}
	set_component_parameter_value coef_a_4 {0}
	set_component_parameter_value coef_a_5 {0}
	set_component_parameter_value coef_a_6 {0}
	set_component_parameter_value coef_a_7 {0}
	set_component_parameter_value coef_b_0 {0}
	set_component_parameter_value coef_b_1 {0}
	set_component_parameter_value coef_b_2 {0}
	set_component_parameter_value coef_b_3 {0}
	set_component_parameter_value coef_b_4 {0}
	set_component_parameter_value coef_b_5 {0}
	set_component_parameter_value coef_b_6 {0}
	set_component_parameter_value coef_b_7 {0}
	set_component_parameter_value coef_sel_a_clock {0}
	set_component_parameter_value coef_sel_b_clock {0}
	set_component_parameter_value delay_scan_out_ay {false}
	set_component_parameter_value delay_scan_out_by {false}
	set_component_parameter_value enable_accumulate {false}
	set_component_parameter_value enable_chainin {false}
	set_component_parameter_value enable_clkena0 {false}
	set_component_parameter_value enable_clkena1 {false}
	set_component_parameter_value enable_clkena2 {false}
	set_component_parameter_value enable_clr0 {false}
	set_component_parameter_value enable_clr1 {false}
	set_component_parameter_value enable_double_accum {false}
	set_component_parameter_value enable_loadconst {false}
	set_component_parameter_value enable_negate {false}
	set_component_parameter_value enable_scanout {false}
	set_component_parameter_value enable_sub {false}
	set_component_parameter_value input_pipeline_clock {0}
	set_component_parameter_value input_systolic_clock {0}
	set_component_parameter_value load_const_2nd_pipeline_clock {0}
	set_component_parameter_value load_const_clock {0}
	set_component_parameter_value load_const_pipeline_clock {0}
	set_component_parameter_value load_const_value {0}
	set_component_parameter_value negate_clock {0}
	set_component_parameter_value operand_source_max {input}
	set_component_parameter_value operand_source_may {input}
	set_component_parameter_value operand_source_mbx {input}
	set_component_parameter_value operand_source_mby {input}
	set_component_parameter_value operation_mode {m18x18_full_top}
	set_component_parameter_value output_clock {0}
	set_component_parameter_value preadder_subtract_a {+}
	set_component_parameter_value preadder_subtract_b {+}
	set_component_parameter_value result_a_width {37}
	set_component_parameter_value result_b_width {0}
	set_component_parameter_value scan_out_width {0}
	set_component_parameter_value second_pipeline_clock {0}
	set_component_parameter_value signed_max {Unsigned}
	set_component_parameter_value signed_may {Unsigned}
	set_component_parameter_value signed_mbx {Unsigned}
	set_component_parameter_value signed_mby {Unsigned}
	set_component_parameter_value sub_clock {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation singledsp
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface ay conduit INPUT
	set_instantiation_interface_parameter_value ay associatedClock {}
	set_instantiation_interface_parameter_value ay associatedReset {}
	set_instantiation_interface_parameter_value ay prSafe {false}
	set_instantiation_interface_assignment_value ay ui.blockdiagram.direction {input}
	add_instantiation_interface_port ay ay ay 18 STD_LOGIC_VECTOR Input
	add_instantiation_interface ax conduit INPUT
	set_instantiation_interface_parameter_value ax associatedClock {}
	set_instantiation_interface_parameter_value ax associatedReset {}
	set_instantiation_interface_parameter_value ax prSafe {false}
	set_instantiation_interface_assignment_value ax ui.blockdiagram.direction {input}
	add_instantiation_interface_port ax ax ax 18 STD_LOGIC_VECTOR Input
	add_instantiation_interface resulta conduit INPUT
	set_instantiation_interface_parameter_value resulta associatedClock {}
	set_instantiation_interface_parameter_value resulta associatedReset {}
	set_instantiation_interface_parameter_value resulta prSafe {false}
	set_instantiation_interface_assignment_value resulta ui.blockdiagram.direction {output}
	add_instantiation_interface_port resulta resulta resulta 37 STD_LOGIC_VECTOR Output
	add_instantiation_interface clk0 clock INPUT
	set_instantiation_interface_parameter_value clk0 clockRate {0}
	set_instantiation_interface_parameter_value clk0 externallyDriven {false}
	set_instantiation_interface_parameter_value clk0 ptfSchematicName {}
	set_instantiation_interface_assignment_value clk0 ui.blockdiagram.direction {input}
	add_instantiation_interface_port clk0 clk0 clk 1 STD_LOGIC Input
	add_instantiation_interface clk1 clock INPUT
	set_instantiation_interface_parameter_value clk1 clockRate {0}
	set_instantiation_interface_parameter_value clk1 externallyDriven {false}
	set_instantiation_interface_parameter_value clk1 ptfSchematicName {}
	set_instantiation_interface_assignment_value clk1 ui.blockdiagram.direction {input}
	add_instantiation_interface_port clk1 clk1 clk 1 STD_LOGIC Input
	add_instantiation_interface clk2 clock INPUT
	set_instantiation_interface_parameter_value clk2 clockRate {0}
	set_instantiation_interface_parameter_value clk2 externallyDriven {false}
	set_instantiation_interface_parameter_value clk2 ptfSchematicName {}
	set_instantiation_interface_assignment_value clk2 ui.blockdiagram.direction {input}
	add_instantiation_interface_port clk2 clk2 clk 1 STD_LOGIC Input
	add_instantiation_interface ena conduit INPUT
	set_instantiation_interface_parameter_value ena associatedClock {}
	set_instantiation_interface_parameter_value ena associatedReset {}
	set_instantiation_interface_parameter_value ena prSafe {false}
	set_instantiation_interface_assignment_value ena ui.blockdiagram.direction {input}
	add_instantiation_interface_port ena ena ena 3 STD_LOGIC_VECTOR Input
	save_instantiation
	add_component st_adapter_512_128 ip/ip_gen/st_adapter_512_128.ip altera_avalon_st_adapter st_adapter_512_128 19.1
	load_component st_adapter_512_128
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value inBitsPerSymbol {8}
	set_component_parameter_value inChannelWidth {0}
	set_component_parameter_value inDataWidth {512}
	set_component_parameter_value inErrorDescriptor {}
	set_component_parameter_value inErrorWidth {0}
	set_component_parameter_value inMaxChannel {0}
	set_component_parameter_value inReadyLatency {0}
	set_component_parameter_value inUseEmptyPort {1}
	set_component_parameter_value inUsePackets {1}
	set_component_parameter_value inUseReady {1}
	set_component_parameter_value inUseValid {1}
	set_component_parameter_value outChannelWidth {0}
	set_component_parameter_value outDataWidth {128}
	set_component_parameter_value outErrorDescriptor {}
	set_component_parameter_value outErrorWidth {0}
	set_component_parameter_value outMaxChannel {0}
	set_component_parameter_value outReadyLatency {0}
	set_component_parameter_value outUseEmptyPort {1}
	set_component_parameter_value outUseReady {1}
	set_component_parameter_value outUseValid {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation st_adapter_512_128
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk_0 clock INPUT
	set_instantiation_interface_parameter_value in_clk_0 clockRate {0}
	set_instantiation_interface_parameter_value in_clk_0 externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk_0 ptfSchematicName {}
	add_instantiation_interface_port in_clk_0 in_clk_0_clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_rst_0 reset INPUT
	set_instantiation_interface_parameter_value in_rst_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value in_rst_0 synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_rst_0 in_rst_0_reset reset 1 STD_LOGIC Input
	add_instantiation_interface in_0 avalon_streaming INPUT
	set_instantiation_interface_parameter_value in_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value in_0 associatedReset {in_rst_0}
	set_instantiation_interface_parameter_value in_0 beatsPerCycle {1}
	set_instantiation_interface_parameter_value in_0 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in_0 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in_0 errorDescriptor {}
	set_instantiation_interface_parameter_value in_0 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in_0 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in_0 maxChannel {0}
	set_instantiation_interface_parameter_value in_0 packetDescription {}
	set_instantiation_interface_parameter_value in_0 prSafe {false}
	set_instantiation_interface_parameter_value in_0 readyAllowance {0}
	set_instantiation_interface_parameter_value in_0 readyLatency {0}
	set_instantiation_interface_parameter_value in_0 symbolsPerBeat {64}
	add_instantiation_interface_port in_0 in_0_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in_0 in_0_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in_0 in_0_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in_0 in_0_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in_0 in_0_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in_0 in_0_empty empty 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface out_0 avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value out_0 associatedReset {in_rst_0}
	set_instantiation_interface_parameter_value out_0 beatsPerCycle {1}
	set_instantiation_interface_parameter_value out_0 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out_0 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out_0 errorDescriptor {}
	set_instantiation_interface_parameter_value out_0 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out_0 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out_0 maxChannel {0}
	set_instantiation_interface_parameter_value out_0 packetDescription {}
	set_instantiation_interface_parameter_value out_0 prSafe {false}
	set_instantiation_interface_parameter_value out_0 readyAllowance {0}
	set_instantiation_interface_parameter_value out_0 readyLatency {0}
	set_instantiation_interface_parameter_value out_0 symbolsPerBeat {16}
	add_instantiation_interface_port out_0 out_0_data data 128 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out_0 out_0_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out_0 out_0_ready ready 1 STD_LOGIC Input
	add_instantiation_interface_port out_0 out_0_startofpacket startofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out_0 out_0_endofpacket endofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out_0 out_0_empty empty 4 STD_LOGIC_VECTOR Output
	save_instantiation
	add_component st_adapter_512_256 ip/ip_gen/st_adapter_512_256.ip altera_avalon_st_adapter st_adapter_512_256 19.1
	load_component st_adapter_512_256
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value inBitsPerSymbol {8}
	set_component_parameter_value inChannelWidth {0}
	set_component_parameter_value inDataWidth {512}
	set_component_parameter_value inErrorDescriptor {}
	set_component_parameter_value inErrorWidth {0}
	set_component_parameter_value inMaxChannel {0}
	set_component_parameter_value inReadyLatency {0}
	set_component_parameter_value inUseEmptyPort {1}
	set_component_parameter_value inUsePackets {1}
	set_component_parameter_value inUseReady {1}
	set_component_parameter_value inUseValid {1}
	set_component_parameter_value outChannelWidth {0}
	set_component_parameter_value outDataWidth {256}
	set_component_parameter_value outErrorDescriptor {}
	set_component_parameter_value outErrorWidth {0}
	set_component_parameter_value outMaxChannel {0}
	set_component_parameter_value outReadyLatency {0}
	set_component_parameter_value outUseEmptyPort {1}
	set_component_parameter_value outUseReady {1}
	set_component_parameter_value outUseValid {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation st_adapter_512_256
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk_0 clock INPUT
	set_instantiation_interface_parameter_value in_clk_0 clockRate {0}
	set_instantiation_interface_parameter_value in_clk_0 externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk_0 ptfSchematicName {}
	add_instantiation_interface_port in_clk_0 in_clk_0_clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_rst_0 reset INPUT
	set_instantiation_interface_parameter_value in_rst_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value in_rst_0 synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_rst_0 in_rst_0_reset reset 1 STD_LOGIC Input
	add_instantiation_interface in_0 avalon_streaming INPUT
	set_instantiation_interface_parameter_value in_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value in_0 associatedReset {in_rst_0}
	set_instantiation_interface_parameter_value in_0 beatsPerCycle {1}
	set_instantiation_interface_parameter_value in_0 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in_0 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in_0 errorDescriptor {}
	set_instantiation_interface_parameter_value in_0 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in_0 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in_0 maxChannel {0}
	set_instantiation_interface_parameter_value in_0 packetDescription {}
	set_instantiation_interface_parameter_value in_0 prSafe {false}
	set_instantiation_interface_parameter_value in_0 readyAllowance {0}
	set_instantiation_interface_parameter_value in_0 readyLatency {0}
	set_instantiation_interface_parameter_value in_0 symbolsPerBeat {64}
	add_instantiation_interface_port in_0 in_0_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in_0 in_0_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in_0 in_0_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in_0 in_0_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in_0 in_0_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in_0 in_0_empty empty 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface out_0 avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value out_0 associatedReset {in_rst_0}
	set_instantiation_interface_parameter_value out_0 beatsPerCycle {1}
	set_instantiation_interface_parameter_value out_0 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out_0 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out_0 errorDescriptor {}
	set_instantiation_interface_parameter_value out_0 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out_0 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out_0 maxChannel {0}
	set_instantiation_interface_parameter_value out_0 packetDescription {}
	set_instantiation_interface_parameter_value out_0 prSafe {false}
	set_instantiation_interface_parameter_value out_0 readyAllowance {0}
	set_instantiation_interface_parameter_value out_0 readyLatency {0}
	set_instantiation_interface_parameter_value out_0 symbolsPerBeat {32}
	add_instantiation_interface_port out_0 out_0_data data 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out_0 out_0_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out_0 out_0_ready ready 1 STD_LOGIC Input
	add_instantiation_interface_port out_0 out_0_startofpacket startofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out_0 out_0_endofpacket endofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out_0 out_0_empty empty 5 STD_LOGIC_VECTOR Output
	save_instantiation
	add_component st_adapter_512_64 ip/ip_gen/st_adapter_512_64.ip altera_avalon_st_adapter st_adapter_512_64 19.1
	load_component st_adapter_512_64
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value inBitsPerSymbol {8}
	set_component_parameter_value inChannelWidth {0}
	set_component_parameter_value inDataWidth {512}
	set_component_parameter_value inErrorDescriptor {}
	set_component_parameter_value inErrorWidth {0}
	set_component_parameter_value inMaxChannel {0}
	set_component_parameter_value inReadyLatency {0}
	set_component_parameter_value inUseEmptyPort {1}
	set_component_parameter_value inUsePackets {1}
	set_component_parameter_value inUseReady {1}
	set_component_parameter_value inUseValid {1}
	set_component_parameter_value outChannelWidth {0}
	set_component_parameter_value outDataWidth {64}
	set_component_parameter_value outErrorDescriptor {}
	set_component_parameter_value outErrorWidth {0}
	set_component_parameter_value outMaxChannel {0}
	set_component_parameter_value outReadyLatency {0}
	set_component_parameter_value outUseEmptyPort {1}
	set_component_parameter_value outUseReady {1}
	set_component_parameter_value outUseValid {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation st_adapter_512_64
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk_0 clock INPUT
	set_instantiation_interface_parameter_value in_clk_0 clockRate {0}
	set_instantiation_interface_parameter_value in_clk_0 externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk_0 ptfSchematicName {}
	add_instantiation_interface_port in_clk_0 in_clk_0_clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_rst_0 reset INPUT
	set_instantiation_interface_parameter_value in_rst_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value in_rst_0 synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_rst_0 in_rst_0_reset reset 1 STD_LOGIC Input
	add_instantiation_interface in_0 avalon_streaming INPUT
	set_instantiation_interface_parameter_value in_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value in_0 associatedReset {in_rst_0}
	set_instantiation_interface_parameter_value in_0 beatsPerCycle {1}
	set_instantiation_interface_parameter_value in_0 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in_0 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in_0 errorDescriptor {}
	set_instantiation_interface_parameter_value in_0 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in_0 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in_0 maxChannel {0}
	set_instantiation_interface_parameter_value in_0 packetDescription {}
	set_instantiation_interface_parameter_value in_0 prSafe {false}
	set_instantiation_interface_parameter_value in_0 readyAllowance {0}
	set_instantiation_interface_parameter_value in_0 readyLatency {0}
	set_instantiation_interface_parameter_value in_0 symbolsPerBeat {64}
	add_instantiation_interface_port in_0 in_0_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in_0 in_0_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in_0 in_0_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in_0 in_0_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in_0 in_0_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in_0 in_0_empty empty 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface out_0 avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value out_0 associatedReset {in_rst_0}
	set_instantiation_interface_parameter_value out_0 beatsPerCycle {1}
	set_instantiation_interface_parameter_value out_0 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out_0 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out_0 errorDescriptor {}
	set_instantiation_interface_parameter_value out_0 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out_0 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out_0 maxChannel {0}
	set_instantiation_interface_parameter_value out_0 packetDescription {}
	set_instantiation_interface_parameter_value out_0 prSafe {false}
	set_instantiation_interface_parameter_value out_0 readyAllowance {0}
	set_instantiation_interface_parameter_value out_0 readyLatency {0}
	set_instantiation_interface_parameter_value out_0 symbolsPerBeat {8}
	add_instantiation_interface_port out_0 out_0_data data 64 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out_0 out_0_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out_0 out_0_ready ready 1 STD_LOGIC Input
	add_instantiation_interface_port out_0 out_0_startofpacket startofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out_0 out_0_endofpacket endofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out_0 out_0_empty empty 3 STD_LOGIC_VECTOR Output
	save_instantiation
	add_component st_multiplexer ip/ip_gen/st_multiplexer.ip multiplexer st_multiplexer 19.1
	load_component st_multiplexer
	set_component_parameter_value bitsPerSymbol {250}
	set_component_parameter_value errorWidth {0}
	set_component_parameter_value numInputInterfaces {2}
	set_component_parameter_value outChannelWidth {1}
	set_component_parameter_value packetScheduling {0}
	set_component_parameter_value schedulingSize {2}
	set_component_parameter_value symbolsPerBeat {1}
	set_component_parameter_value useHighBitsOfChannel {1}
	set_component_parameter_value usePackets {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation st_multiplexer
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clk}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface out avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out associatedClock {clk}
	set_instantiation_interface_parameter_value out associatedReset {reset}
	set_instantiation_interface_parameter_value out beatsPerCycle {1}
	set_instantiation_interface_parameter_value out dataBitsPerSymbol {250}
	set_instantiation_interface_parameter_value out emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out errorDescriptor {}
	set_instantiation_interface_parameter_value out firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out maxChannel {1}
	set_instantiation_interface_parameter_value out packetDescription {}
	set_instantiation_interface_parameter_value out prSafe {false}
	set_instantiation_interface_parameter_value out readyAllowance {0}
	set_instantiation_interface_parameter_value out readyLatency {0}
	set_instantiation_interface_parameter_value out symbolsPerBeat {1}
	add_instantiation_interface_port out out_data data 250 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out out_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out out_ready ready 1 STD_LOGIC Input
	add_instantiation_interface_port out out_channel channel 1 STD_LOGIC Output
	add_instantiation_interface in0 avalon_streaming INPUT
	set_instantiation_interface_parameter_value in0 associatedClock {clk}
	set_instantiation_interface_parameter_value in0 associatedReset {reset}
	set_instantiation_interface_parameter_value in0 beatsPerCycle {1}
	set_instantiation_interface_parameter_value in0 dataBitsPerSymbol {250}
	set_instantiation_interface_parameter_value in0 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in0 errorDescriptor {}
	set_instantiation_interface_parameter_value in0 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in0 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in0 maxChannel {0}
	set_instantiation_interface_parameter_value in0 packetDescription {}
	set_instantiation_interface_parameter_value in0 prSafe {false}
	set_instantiation_interface_parameter_value in0 readyAllowance {0}
	set_instantiation_interface_parameter_value in0 readyLatency {0}
	set_instantiation_interface_parameter_value in0 symbolsPerBeat {1}
	add_instantiation_interface_port in0 in0_data data 250 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in0 in0_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in0 in0_ready ready 1 STD_LOGIC Output
	add_instantiation_interface in1 avalon_streaming INPUT
	set_instantiation_interface_parameter_value in1 associatedClock {clk}
	set_instantiation_interface_parameter_value in1 associatedReset {reset}
	set_instantiation_interface_parameter_value in1 beatsPerCycle {1}
	set_instantiation_interface_parameter_value in1 dataBitsPerSymbol {250}
	set_instantiation_interface_parameter_value in1 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in1 errorDescriptor {}
	set_instantiation_interface_parameter_value in1 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in1 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in1 maxChannel {0}
	set_instantiation_interface_parameter_value in1 packetDescription {}
	set_instantiation_interface_parameter_value in1 prSafe {false}
	set_instantiation_interface_parameter_value in1 readyAllowance {0}
	set_instantiation_interface_parameter_value in1 readyLatency {0}
	set_instantiation_interface_parameter_value in1 symbolsPerBeat {1}
	add_instantiation_interface_port in1 in1_data data 250 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in1 in1_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in1 in1_ready ready 1 STD_LOGIC Output
	save_instantiation
	add_component st_multiplexer_pkt ip/ip_gen/st_multiplexer_pkt.ip multiplexer st_multiplexer_pkt 19.1
	load_component st_multiplexer_pkt
	set_component_parameter_value bitsPerSymbol {8}
	set_component_parameter_value errorWidth {0}
	set_component_parameter_value numInputInterfaces {2}
	set_component_parameter_value outChannelWidth {1}
	set_component_parameter_value packetScheduling {1}
	set_component_parameter_value schedulingSize {2}
	set_component_parameter_value symbolsPerBeat {64}
	set_component_parameter_value useHighBitsOfChannel {1}
	set_component_parameter_value usePackets {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation st_multiplexer_pkt
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clk}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface out avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out associatedClock {clk}
	set_instantiation_interface_parameter_value out associatedReset {reset}
	set_instantiation_interface_parameter_value out beatsPerCycle {1}
	set_instantiation_interface_parameter_value out dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out errorDescriptor {}
	set_instantiation_interface_parameter_value out firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out maxChannel {1}
	set_instantiation_interface_parameter_value out packetDescription {}
	set_instantiation_interface_parameter_value out prSafe {false}
	set_instantiation_interface_parameter_value out readyAllowance {0}
	set_instantiation_interface_parameter_value out readyLatency {0}
	set_instantiation_interface_parameter_value out symbolsPerBeat {64}
	add_instantiation_interface_port out out_data data 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out out_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out out_ready ready 1 STD_LOGIC Input
	add_instantiation_interface_port out out_startofpacket startofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_endofpacket endofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_empty empty 6 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out out_channel channel 1 STD_LOGIC Output
	add_instantiation_interface in0 avalon_streaming INPUT
	set_instantiation_interface_parameter_value in0 associatedClock {clk}
	set_instantiation_interface_parameter_value in0 associatedReset {reset}
	set_instantiation_interface_parameter_value in0 beatsPerCycle {1}
	set_instantiation_interface_parameter_value in0 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in0 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in0 errorDescriptor {}
	set_instantiation_interface_parameter_value in0 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in0 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in0 maxChannel {0}
	set_instantiation_interface_parameter_value in0 packetDescription {}
	set_instantiation_interface_parameter_value in0 prSafe {false}
	set_instantiation_interface_parameter_value in0 readyAllowance {0}
	set_instantiation_interface_parameter_value in0 readyLatency {0}
	set_instantiation_interface_parameter_value in0 symbolsPerBeat {64}
	add_instantiation_interface_port in0 in0_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in0 in0_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in0 in0_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in0 in0_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in0 in0_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in0 in0_empty empty 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface in1 avalon_streaming INPUT
	set_instantiation_interface_parameter_value in1 associatedClock {clk}
	set_instantiation_interface_parameter_value in1 associatedReset {reset}
	set_instantiation_interface_parameter_value in1 beatsPerCycle {1}
	set_instantiation_interface_parameter_value in1 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in1 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in1 errorDescriptor {}
	set_instantiation_interface_parameter_value in1 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in1 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in1 maxChannel {0}
	set_instantiation_interface_parameter_value in1 packetDescription {}
	set_instantiation_interface_parameter_value in1 prSafe {false}
	set_instantiation_interface_parameter_value in1 readyAllowance {0}
	set_instantiation_interface_parameter_value in1 readyLatency {0}
	set_instantiation_interface_parameter_value in1 symbolsPerBeat {64}
	add_instantiation_interface_port in1 in1_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in1 in1_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in1 in1_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in1 in1_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in1 in1_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in1 in1_empty empty 6 STD_LOGIC_VECTOR Input
	save_instantiation
	add_component st_multiplexer_pkt_3 ip/ip_gen/st_multiplexer_pkt_3.ip multiplexer st_multiplexer_pkt_3 19.1
	load_component st_multiplexer_pkt_3
	set_component_parameter_value bitsPerSymbol {8}
	set_component_parameter_value errorWidth {0}
	set_component_parameter_value numInputInterfaces {3}
	set_component_parameter_value outChannelWidth {3}
	set_component_parameter_value packetScheduling {1}
	set_component_parameter_value schedulingSize {2}
	set_component_parameter_value symbolsPerBeat {64}
	set_component_parameter_value useHighBitsOfChannel {1}
	set_component_parameter_value usePackets {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation st_multiplexer_pkt_3
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clk}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface out avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out associatedClock {clk}
	set_instantiation_interface_parameter_value out associatedReset {reset}
	set_instantiation_interface_parameter_value out beatsPerCycle {1}
	set_instantiation_interface_parameter_value out dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out errorDescriptor {}
	set_instantiation_interface_parameter_value out firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out maxChannel {7}
	set_instantiation_interface_parameter_value out packetDescription {}
	set_instantiation_interface_parameter_value out prSafe {false}
	set_instantiation_interface_parameter_value out readyAllowance {0}
	set_instantiation_interface_parameter_value out readyLatency {0}
	set_instantiation_interface_parameter_value out symbolsPerBeat {64}
	add_instantiation_interface_port out out_data data 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out out_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out out_ready ready 1 STD_LOGIC Input
	add_instantiation_interface_port out out_startofpacket startofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_endofpacket endofpacket 1 STD_LOGIC Output
	add_instantiation_interface_port out out_empty empty 6 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out out_channel channel 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface in0 avalon_streaming INPUT
	set_instantiation_interface_parameter_value in0 associatedClock {clk}
	set_instantiation_interface_parameter_value in0 associatedReset {reset}
	set_instantiation_interface_parameter_value in0 beatsPerCycle {1}
	set_instantiation_interface_parameter_value in0 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in0 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in0 errorDescriptor {}
	set_instantiation_interface_parameter_value in0 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in0 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in0 maxChannel {1}
	set_instantiation_interface_parameter_value in0 packetDescription {}
	set_instantiation_interface_parameter_value in0 prSafe {false}
	set_instantiation_interface_parameter_value in0 readyAllowance {0}
	set_instantiation_interface_parameter_value in0 readyLatency {0}
	set_instantiation_interface_parameter_value in0 symbolsPerBeat {64}
	add_instantiation_interface_port in0 in0_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in0 in0_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in0 in0_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in0 in0_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in0 in0_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in0 in0_empty empty 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in0 in0_channel channel 1 STD_LOGIC Input
	add_instantiation_interface in1 avalon_streaming INPUT
	set_instantiation_interface_parameter_value in1 associatedClock {clk}
	set_instantiation_interface_parameter_value in1 associatedReset {reset}
	set_instantiation_interface_parameter_value in1 beatsPerCycle {1}
	set_instantiation_interface_parameter_value in1 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in1 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in1 errorDescriptor {}
	set_instantiation_interface_parameter_value in1 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in1 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in1 maxChannel {1}
	set_instantiation_interface_parameter_value in1 packetDescription {}
	set_instantiation_interface_parameter_value in1 prSafe {false}
	set_instantiation_interface_parameter_value in1 readyAllowance {0}
	set_instantiation_interface_parameter_value in1 readyLatency {0}
	set_instantiation_interface_parameter_value in1 symbolsPerBeat {64}
	add_instantiation_interface_port in1 in1_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in1 in1_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in1 in1_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in1 in1_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in1 in1_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in1 in1_empty empty 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in1 in1_channel channel 1 STD_LOGIC Input
	add_instantiation_interface in2 avalon_streaming INPUT
	set_instantiation_interface_parameter_value in2 associatedClock {clk}
	set_instantiation_interface_parameter_value in2 associatedReset {reset}
	set_instantiation_interface_parameter_value in2 beatsPerCycle {1}
	set_instantiation_interface_parameter_value in2 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in2 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in2 errorDescriptor {}
	set_instantiation_interface_parameter_value in2 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in2 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in2 maxChannel {1}
	set_instantiation_interface_parameter_value in2 packetDescription {}
	set_instantiation_interface_parameter_value in2 prSafe {false}
	set_instantiation_interface_parameter_value in2 readyAllowance {0}
	set_instantiation_interface_parameter_value in2 readyLatency {0}
	set_instantiation_interface_parameter_value in2 symbolsPerBeat {64}
	add_instantiation_interface_port in2 in2_data data 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in2 in2_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in2 in2_ready ready 1 STD_LOGIC Output
	add_instantiation_interface_port in2 in2_startofpacket startofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in2 in2_endofpacket endofpacket 1 STD_LOGIC Input
	add_instantiation_interface_port in2 in2_empty empty 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in2 in2_channel channel 1 STD_LOGIC Input
	save_instantiation
	add_component user_pll ip/ip_gen/user_pll.ip altera_iopll user_pll 19.3.0
	load_component user_pll
	set_component_parameter_value gui_active_clk {0}
	set_component_parameter_value gui_c_cnt_in_src0 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src1 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src2 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src3 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src4 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src5 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src6 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src7 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src8 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_cal_code_hex_file {iossm.hex}
	set_component_parameter_value gui_cal_converge {0}
	set_component_parameter_value gui_cal_error {cal_clean}
	set_component_parameter_value gui_cascade_counter0 {0}
	set_component_parameter_value gui_cascade_counter1 {0}
	set_component_parameter_value gui_cascade_counter10 {0}
	set_component_parameter_value gui_cascade_counter11 {0}
	set_component_parameter_value gui_cascade_counter12 {0}
	set_component_parameter_value gui_cascade_counter13 {0}
	set_component_parameter_value gui_cascade_counter14 {0}
	set_component_parameter_value gui_cascade_counter15 {0}
	set_component_parameter_value gui_cascade_counter16 {0}
	set_component_parameter_value gui_cascade_counter17 {0}
	set_component_parameter_value gui_cascade_counter2 {0}
	set_component_parameter_value gui_cascade_counter3 {0}
	set_component_parameter_value gui_cascade_counter4 {0}
	set_component_parameter_value gui_cascade_counter5 {0}
	set_component_parameter_value gui_cascade_counter6 {0}
	set_component_parameter_value gui_cascade_counter7 {0}
	set_component_parameter_value gui_cascade_counter8 {0}
	set_component_parameter_value gui_cascade_counter9 {0}
	set_component_parameter_value gui_cascade_outclk_index {0}
	set_component_parameter_value gui_clk_bad {0}
	set_component_parameter_value gui_clock_name_global {0}
	set_component_parameter_value gui_clock_name_string0 {outclk0}
	set_component_parameter_value gui_clock_name_string1 {outclk1}
	set_component_parameter_value gui_clock_name_string10 {outclk10}
	set_component_parameter_value gui_clock_name_string11 {outclk11}
	set_component_parameter_value gui_clock_name_string12 {outclk12}
	set_component_parameter_value gui_clock_name_string13 {outclk13}
	set_component_parameter_value gui_clock_name_string14 {outclk14}
	set_component_parameter_value gui_clock_name_string15 {outclk15}
	set_component_parameter_value gui_clock_name_string16 {outclk16}
	set_component_parameter_value gui_clock_name_string17 {outclk17}
	set_component_parameter_value gui_clock_name_string2 {outclk2}
	set_component_parameter_value gui_clock_name_string3 {outclk3}
	set_component_parameter_value gui_clock_name_string4 {outclk4}
	set_component_parameter_value gui_clock_name_string5 {outclk5}
	set_component_parameter_value gui_clock_name_string6 {outclk6}
	set_component_parameter_value gui_clock_name_string7 {outclk7}
	set_component_parameter_value gui_clock_name_string8 {outclk8}
	set_component_parameter_value gui_clock_name_string9 {outclk9}
	set_component_parameter_value gui_clock_to_compensate {0}
	set_component_parameter_value gui_debug_mode {0}
	set_component_parameter_value gui_divide_factor_c0 {6}
	set_component_parameter_value gui_divide_factor_c1 {6}
	set_component_parameter_value gui_divide_factor_c10 {6}
	set_component_parameter_value gui_divide_factor_c11 {6}
	set_component_parameter_value gui_divide_factor_c12 {6}
	set_component_parameter_value gui_divide_factor_c13 {6}
	set_component_parameter_value gui_divide_factor_c14 {6}
	set_component_parameter_value gui_divide_factor_c15 {6}
	set_component_parameter_value gui_divide_factor_c16 {6}
	set_component_parameter_value gui_divide_factor_c17 {6}
	set_component_parameter_value gui_divide_factor_c2 {6}
	set_component_parameter_value gui_divide_factor_c3 {6}
	set_component_parameter_value gui_divide_factor_c4 {6}
	set_component_parameter_value gui_divide_factor_c5 {6}
	set_component_parameter_value gui_divide_factor_c6 {6}
	set_component_parameter_value gui_divide_factor_c7 {6}
	set_component_parameter_value gui_divide_factor_c8 {6}
	set_component_parameter_value gui_divide_factor_c9 {6}
	set_component_parameter_value gui_divide_factor_n {1}
	set_component_parameter_value gui_dps_cntr {C0}
	set_component_parameter_value gui_dps_dir {Positive}
	set_component_parameter_value gui_dps_num {1}
	set_component_parameter_value gui_dsm_out_sel {1st_order}
	set_component_parameter_value gui_duty_cycle0 {50.0}
	set_component_parameter_value gui_duty_cycle1 {50.0}
	set_component_parameter_value gui_duty_cycle10 {50.0}
	set_component_parameter_value gui_duty_cycle11 {50.0}
	set_component_parameter_value gui_duty_cycle12 {50.0}
	set_component_parameter_value gui_duty_cycle13 {50.0}
	set_component_parameter_value gui_duty_cycle14 {50.0}
	set_component_parameter_value gui_duty_cycle15 {50.0}
	set_component_parameter_value gui_duty_cycle16 {50.0}
	set_component_parameter_value gui_duty_cycle17 {50.0}
	set_component_parameter_value gui_duty_cycle2 {50.0}
	set_component_parameter_value gui_duty_cycle3 {50.0}
	set_component_parameter_value gui_duty_cycle4 {50.0}
	set_component_parameter_value gui_duty_cycle5 {50.0}
	set_component_parameter_value gui_duty_cycle6 {50.0}
	set_component_parameter_value gui_duty_cycle7 {50.0}
	set_component_parameter_value gui_duty_cycle8 {50.0}
	set_component_parameter_value gui_duty_cycle9 {50.0}
	set_component_parameter_value gui_en_adv_params {0}
	set_component_parameter_value gui_en_dps_ports {0}
	set_component_parameter_value gui_en_extclkout_ports {0}
	set_component_parameter_value gui_en_lvds_ports {Disabled}
	set_component_parameter_value gui_en_phout_ports {0}
	set_component_parameter_value gui_en_reconf {0}
	set_component_parameter_value gui_enable_cascade_in {0}
	set_component_parameter_value gui_enable_cascade_out {0}
	set_component_parameter_value gui_enable_mif_dps {0}
	set_component_parameter_value gui_enable_output_counter_cascading {0}
	set_component_parameter_value gui_enable_permit_cal {0}
	set_component_parameter_value gui_existing_mif_file_path {~/pll.mif}
	set_component_parameter_value gui_extclkout_0_source {C0}
	set_component_parameter_value gui_extclkout_1_source {C0}
	set_component_parameter_value gui_feedback_clock {Global Clock}
	set_component_parameter_value gui_fix_vco_frequency {0}
	set_component_parameter_value gui_fixed_vco_frequency {600.0}
	set_component_parameter_value gui_fixed_vco_frequency_ps {1667.0}
	set_component_parameter_value gui_frac_multiply_factor {1.0}
	set_component_parameter_value gui_fractional_cout {32}
	set_component_parameter_value gui_include_iossm {0}
	set_component_parameter_value gui_location_type {I/O Bank}
	set_component_parameter_value gui_lock_setting {Low Lock Time}
	set_component_parameter_value gui_mif_config_name {unnamed}
	set_component_parameter_value gui_mif_gen_options {Generate New MIF File}
	set_component_parameter_value gui_multiply_factor {6}
	set_component_parameter_value gui_new_mif_file_path {~/pll.mif}
	set_component_parameter_value gui_number_of_clocks {2}
	set_component_parameter_value gui_operation_mode {direct}
	set_component_parameter_value gui_output_clock_frequency0 {200.0}
	set_component_parameter_value gui_output_clock_frequency1 {400.0}
	set_component_parameter_value gui_output_clock_frequency10 {100.0}
	set_component_parameter_value gui_output_clock_frequency11 {100.0}
	set_component_parameter_value gui_output_clock_frequency12 {100.0}
	set_component_parameter_value gui_output_clock_frequency13 {100.0}
	set_component_parameter_value gui_output_clock_frequency14 {100.0}
	set_component_parameter_value gui_output_clock_frequency15 {100.0}
	set_component_parameter_value gui_output_clock_frequency16 {100.0}
	set_component_parameter_value gui_output_clock_frequency17 {100.0}
	set_component_parameter_value gui_output_clock_frequency2 {100.0}
	set_component_parameter_value gui_output_clock_frequency3 {100.0}
	set_component_parameter_value gui_output_clock_frequency4 {100.0}
	set_component_parameter_value gui_output_clock_frequency5 {100.0}
	set_component_parameter_value gui_output_clock_frequency6 {100.0}
	set_component_parameter_value gui_output_clock_frequency7 {100.0}
	set_component_parameter_value gui_output_clock_frequency8 {100.0}
	set_component_parameter_value gui_output_clock_frequency9 {100.0}
	set_component_parameter_value gui_output_clock_frequency_ps0 {5000.0}
	set_component_parameter_value gui_output_clock_frequency_ps1 {2500.0}
	set_component_parameter_value gui_output_clock_frequency_ps10 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps11 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps12 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps13 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps14 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps15 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps16 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps17 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps2 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps3 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps4 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps5 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps6 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps7 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps8 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps9 {10000.0}
	set_component_parameter_value gui_parameter_table_hex_file {seq_params_sim.hex}
	set_component_parameter_value gui_phase_shift0 {0.0}
	set_component_parameter_value gui_phase_shift1 {0.0}
	set_component_parameter_value gui_phase_shift10 {0.0}
	set_component_parameter_value gui_phase_shift11 {0.0}
	set_component_parameter_value gui_phase_shift12 {0.0}
	set_component_parameter_value gui_phase_shift13 {0.0}
	set_component_parameter_value gui_phase_shift14 {0.0}
	set_component_parameter_value gui_phase_shift15 {0.0}
	set_component_parameter_value gui_phase_shift16 {0.0}
	set_component_parameter_value gui_phase_shift17 {0.0}
	set_component_parameter_value gui_phase_shift2 {0.0}
	set_component_parameter_value gui_phase_shift3 {0.0}
	set_component_parameter_value gui_phase_shift4 {0.0}
	set_component_parameter_value gui_phase_shift5 {0.0}
	set_component_parameter_value gui_phase_shift6 {0.0}
	set_component_parameter_value gui_phase_shift7 {0.0}
	set_component_parameter_value gui_phase_shift8 {0.0}
	set_component_parameter_value gui_phase_shift9 {0.0}
	set_component_parameter_value gui_phase_shift_deg0 {0.0}
	set_component_parameter_value gui_phase_shift_deg1 {0.0}
	set_component_parameter_value gui_phase_shift_deg10 {0.0}
	set_component_parameter_value gui_phase_shift_deg11 {0.0}
	set_component_parameter_value gui_phase_shift_deg12 {0.0}
	set_component_parameter_value gui_phase_shift_deg13 {0.0}
	set_component_parameter_value gui_phase_shift_deg14 {0.0}
	set_component_parameter_value gui_phase_shift_deg15 {0.0}
	set_component_parameter_value gui_phase_shift_deg16 {0.0}
	set_component_parameter_value gui_phase_shift_deg17 {0.0}
	set_component_parameter_value gui_phase_shift_deg2 {0.0}
	set_component_parameter_value gui_phase_shift_deg3 {0.0}
	set_component_parameter_value gui_phase_shift_deg4 {0.0}
	set_component_parameter_value gui_phase_shift_deg5 {0.0}
	set_component_parameter_value gui_phase_shift_deg6 {0.0}
	set_component_parameter_value gui_phase_shift_deg7 {0.0}
	set_component_parameter_value gui_phase_shift_deg8 {0.0}
	set_component_parameter_value gui_phase_shift_deg9 {0.0}
	set_component_parameter_value gui_phout_division {1}
	set_component_parameter_value gui_pll_auto_reset {0}
	set_component_parameter_value gui_pll_bandwidth_preset {Low}
	set_component_parameter_value gui_pll_cal_done {0}
	set_component_parameter_value gui_pll_cascading_mode {adjpllin}
	set_component_parameter_value gui_pll_freqcal_en {1}
	set_component_parameter_value gui_pll_freqcal_req_flag {1}
	set_component_parameter_value gui_pll_m_cnt_in_src {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_pll_mode {Integer-N PLL}
	set_component_parameter_value gui_pll_tclk_mux_en {0}
	set_component_parameter_value gui_pll_tclk_sel {pll_tclk_m_src}
	set_component_parameter_value gui_pll_type {S10_Simple}
	set_component_parameter_value gui_pll_vco_freq_band_0 {pll_freq_clk0_disabled}
	set_component_parameter_value gui_pll_vco_freq_band_1 {pll_freq_clk1_disabled}
	set_component_parameter_value gui_prot_mode {UNUSED}
	set_component_parameter_value gui_ps_units0 {ps}
	set_component_parameter_value gui_ps_units1 {ps}
	set_component_parameter_value gui_ps_units10 {ps}
	set_component_parameter_value gui_ps_units11 {ps}
	set_component_parameter_value gui_ps_units12 {ps}
	set_component_parameter_value gui_ps_units13 {ps}
	set_component_parameter_value gui_ps_units14 {ps}
	set_component_parameter_value gui_ps_units15 {ps}
	set_component_parameter_value gui_ps_units16 {ps}
	set_component_parameter_value gui_ps_units17 {ps}
	set_component_parameter_value gui_ps_units2 {ps}
	set_component_parameter_value gui_ps_units3 {ps}
	set_component_parameter_value gui_ps_units4 {ps}
	set_component_parameter_value gui_ps_units5 {ps}
	set_component_parameter_value gui_ps_units6 {ps}
	set_component_parameter_value gui_ps_units7 {ps}
	set_component_parameter_value gui_ps_units8 {ps}
	set_component_parameter_value gui_ps_units9 {ps}
	set_component_parameter_value gui_refclk1_frequency {100.0}
	set_component_parameter_value gui_refclk_might_change {0}
	set_component_parameter_value gui_refclk_switch {0}
	set_component_parameter_value gui_reference_clock_frequency {100.0}
	set_component_parameter_value gui_reference_clock_frequency_ps {10000.0}
	set_component_parameter_value gui_skip_sdc_generation {0}
	set_component_parameter_value gui_switchover_delay {0}
	set_component_parameter_value gui_switchover_mode {Automatic Switchover}
	set_component_parameter_value gui_use_NDFB_modes {0}
	set_component_parameter_value gui_use_coreclk {0}
	set_component_parameter_value gui_use_locked {1}
	set_component_parameter_value gui_use_logical {0}
	set_component_parameter_value gui_usr_device_speed_grade {1}
	set_component_parameter_value gui_vco_frequency {600.0}
	set_component_parameter_value hp_qsys_scripting_mode {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation user_pll
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.dts.compatible {altr,pll}
	set_instantiation_assignment_value embeddedsw.dts.group {clock}
	set_instantiation_assignment_value embeddedsw.dts.vendor {altr}
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {}
	set_instantiation_interface_parameter_value reset synchronousEdges {NONE}
	set_instantiation_interface_assignment_value reset ui.blockdiagram.direction {input}
	add_instantiation_interface_port reset rst reset 1 STD_LOGIC Input
	add_instantiation_interface refclk clock INPUT
	set_instantiation_interface_parameter_value refclk clockRate {100000000}
	set_instantiation_interface_parameter_value refclk externallyDriven {false}
	set_instantiation_interface_parameter_value refclk ptfSchematicName {}
	set_instantiation_interface_assignment_value refclk ui.blockdiagram.direction {input}
	add_instantiation_interface_port refclk refclk clk 1 STD_LOGIC Input
	add_instantiation_interface locked conduit INPUT
	set_instantiation_interface_parameter_value locked associatedClock {}
	set_instantiation_interface_parameter_value locked associatedReset {}
	set_instantiation_interface_parameter_value locked prSafe {false}
	set_instantiation_interface_assignment_value locked ui.blockdiagram.direction {output}
	add_instantiation_interface_port locked locked export 1 STD_LOGIC Output
	add_instantiation_interface outclk0 clock OUTPUT
	set_instantiation_interface_parameter_value outclk0 associatedDirectClock {}
	set_instantiation_interface_parameter_value outclk0 clockRate {200000000}
	set_instantiation_interface_parameter_value outclk0 clockRateKnown {true}
	set_instantiation_interface_parameter_value outclk0 externallyDriven {false}
	set_instantiation_interface_parameter_value outclk0 ptfSchematicName {}
	set_instantiation_interface_assignment_value outclk0 ui.blockdiagram.direction {output}
	set_instantiation_interface_sysinfo_parameter_value outclk0 clock_rate {200000000}
	add_instantiation_interface_port outclk0 outclk_0 clk 1 STD_LOGIC Output
	add_instantiation_interface outclk1 clock OUTPUT
	set_instantiation_interface_parameter_value outclk1 associatedDirectClock {}
	set_instantiation_interface_parameter_value outclk1 clockRate {400000000}
	set_instantiation_interface_parameter_value outclk1 clockRateKnown {true}
	set_instantiation_interface_parameter_value outclk1 externallyDriven {false}
	set_instantiation_interface_parameter_value outclk1 ptfSchematicName {}
	set_instantiation_interface_assignment_value outclk1 ui.blockdiagram.direction {output}
	set_instantiation_interface_sysinfo_parameter_value outclk1 clock_rate {400000000}
	add_instantiation_interface_port outclk1 outclk_1 clk 1 STD_LOGIC Output
	save_instantiation

	# add wirelevel expressions

	# add the connections
	add_connection clock_in.out_clk/reset_in.clk
	set_connection_parameter_value clock_in.out_clk/reset_in.clk clockDomainSysInfo {-1}
	set_connection_parameter_value clock_in.out_clk/reset_in.clk clockRateSysInfo {50000000.0}
	set_connection_parameter_value clock_in.out_clk/reset_in.clk clockResetSysInfo {}
	set_connection_parameter_value clock_in.out_clk/reset_in.clk resetDomainSysInfo {-1}

	# add the exports
	set_interface_property clk EXPORT_OF clock_in.in_clk
	set_interface_property reset EXPORT_OF reset_in.in_reset

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="bram_1port">
  <datum __value="_sortIndex" value="11" type="int" />
 </element>
 <element __value="bram_dc_diff_width">
  <datum __value="_sortIndex" value="12" type="int" />
 </element>
 <element __value="bram_simple2port">
  <datum __value="_sortIndex" value="13" type="int" />
 </element>
 <element __value="bram_true2port">
  <datum __value="_sortIndex" value="14" type="int" />
 </element>
 <element __value="clock_in">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
 <element __value="dc_fifo_wrapper">
  <datum __value="_sortIndex" value="6" type="int" />
 </element>
 <element __value="dc_fifo_wrapper_infill">
  <datum __value="_sortIndex" value="7" type="int" />
 </element>
 <element __value="dsp">
  <datum __value="_sortIndex" value="22" type="int" />
 </element>
 <element __value="fifo_pkt_wrapper">
  <datum __value="_sortIndex" value="3" type="int" />
 </element>
 <element __value="fifo_pkt_wrapper_infill">
  <datum __value="_sortIndex" value="2" type="int" />
 </element>
 <element __value="fifo_wrapper">
  <datum __value="_sortIndex" value="4" type="int" />
 </element>
 <element __value="fifo_wrapper_infill">
  <datum __value="_sortIndex" value="5" type="int" />
 </element>
 <element __value="reset_in">
  <datum __value="_sortIndex" value="1" type="int" />
 </element>
 <element __value="rom_1port_mlab">
  <datum __value="_sortIndex" value="8" type="int" />
 </element>
 <element __value="rom_2port">
  <datum __value="_sortIndex" value="9" type="int" />
 </element>
 <element __value="rom_2port_noreg">
  <datum __value="_sortIndex" value="10" type="int" />
 </element>
 <element __value="singledsp">
  <datum __value="_sortIndex" value="21" type="int" />
 </element>
 <element __value="st_adapter_512_128">
  <datum __value="_sortIndex" value="16" type="int" />
 </element>
 <element __value="st_adapter_512_256">
  <datum __value="_sortIndex" value="15" type="int" />
 </element>
 <element __value="st_adapter_512_64">
  <datum __value="_sortIndex" value="17" type="int" />
 </element>
 <element __value="st_multiplexer">
  <datum __value="_sortIndex" value="18" type="int" />
 </element>
 <element __value="st_multiplexer_pkt">
  <datum __value="_sortIndex" value="19" type="int" />
 </element>
 <element __value="st_multiplexer_pkt_3">
  <datum __value="_sortIndex" value="20" type="int" />
 </element>
 <element __value="user_pll">
  <datum __value="_sortIndex" value="23" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {ip_gen.qsys}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {ip_gen}

	# save the system
	sync_sysinfo_parameters
	save_system ip_gen
}

# create all the systems, from bottom up
do_create_ip_gen
