
read_verilog -netlist ../netlist/myiir.v
read_saif -input ../saif/myiir_syn.saif -instance tb_iir/UUT -unit ns -scale 1
create_clock -name MY_CLK CLK
report_power > ./report_power_fm_4_21_10.txt
