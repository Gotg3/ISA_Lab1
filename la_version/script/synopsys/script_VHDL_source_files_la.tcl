analyze -f vhdl -lib work ../src/filt_package.vhd
analyze -f vhdl -lib work ../src/register_n.vhd
analyze -f vhdl -lib work ../src/myiir.vhd
analyze -f vhdl -lib work ../src/filt_behavioural.vhd
set power_preserve_rtl_hie_names true
elaborate myiir -arch structural -lib WORK > ./elaborate.txt
