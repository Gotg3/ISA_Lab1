library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package filter_package is

	constant nb: integer:=13; --parallelism of the filter
	constant  N:  integer:=1;	 --order of the filter
	constant  g: integer:=1;
end package filter_package;