# =============================================================================
# create_and_sim.tcl
#
# Builds a Vivado project for the RV32I 5-stage pipeline core and launches
# a behavioral (RTL) simulation. No board, no bitstream, no hardware needed.
#
# Usage (from a terminal, no GUI required):
#   cd RISCV32I_5stage_Vivado
#   vivado -mode batch -source scripts/create_and_sim.tcl
#
# Usage (from the Vivado GUI Tcl console):
#   cd <path to RISCV32I_5stage_Vivado>
#   source scripts/create_and_sim.tcl
# =============================================================================

set proj_name "riscv5stage_sim"
set proj_dir  "./build/${proj_name}"

# Any part works here since we never synthesize or generate a bitstream.
# Pick a common, freely-supported Artix-7 part just to satisfy Vivado.
set fpga_part "xc7a35tcpg236-1"

create_project $proj_name $proj_dir -part $fpga_part -force

# ---- Design (RTL) sources -----------------------------------------------
add_files -norecurse [glob ./rtl/*.v]
set_property file_type Verilog [get_files ./rtl/*.v]
update_compile_order -fileset sources_1

# The design has no dedicated top for synthesis in this simulation-only
# flow; Pipeline_Top.v is the DUT the testbench instantiates.
set_property top Pipeline_top [current_fileset]

# ---- Simulation sources ----------------------------------------------------
add_files -fileset sim_1 -norecurse ./sim/pipeline_tb.v
add_files -fileset sim_1 -norecurse ./sim/mem/memfile.hex

# Mark the .hex as simulation-only data (not a design source) so Vivado
# copies it into the simulation run directory instead of trying to
# synthesize it. $readmemh("memfile.hex", ...) then resolves correctly.
set_property used_in_synthesis false [get_files ./sim/mem/memfile.hex]
set_property used_in_implementation false [get_files ./sim/mem/memfile.hex]

set_property top tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

# ---- Run behavioral simulation --------------------------------------------
set_property -name {xsim.simulate.runtime} -value {1200ns} -objects [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral

puts "\n===================================================================="
puts " Simulation launched. In the Vivado GUI, use the Scope/Objects panes"
puts " to add DUT signals to the waveform, or open scripts/wave.do-style"
puts " signals manually. In batch mode, xsim will run to \$finish and stop."
puts "====================================================================\n"
