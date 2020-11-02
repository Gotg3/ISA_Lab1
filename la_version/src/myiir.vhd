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
	a1:  in signed(nb-1 downto 0); 
	b0:  in signed(nb-1 downto 0); 
	b1:  in signed(nb-1 downto 0);
	a1_2: in signed(nb-1 downto 0)
	);
end myiir ;

architecture structural of myiir  is

signal dout_filter: signed(nb-1 downto 0);
signal dout_reg : std_logic_vector(nb-1 downto 0);
signal q_dout: std_logic_vector(nb-1 downto 0);
signal en_reg_out: std_logic:='1';
signal VIN_sig: std_logic;  --delay VIN, input register 
signal VIN_sig1: std_logic; --delay VIN, 1st pipe
signal VIN_sig2: std_logic; --delay VIN, 2nd pipe
signal VIN_sig3: std_logic; --delay VIN, 3rd pipe
signal VOUT_sig: std_logic;
signal d_out_sig: std_logic_vector(nb downto 0);
signal d_ingresso_ritardato: std_logic_vector(nb-1 downto 0);

   component filt_behavioural is
	generic(nb: integer:=6; g: integer:=1);
		port(
		DIN: in signed(nb-1 downto 0); --data in
		DOUT: out signed(nb-1 downto 0); --data out
		CLK: in std_logic; 
		RST_N: in std_logic;
		EN1: in std_logic;
		EN2: in std_logic;
		EN3: in std_logic;
		--coefficients
		a1: in signed(nb-1 downto 0); 
		a1_2: in signed(nb-1 downto 0);
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
    
      process(CLK,RST_n) --delay of VIN 
		begin  -- process
		if RST_n = '0' then  --negative reset
		VIN_sig<='0';
		
		elsif CLK'event and CLK = '1' then  -- rising clock edge
		VIN_sig<=VIN;
		
		end if;
		end process;
		
		process(CLK,RST_n) --1st pipe reg for VIN
      begin  -- process
      if RST_n = '0' then  --negative reset
      VIN_sig1<='0';
      elsif CLK'event and CLK = '1' then  -- rising clock edge
     
      VIN_sig1<=VIN_sig;
      
      end if;
      end process;
      
      process(CLK,RST_n) --2nd pipe reg for VIN
      begin  -- process
      if RST_n = '0' then  --negative reset
      
      VIN_sig2<='0';
      elsif CLK'event and CLK = '1' then  -- rising clock edge
      
      VIN_sig2<=VIN_sig1;
      end if;
      end process;
	  
	  process(CLK,RST_n) --3rd pipe reg for VIN
      begin  -- process
      if RST_n = '0' then  --negative reset
      
      VIN_sig3<='0';
      elsif CLK'event and CLK = '1' then  -- rising clock edge
      
      VIN_sig3<=VIN_sig2;
      end if;
      end process;
		
		
		
	    process(CLK,RST_n) --vout reg
		begin  -- process
		if RST_n = '0' then  
		VOUT_sig<='0';
		elsif CLK'event and CLK = '1' then  -- rising clock edge
		VOUT_sig<=VIN_sig3;
		end if;
		end process;


--d_out_sig<=VIN_sig & std_logic_vector(dout_filter);  --connect DOUT and VOUT before the register

reg_in: register_n generic map (parallelism=>nb) port map(d=>std_logic_vector(DIN), q=>dout_reg, clk=>CLK, rst_n=>RST_N, en=>std_logic(VIN) ); --input register
reg_out: register_n generic map (parallelism=>nb) port map(d=>std_logic_vector(dout_filter), q=>q_dout, clk=>CLK, rst_n=>RST_N, en=>VIN_sig3); --output register
filter: filt_behavioural generic map (nb=>nb, g=>g) port map(DIN=>signed(dout_reg(nb-1 downto 0)), DOUT=>dout_filter, clk=>CLK, rst_n=>RST_N, EN1=>VIN_sig, EN2=>VIN_sig1, EN3=>VIN_sig2 , a1=>a1,b0=>b0,b1=>b1, a1_2=>a1_2); 
DOUT<=signed(q_dout); --connect DOUT
VOUT<=VOUT_sig; --connect VOUT
end structural;









