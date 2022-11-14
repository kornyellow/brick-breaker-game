
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name test-vga -dir "/home/korn/xilinx/test-vga/planAhead_run_1" -part xc6slx9tqg144-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "verilog.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {verilog.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top verilog $srcset
add_files [list {verilog.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-3
