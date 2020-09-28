# Pigasus

<img align="right" width="200" src="./pigasus_logo.png">

Pigasus is an Intrusion Detection and Prevention System (ID/PS) that achieves 100Gbps using a single FPGA-equipped server. Pigasus's FPGA-first design ensures that most packets are processed entirely using the FPGA, while some packets are sent to the CPU for full evaluation. Refer to the OSDI '20 paper for details about the design.

If you have already configured your system and wants to run Pigasus, you can skip directly to [Running Pigasus](#running-pigasus).

## Getting Started

Pigasus has a hardware component, that runs on an FPGA, and a software component which is adapted from [Snort3](https://github.com/snort3/snort3). The current version requires a host with a multi-core CPU and an [Intel Stratix 10 MX FPGA](https://www.intel.com/content/www/us/en/programmable/products/boards_and_kits/dev-kits/altera/kit-s10-mx.html) (with 100Gb Ethernet). The instructions that follow assume the system runs Ubuntu 16.04. They may be slightly different for other distributions.

To start, clone this repository:
```bash
git clone https://github.com/cmu-snap/pigasus.git
```

If you just want to do RTL simulation, please jump to [Developing Pigasus](#developing-pigasus). The [Software Configuration](#software-configuration) is only necessary for running Pigasus in real system. 

### Software Configuration

To start, add the following to your `~/.bashrc` or equivalent, make sure you set the `pigasus_rep_dir` variable to point to the Pigasus repository you just cloned:

```bash
#### MAKE SURE THIS POINTS TO THE PIGASUS REPOSITORY
export pigasus_rep_dir=$HOME/pigasus # We assume the pigasus repo is at the home dir, by default
####################################################

export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

# this is installing snort with pigasus on your home dir, you can specify another location if you want
export installation_path_pigasus=$HOME/pigasus_install

export LUA_PATH="$installation_path_pigasus/include/snort/lua/?.lua;;"

export SNORT_LUA_PATH="$pigasus_rep_dir/lua"
export LUA_CONFIG_FILE="$SNORT_LUA_PATH/snort.lua"

alias pigasus="taskset --cpu-list 0 $installation_path_pigasus/bin/snort"

# ensure that aliases also work when using sudo
alias sudo='sudo '
```

Make sure these changes are applied:

```bash
source ~/.bashrc
```

Install the dependencies available through packages:
```bash
sudo apt update
sudo apt install build-essential cmake libhwloc-dev luajit libluajit-5.1-dev \
    openssl libpcap0.8-dev libpcre3-dev pkg-config zlib1g libtool libhyperscan-dev
```

Then install `libdaq`:
```bash
git clone https://github.com/snort3/libdaq.git
cd libdaq
git checkout 2.x
./bootstrap
./configure
make
sudo make install
cd ..
```

And install `libdnet`:
```bash
git clone https://github.com/dugsong/libdnet.git
cd libdnet
./configure
make
sudo make install
cd ..
```

### Building Software

```bash
sudo ldconfig -v
cd pigasus/software
./configure_cmake.sh --prefix=$installation_path_pigasus --enable-pigasus --enable-tsc-clock --builddir=build_pigasus
cd build_pigasus
make -j $(nproc) install
```

### Hardware Configuration

*This assumes that you already have a bitstream to load on the FPGA. For instructions on how to synthesize the design and generate the bitstream refer to the [development guide](#developing-pigasus).*

Download and install [Quartus 19.3](https://fpgasoftware.intel.com/19.3/?edition=pro) and the Stratix 10 device support (same link). You need Quartus in order to load the bitstream into the FPGA.

Add the following to your `~/.bashrc` or equivalent. Make sure that you set `quartus_dir` to the quartus installation directory:
```bash
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

## Running Pigasus

Once both the software and hardware components are configured, you can run Pigasus by loading the bitstream and then running the software.

To load the bitstream, ensure that you have a `.sof` file (bitstream file), that was handled to you or that you compiled [using the Quartus project](#hardware-synthesis). 

Then, copy the `.sof` file to `pigasus/hardware/hw_test/` and load the bitstream with:
```bash
cd $pigasus_rep_dir/hardware/hw_test
./load_bitstream.sh
```

Note that the JTAG system console should be closed when loading the bitstream. And the USB port number should be adjusted according to the machine.

After the bitstream finishes loading, reboot the machine:
```bash
sudo reboot
```

The PCIe core on the FPGA will be recognized after the reboot.

Once the system finishes booting, run the JTAG system console with:
```bash
cd $pigasus_rep_dir/hardware/hw_test
./run_console
```

After the console starts, run:
```
source path.tcl
```

> It may return some error the first time. Exit it using Ctrl-C. Then relaunch the console (`./run_console`) and rerun `source path.tcl`.

In the tcl console, you will need to type some tcl commands. We built our tcl infrastructure on top of the Ethernet design example "hwtest." In this repo, we only provide our `stats.tcl` file. The files in "hwtest" of the design example are not provided due to copyright.

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

You may consider leaving the tcl console open while you run Pigasus, to be let you check the counters. Once you are ready to exit it, use Ctrl-C.

To run the software, first insert the kernel module:
```bash
cd $pigasus_rep_dir/software/src/pigasus/pcie/kernel/linux
sudo ./install
```

Then execute the software application, specifying the `snort.lua` configuration file and the rule_list file (specifying which rule is used). We do not provide rule set as it requires registration on [Snort](https://www.snort.org/downloads). 
```bash
cd $pigasus_rep_dir/software/lua
sudo pigasus -c snort.lua --patterns ~/rule_list
```

### Example using DPDK pktgen

We provide an example setup with two machines. One hosts Pigasus (Intel Stratix 10 MX FPGA + Full Matcher running on CPU), the other generates packets. We use DPDK pkt-gen to push empirical traces to the attached 100G Mellanox NIC. The Mellanox NIC is connected back-to-back with the Pigasus FPGA through a 100Gb cable. 

Follow the [instructions to run Pigasus](#running-pigasus) and then start the packet generator in the other machine:
```
cp example.pcap /dev/shm/test.pcap
cd dpdk/pktgen-dpdk/
./run_pktgen.sh
```
> Refer to the [DPDK Pktgen docs](https://pktgen-dpdk.readthedocs.io/en/latest/index.html) for details on how to run it.

Remember to set the number of packets to match the pcap. Otherwise the packet generator sends the pcap repeatedly. And set the rate. Y = 1 means 1 Gbps.
```
set 0 count X
set 0 rate Y
str
```

After the packet generator finishes sending the number of packets that you specified, recheck the counters on the FPGA using the tcl console:
```
## recheck the top counters, you can see the recv pkts, processed pkts and dma pkts.
get_top_stats 
```

Now exit the software application, with Ctrl-C. You should expect to see the number of `rx_pkt` should match up the dma pkts. 


## Developing Pigasus

New developers may find a description of each hardware component [here](hardware/README.md).

### Hardware Development Requirements

To change the hardware component of Pigasus you will need Quartus as well as an RTL simulation tool. Here we use Modelsim-SE (requires license) as our simulation tool. We do not recommend using the Modelsim-Altera_Start_Edition (Modelsim-ASE) -- the free version that comes with Quartus -- to simulate Pigasus, as Pigasus exceeds the line limit of Modelsim-ASE, which leads to extremely slow simulation. We have not tested other simulation tools like VCS.

If you have not yet installed Quartus, download and install [Quartus 19.3](https://fpgasoftware.intel.com/19.3/?edition=pro) and the Stratix 10 device support (same link). Then follow the next steps to prepare the RTL code for simulation and synthesis.

Simulation Setup:
1. Compile Quartus 19.3 IP library for RTL simulation. Open Quartus 19.3. Select "Launch Simulation Library Compiler" under the "Tools" Tab. Select "ModelSim" as the "Tool name" and specify the path for "Executable location." Then select "Stratix 10" as Library families. Specify the output directory and click "Start Compilation".
2. Add compiled library path as enviroment variable, by `export SIM_LIB_PATH=your_install_path/sim_lib/verilog_libs`
3. Generate IP cores used in RTL simulation from Quartus, including 1-PORT RAM, 2-PORT RAM, 2-PORT ROM, Avalon-ST Adapter, Avalon-ST Multiplexer, Avalon-ST Dual Clock FIFO, Avalon-ST Single Clock FIFO, Native Fixed Point DSP. Copy the generated files to `pigasus/hardware/rtl_sim/common/`.

Synthesis Setup:
1. Generate the IP blocks used in Pigasus. Generate the design example of [H-tile Hard IP for Ethernet Intel Stratix 10 FPGA IP](https://www.intel.com/content/www/us/en/programmable/documentation/vqu1511218103429.html). Generate the design example of [Avalon memory mapped Intel Stratix 10 Hard IP+](https://www.intel.com/content/www/us/en/programmable/documentation/sox1520633403002.html). Generate IOPLL, eSRAM IP, and External Memory Interfaces (DRAM) IP. The eSRAM is only available on particular Intel FPGA devices. It is optional for Pigasus as it can be replaced by BRAM. 
2. Add Pigasus source code (entire `rtl_sim` folder including the `rtl_sim/common`) into the Ethernet Hard IP design example.
3. Change the pin assignment based on the hardware platform. We use [Stratix 10 MX Development Kit](https://www.intel.com/content/www/us/en/programmable/documentation/cbc1517362051825.html).
4. Compile the design by clicking "Compile Design" in Quartus. 

> **Notes:**
>
> - We will create a script to fully automate Simulation step 3 and Synthesis step 1-4. 
> - When using other Quartus versions, all the Simulation and Synthesis steps should be redone.
> - When mapping to other Intel FPGA devices, the specific device support should be downloaded and all the Simulation and Synthesis steps should be redone as the IPs for difference devices might be different.
> - When mapping to FPGAs from other vendors, users are responsible to include all the missing IPs and perhaps a shim layer between those IPs and the Pigasus code. 

### RTL Simulation

Before you synthesize your changes an run them on the FPGA, you should verify your design using RTL simulation. The simulation testbed does not include the Ethernet IP core, PCIe IP core, and full matcher on CPU. The `testbench.sv` drives the FPGA datapth, including parser, TCP Reassembly and MSPM by dumping converted pcap file. Once the simulation finishes, the testbench will report statistics of FPGA datapth to help developers verify functionality and diagnose performance bottleneck. The following instructions assume that you have Modelsim installed. 

Go to the input generator and convert the example pcap into a pkt format, that can be used as input for the simulation:

```bash
cd $pigasus_rep_dir/hardware/rtl_sim/input_gen/
./run.sh ./m10_100.pcap
cd ..
```

Now run the simulation using Modelsim and your newly generated input:
```bash
./run_vsim.sh ./input_gen/output.pkt
```

After the simulation, you should expect the key counter values match up with the `input_gen/example_expected_res`

We also provide an example script `run_vsim.bat` for Windows users. Please set up the `SIM_LIB_PATH` and the RTL simulator environment variables before running this script in cmd or powershell. 

Tips:
To enable GUI mode in Modelsim, comment the last line of `run_vsim.sh` and uncomment the line under "GUI full debug."
To speedup the simulation, you can disable MSPM in your first few runs by uncommenting the second line of `mspm/string_matcher/string_matcher.sv`. The MSPM will be a dummy module which just passes the packets. 



### Hardware Synthesis

Once you verify that your design runs in simulation, you can synthesize it and run it on the FPGA. To do so you will need Quartus.

If you completed the steps in [Hardware Development Requirements](#hardware-development-requirements), all you need to do is to open the project in Quartus and click in "Compile Design" (it will take a few hours). After that, refer to [Running Pigasus](#running-pigasus) for instructions on how to load the bitstream on the FPGA and run Pigasus.

## License

Pigasus is developed at Carnegie Mellon University. The hardware component of Pigasus (`/hardware`) is released under the [BSD 3-Clause Clear License](hardware/LICENSE). The software component (`/software`) is adapted from Snort3 and released under the [GNU General Public License v2.0](software/LICENSE).
