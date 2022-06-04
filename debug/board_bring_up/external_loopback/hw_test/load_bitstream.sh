#copy from the quartus project
cp ../quartus_project/hardware_test_desgin/output_files/alt_ehipc2_hw.sof ./

quartus_pgm -c Intel\ Stratix\ 10\ MX\ FPGA\ Development\ Kit\ [1-12] ./load.cdf 
