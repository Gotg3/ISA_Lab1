create_clock -name MY_CLK -period 0.0 CLK
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]
compile
report_timing > ./report_timing_period0.txt
report_area > ./report_area_period0.txt
ungroup -all -flatten
change_names -hierarchy -rules verilog
write_sdf ../netlist/myiir.sdf
write -f verilog -hierarchy -output ../netlist/myiir.v
write_sdc ../netlist/myiir.sdc


