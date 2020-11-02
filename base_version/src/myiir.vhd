library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.filter_package.all;

entity myiir is

port(
	DIN: in signed(nb-1 downto 0); --data in
	DOUT: out signed(nb-1 downto 0); --data out
	VIN: in std_logic; --validation input
	VOUT: out std_logic; --validation output 
	CLK: in std_logic; 
	RST_n: in std_logic;
	--coefficients
	a1: in signed(nb-1 downto 0); 
	b0: in signed(nb-1 downto 0); 
	b1: in signed(nb-1 downto 0)
	);
end myiir ;

architecture structural of myiir  is

signal dout_filter: signed(nb-1 downto 0);
signal dout_reg : std_logic_vector(nb-1 downto 0);
signal q_dout: std_logic_vector(nb-1 downto 0);
signal en_reg_out: std_logic:='1';
signal VIN_sig: std_logic;
signal VOUT_sig: std_logic;
--signal d_out_sig: std_logic_vector(nb downto 0);
signal d_ingresso_ritardato: std_logic_vector(nb-1 downto 0);

   component filt_behavioural is
	generic(nb: integer:=6);
		port(
		DIN: in signed(nb-1 downto 0); --data in
		DOUT: out signed(nb-1 downto 0); --data out
		CLK: in std_logic; 
		RST_N: in std_logic;
		EN: in std_logic;
		--coefficients
		a1: in signed(nb-1 downto 0); 
		b0: in signed(nb-1 downto 0); 
		b1: in signed(nb-1 downto 0)
		);
		end component;
	 
	 component register_n is
	 generic (parallelism: integer:=7);
		port(
		d: in std_logic_vector(parallelism-1 downto 0);
		q: out std_logic_vector(parallelism-1 downto 0);
		clk: in std_logic;
		rst_n: in std_logic; --negative reset
		en: in std_logic --enable 
		);
		end component;
		
		
begin
    
    process(CLK,RST_n) --vin reg
		begin  -- process
		if RST_n = '0' then  
		VIN_sig<='0';
		elsif CLK'event and CLK = '1' then  -- rising clock edge
		VIN_sig<=VIN;
		end if;
		end process;

	    process(CLK,RST_n) --vout reg
		begin  -- process
		if RST_n = '0' then  
		VOUT_sig<='0';
		elsif CLK'event and CLK = '1' then  -- rising clock edge
		VOUT_sig<=VIN_SIG;
		end if;
		end process;

--VIN_sig<=VIN;
--VIN_sig<=dout_reg(nb);
--osservo DIN dopo il primo registro
--d_ingresso_ritardato<=dout_reg(nb-1 downto 0);
--d_in_sig<=VIN & std_logic_vector(DIN); --we can't have operators inside portmap
--d_out_sig<=VIN_sig & std_logic_vector(dout_filter); 
--reg_in: register_n generic map (parallelism=>nb+1) port map(d=>d_in_sig, q=>dout_reg, clk=>CLK, rst_n=>RST_N, en=>std_logic(VIN) );
reg_in: register_n generic map (parallelism=>nb) port map(d=>std_logic_vector(DIN), q=>dout_reg, clk=>CLK, rst_n=>RST_N, en=>std_logic(VIN) );
reg_out: register_n generic map (parallelism=>nb) port map(d=>std_logic_vector(dout_filter), q=>q_dout, clk=>CLK, rst_n=>RST_N, en=>VIN_sig);
filter: filt_behavioural generic map (nb=>nb) port map(DIN=>signed(dout_reg(nb-1 downto 0)), DOUT=>dout_filter, clk=>CLK, rst_n=>RST_N, EN=>VIN_sig , a1=>a1,b0=>b0,b1=>b1); 
DOUT<=signed(q_dout);
VOUT<=VOUT_sig;
end structural;
