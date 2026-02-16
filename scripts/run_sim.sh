#!/usr/bin/env bash
# =============================================================================
# run_sim.sh
#
# Compiles and runs the pipeline testbench using Vivado's simulator (xsim)
# directly from the command line -- no Vivado project file, no GUI, no
# board, no bitstream. Requires Vivado's bin directory on your PATH
# (e.g. source /tools/Xilinx/Vivado/<version>/settings64.sh first).
#
# Usage:
#   cd RISCV32I_5stage_Vivado
#   bash scripts/run_sim.sh
# =============================================================================
set -e

TOP_TB="tb"
WORK_DIR="build/xsim_cli"

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Keep memfile.hex next to the simulation binary so the bare-filename
# $readmemh("memfile.hex", mem) call in Instruction_Memory.v resolves.
cp -f ../../sim/mem/memfile.hex .

echo ">> Compiling design + testbench with xvlog..."
xvlog --sv ../../rtl/*.v ../../sim/pipeline_tb.v

echo ">> Elaborating with xelab..."
xelab ${TOP_TB} -debug typical -s ${TOP_TB}_sim

echo ">> Running simulation with xsim..."
xsim ${TOP_TB}_sim -runall

echo ""
echo "Done. Waveform database (if any) and logs are in: $(pwd)"
echo "To inspect waveforms interactively instead, run:"
echo "  xsim ${TOP_TB}_sim -gui"
