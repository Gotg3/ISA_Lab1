

vcom -93 -work ./work ../src/filt_package.vhd
vcom -93 -work ./work ../src/register_n.vhd
vcom -93 -work ./work ../src/myiir.vhd
vcom -93 -work ./work ../src/filt_behavioural.vhd
vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker.vhd
vcom -93 -work ./work ../tb/data_sink.vhd
vlog -work ./work ../tb/tb_iir.v

vsim work.tb_iir

add wave sim:/tb_iir/CLK_i
add wave sim:/tb_iir/RST_n_i
add wave sim:/tb_iir/DIN_i
add wave sim:/tb_iir/VIN_i
add wave sim:/tb_iir/DOUT_i
add wave sim:/tb_iir/VOUT_i
