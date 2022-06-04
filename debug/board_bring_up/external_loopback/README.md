# External Loopback Test
This project tests the external loopback of the two 100Gbps Ethernet ports of Intel Stratix-10 MX dev kit. An external 100G cable is needed to wire the two QSFP ports of the board. This project only contains two 100Gbps MAC IPs without any packet processing logic. 

1. Generate bitstream
```bash
./run_quartus
```

2. Load the bitstream to the Intel MX development kit.
```bash
cd hw_test
./load_bitstream.sh
```

3. Send packet from one port (using port 0 in this example).
Once the system finishes booting, run the JTAG system console with:
```bash
./run_console.sh
```
After the console starts, run:
```
source path.tcl
```
> It may return some error the first time. Exit it using Ctrl-C. Then relaunch the console (`./run_console`) and rerun `source path.tcl.
In the tcl console, you will need to type some tcl commands.
Check the initial value, should be all zero
```
chkmac_stats
```
Send pkt
```
start_pkt_gen
stop_pkt_gen
```
Check the value again, the TX part should return non-zero values, indicating number of packets of different sizes. RX is zero
```
chkmac_stats
```
Ctrl-C to exit

4. Check results of the other port
```
cd hwtest/altera/sval_top
```
Comment Port 0 and uncomment Port 1 (assuming step 2 is using port 0)
```
vi reg_map_inc.tcl
```
The RX part value should match with the TX of the sending port. 
```
cd ../../../
./run_console.sh
source path.tcl
chkmac_stats
```
