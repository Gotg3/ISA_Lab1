library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity register_n is
generic (parallelism: integer:=7);
port(
	d: in std_logic_vector(parallelism-1 downto 0);
	q: out std_logic_vector(parallelism-1 downto 0);
	clk: in std_logic;
	rst_n: in std_logic; --negative reset
	en: in std_logic --enable 
	);
end register_n;

architecture behavioural of register_n is
signal q_sig: std_logic_vector(parallelism-1 downto 0);

begin

   process(clk,rst_n,en)
	begin
		
		if (clk' event and clk='1') then
			if(rst_n='0') then
				q_sig<=(others => '0');
			else
				if(en='1') then
					q_sig<=d;
				else
					q_sig<=q_sig;
				end if;
			end if;
		end if;
	end process;
	
	q<=q_sig;
	
end behavioural;
