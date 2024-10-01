#!/bin/bash
# echo "Generating Floating point inputs for testing.."
# python3 fp_conversion.py

OUTPUT_DIR="outputs"

echo "Creating output directory.."
rm -rf "$OUTPUT_DIR"
mkdir "$OUTPUT_DIR"
if [ $? -ne 0 ]; then
    echo "Failed to create directory: $OUTPUT_DIR"
    exit 1
fi

echo "Compiling Design and Testbench Files!"
iverilog -g2012 -o "$OUTPUT_DIR"/testbench fp_mult.sv fp_add.sv PE.sv systolic_array.sv tb_systolic_array.sv

if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

echo "Running Simulation!"
vvp "$OUTPUT_DIR"/testbench

if [ $? -ne 0 ]; then
    echo "Simulation failed!"
    exit 1
fi

echo "Launching GTK waveform viewer"
gtkwave "$OUTPUT_DIR"/waveform.vcd

echo "Simulation Completed Successfully!"

clear
