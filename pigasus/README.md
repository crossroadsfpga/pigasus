# Pigasus

Pigasus has a hardware component, that runs on an FPGA, and a software component which is adapted from [Snort3](https://github.com/snort3/snort3). The current version requires a host with a multi-core CPU and an [Intel Stratix 10 MX FPGA](https://www.intel.com/content/www/us/en/programmable/products/boards_and_kits/dev-kits/altera/kit-s10-mx.html) (with 100Gb Ethernet). Note that Pigasus was initially built for Engineering Sample Board with the part number 1SM21BHU2F53E2VGS1. We have updated the scripts to support the Production Board with the part number 1SM21BHU2F53E1VG. The instructions that follow assume the system runs Ubuntu 16.04. They may be slightly different for other distributions.

## Build Pigasus
### Hardware Development Requirements

To build Pigasus you will need Quartus. We highly recommend running RTL simulation of Pigasus before testing it on real system. Here we use Modelsim-SE (requires license) as our simulation tool. We do not recommend using the Modelsim-Altera_Start_Edition (Modelsim-ASE) -- the free version that comes with Quartus -- to simulate Pigasus, as Pigasus exceeds the line limit of Modelsim-ASE, which leads to extremely slow simulation. We have not tested other simulation tools like VCS.

Download and install [Quartus 19.3](https://fpgasoftware.intel.com/19.3/?edition=pro) and the Stratix 10 device support (same link). You need Quartus in order to generate necessary IP files for RTL simulation, synthesize the design and test FPGA hardware. 

Add the following to your `~/.bashrc` or equivalent. Make sure that you set `quartus_dir` to the quartus installation directory:
```bash
#### MAKE SURE THIS POINTS TO THE PIGASUS REPOSITORY
export pigasus_rep_dir=$HOME/pigasus # We assume the pigasus repo is at the home dir, by default
#### MAKE SURE THIS POINTS TO THE QUARTUS INSTALLATION DIRECTORY
export quartus_dir=
####################################################
export INTELFPGAOCLSDKROOT="$quartus_dir/19.3/hld"
export QUARTUS_ROOTDIR="$quartus_dir/19.3/quartus"
export QSYS_ROOTDIR="$quartus_dir/19.3/qsys/bin"
export IP_ROOTDIR="$quartus_dir/19.3/ip/"
export PATH=$quartus_dir/19.3/quartus/bin:$PATH
export PATH=$quartus_dir/19.3/modelsim_ase/linuxaloem:$PATH
export PATH=$quartus_dir/19.3/quartus/sopc_builder/bin:$PATH
```

Make sure these changes are applied:

```bash
source ~/.bashrc
```

Then follow the next steps to prepare the RTL code for simulation and synthesis. Before setting up the simulation and synthesis, if you have not yet generated the IP cores (only need to do it once), do:
```bash
cd $pigasus_rep_dir/pigasus/hardware/scripts/
./run_ipgen.sh
```

Simulation Setup:
1. Compile Quartus 19.3 IP library for RTL simulation. Open Quartus 19.3. Select "Launch Simulation Library Compiler" under the "Tools" Tab. Select "ModelSim" as the "Tool name" and specify the path for "Executable location." Then select "Stratix 10" as Library families. Specify the output directory and click "Start Compilation".
2. Add the compiled library path as the environment variable, by `export SIM_LIB_PATH=your_install_path/sim_lib/verilog_libs`

### RTL Simulation

Before you synthesize your changes and run them on the FPGA, you should verify your design using RTL simulation. The simulation testbed does not include the Ethernet IP core, PCIe IP core, and full matcher on CPU. The `testbench.sv` drives the FPGA datapth, including parser, TCP Reassembly, fast pattern matcher, port group matcher, and non-fast-pattern matcher (please see [Pigasus components](hardware/README.md) for more details) by dumping the converted pcap file. Once the simulation finishes, the testbench will report statistics of FPGA datapth to help developers verify functionality and diagnose any performance bottlenecks. The following instructions assume that you have Modelsim installed. 

Go to the input generator and convert the example pcap into a pkt format, that can be used as input for the simulation:

```bash
cd $pigasus_rep_dir/pigasus/hardware/rtl_sim/input_gen/
./run.sh ./m10_100.pcap
cd ..
```

Now run the simulation using Modelsim and your newly generated input:
```bash
./run_vsim.sh ./input_gen/output.pkt
```

After the simulation, you should expect the key counter values to match up with the `input_gen/example_expected_res`

We also provide an example script `run_vsim.bat` for Windows users. Please set up the `SIM_LIB_PATH` and the RTL simulator environment variables before running this script in cmd or powershell. 

Tips:
To enable GUI mode in Modelsim, comment the last line of `run_vsim.sh` and uncomment the line under "GUI full debug."
We also provide another test case (test_case2). You can replace the output.pkt. 


### Hardware Synthesis
Create Quartus project
```bash
cd $pigasus_rep_dir/pigasus/hardware/scripts/
./run_quartus_create.sh
```

Generate the bitstream. This step could take a few hours. We suggest running this step using a multi-core CPU with a large memory (e.g., 64GB). This step can also be done in Quartus GUI manually. 
```bash
cd $pigasus_rep_dir/pigasus/hardware/scripts/
./run_quartus_synth.sh
```


### Software Configuration

Software component is only necessary when running Pigasus in real system. We suggest running Pigasus hardware component in isolation first before installing software component. Please see [Hardware-only Test](#Hardware-only Test). 
To install software component, add the following to your `~/.bashrc` or equivalent, make sure you set the `pigasus_rep_dir` variable to point to the Pigasus repository you just cloned:

```bash
export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

# this is installing snort with pigasus on your home dir, you can specify another location if you want
export installation_path_pigasus=$HOME/pigasus_install

export LUA_PATH="$installation_path_pigasus/include/snort/lua/?.lua;;"

export SNORT_LUA_PATH="$pigasus_rep_dir/pigasus/software/lua"
export LUA_CONFIG_FILE="$SNORT_LUA_PATH/snort.lua"

alias pigasus="taskset --cpu-list 0 $installation_path_pigasus/bin/snort"

# ensure that aliases also work when using sudo
alias sudo='sudo '
```

Make sure these changes are applied:

```bash
source ~/.bashrc
```

To ensure that the Lua variables are passed to sudo open the sudoers config file with:

```bash
sudo visudo
```

And add the following line to the opened file:

```
Defaults env_keep += "LUA_PATH SNORT_LUA_PATH"
```

Save and close the file.

Then install the dependencies using the provided script:

```bash
cd $pigasus_rep_dir
./pigasus/install_deps.sh
```

Then build software:

```bash
cd $pigasus_rep_dir/pigasus/software
./configure_cmake.sh --prefix=$installation_path_pigasus --enable-pigasus --enable-tsc-clock --builddir=build_pigasus
cd build_pigasus
make -j $(nproc) install
```



## Running Pigasus
Below is based on an example setup with two machines. One hosts Pigasus (Intel Stratix 10 MX FPGA + Full Matcher running on CPU), the other generates packets. We use DPDK pkt-gen to push empirical traces to the attached 100G Mellanox NIC. The Mellanox NIC is connected back-to-back with the Pigasus FPGA through a 100Gb cable. Pigasus 2.0 design uses Ethernet Port 0 (the bottom Port that is close to PCIe connector). Note that Pigasus 1.0 design uses Ethernet Port 1 by default. 

### Hardware-only Test

We provide an easy way to just exercise the FPGA datapath without interacting with the software. In this case, you don't need to install and run the software. 

Load the bitstream to the Intel MX development kit.
```bash
cd $pigasus_rep_dir/pigasus/hardware/hw_test
./load_bitstream.sh
```

Note that the JTAG system console should be closed when loading the bitstream and the USB port number should be adjusted according to the machine.

Once the system finishes booting, run the JTAG system console with:
```bash
cd $pigasus_rep_dir/pigasus/hardware/hw_test
./run_console
```

After the console starts, run:
```
source path.tcl
```

> It may return some error the first time. Exit it using Ctrl-C. Then relaunch the console (`./run_console`) and rerun `source path.tcl`.

In the tcl console, you will need to type some tcl commands.

```
disable_pcie
get_results
```

This would return all 0 as no packets have been sent at this point. You may consider leaving the tcl console open while you run Pigasus to let you check the counters. Once you are ready to exit it, use Ctrl-C.


Start the packet generator in the other machine (here we use `m10_100.pcap` in $pigasus_rep_dir/pigasus/hardware/rtl_sim/input_gen as the example pcap):
```
cp example.pcap /dev/shm/test.pcap
cd dpdk/pktgen-dpdk/
./run_pktgen.sh
```
> Refer to the [DPDK Pktgen docs](https://pktgen-dpdk.readthedocs.io/en/latest/index.html) for details on how to run it.

Remember to set the number of packets to match the pcap, otherwise the packet generator sends the pcap repeatedly, and set the rate. Y = 1 means 1 Gbps.
```
set 0 count X
set 0 rate Y
str
```

After the packet generator finishes sending the number of packets that you specified, recheck the counters on the FPGA using the tcl console:
```
## recheck the top counters, you can see the recv pkts, processed pkts and dma pkts.
get_results
```

If you are using our sample rule and pcap (`m10_100.pcap`). You should expect to see the results below.
```
IN_PKT: 100
PROCESSED_PKT: 100
DMA_PKT: 10
```

Note that since the software is not installed. The `DMA_PKT` will be discarded in this experiment. 
This is a faster way to get the FPGA running and an effective way to isolate any potential hardware/software integration issues. 

### Full system test
Once both the software and hardware components are configured, you can run full system test.


After the bitstream finishes loading, reboot the machine to allow the PCIe core on the FPGA be recognized by the system:
```bash
sudo reboot
```

Once the system finishes booting, run the JTAG system console with:
```bash
cd $pigasus_rep_dir/pigasus/hardware/hw_test
./run_console
```

After the console starts, run:
```
source path.tcl
```

In the tcl console, set the buffer size:
```
set_buf_size 262143
```

And set the number of cores:
```
set_core_num 1
```

You can also verify the FPGA counter stats with:
```
get_results
```


To run the software, first insert the kernel module:
```bash
cd $pigasus_rep_dir/pigasus/software/src/pigasus/pcie/kernel/linux
sudo ./install
```

Then execute the software application, specifying the `snort.lua` configuration file and the rule_list file (specifying the `sid` of the rules are used). We only provide a sample rule as the Snort Registered Rules requires registration on [Snort](https://www.snort.org/downloads). This sample rule will be triggered 10 times by our sample trace `$pigasus_rep_dir/hardware/rtl_sim/input_gen/m10_100.pcap`.
```bash
cd $pigasus_rep_dir/pigasus/software/lua
sudo pigasus -c snort.lua --patterns ./rule_list
```

Run following commands on the packet generator in the other machine:
```
cp example.pcap /dev/shm/test.pcap
cd dpdk/pktgen-dpdk/
./run_pktgen.sh
```

Remember to set the number of packets to match the pcap, otherwise the packet generator sends the pcap repeatedly, and set the rate. Y = 1 means 1 Gbps.
```
set 0 count X
set 0 rate Y
str
```

After the packet generator finishes sending the number of packets that you specified, recheck the counters on the FPGA using the tcl console:
```
## recheck the top counters, you can see the recv pkts, processed pkts and dma pkts.
get_results
```

If you are using our sample rule and pcap (`m10_100.pcap`). You should expect to see the results below.
```
IN_PKT: 100
PROCESSED_PKT: 100
DMA_PKT: 10
```

Now exit the software application with Ctrl-C. You should expect to see that the number of `rx_pkt` should match up the `DMA_PKT`. 
