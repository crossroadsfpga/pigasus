#copy from the quartus project
cp ../quartus_project_0/hardware_test_design/output_files/alt_ehipc2_hw.sof ./

#program the bitstream. The exact USB port (e.g. port 13 in this example) may be adjusted for different setup. 
quartus_pgm -c Intel\ Stratix\ 10\ MX\ FPGA\ Development\ Kit\ [1-13] ./load.cdf 
