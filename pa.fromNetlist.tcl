
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name test-vga -dir "/home/korn/xilinx/test-vga/planAhead_run_4" -part xc6slx9tqg144-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/korn/xilinx/test-vga/verilog.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/korn/xilinx/test-vga} }
set_property target_constrs_file "verilog.ucf" [current_fileset -constrset]
add_files [list {verilog.ucf}] -fileset [get_property constrset [current_run]]
link_design
