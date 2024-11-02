Instructions for Using Makefile
1. Initiate Project:
*Command: make init
*Description: This command will create a working library (work) and map that library, 
similar to the vlib work and vmap work work commands in the command line instructions.

2. Compile All Sources and Testbenches:
*Command: make compile
*Description: This command compiles all Verilog files in the RTL directory and the testbench using vlog -work work *.v,
corresponding to the direct compilation command in the command line.

3. Run Simulation:
*Command: make simulation
*Description: This command runs the simulation for the testbench file (here, tb_top_module) without waveform,
corresponding to the command vsim -c work.my_tb -do "run -all" in the command line instructions.

4. Clean All Outputs:
*Command: make clean
*Description: This command removes all temporary files and the working library,
similar to the command vdel -all -lib work in the command line instructions.
