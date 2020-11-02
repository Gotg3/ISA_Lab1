library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filt_behavioural is
generic(nb: integer:=6; g: integer:=1);
port(
DIN: in signed(nb-1 downto 0); --data in
DOUT: out signed(nb-1 downto 0); --data out
CLK: in std_logic; 
RST_N: in std_logic;
EN: in std_logic; -- enable for the internal register
--coefficients
a1: in signed(nb-1 downto 0); 
b0: in signed(nb-1 downto 0); 
b1: in signed(nb-1 downto 0)
);
end filt_behavioural;

architecture behavioural of filt_behavioural is 

--signal DIN_G:signed(nb downto 0):=(others =>'0'); --signal guarded
signal DOUT_EXP:signed(nb-1+g downto 0):=(others =>'0');
signal DIN_EXP:signed(nb-1+g downto 0):=(others =>'0'); --nb+1 bits, 1 extra internal bit for 1 bit guard
signal a1_EXP:signed(nb-1+g downto 0):=(others =>'0');
signal b1_EXP:signed(nb-1+g downto 0):=(others =>'0');
signal b0_EXP:signed(nb-1+g downto 0):=(others =>'0');

signal V : signed(nb-1+g downto 0):=(others =>'0'); --v[n]
signal V_1s: signed(nb-1+g downto 0):=(others =>'0'); --v[n-1]
signal V_1: signed(nb-1+g downto 0):=(others =>'0'); --v[n-1]
signal DOUT_T: signed(nb-1+g downto 0):=(others =>'0'); --temp dout 
signal MULT_DOUT_T:signed(2*(nb+g)-1 downto 0):=(others =>'0'); -- output temp signal mult
signal MULT_FF:signed(2*(nb+g)-1 downto 0):=(others =>'0'); -- feedback signal mult
signal MULT_FB:signed(2*(nb+g)-1 downto 0):=(others =>'0'); -- feedback signal mult

signal FB:signed(nb-1+g downto 0):=(others =>'0'); -- feedback signal 
signal Ff:signed(nb-1+g downto 0):=(others =>'0'); -- feedforward signal 



--signal V : signed(nb-1 downto 0):=(others =>'0'); --v[n]
--signal V_1: signed(nb-1 downto 0):=(others =>'0'); --v[n-1]

--signal DOUT_T: signed(nb-1 downto 0):=(others =>'0'); --temp dout 
--signal MULT_DOUT_T:signed(2*nb-1 downto 0):=(others =>'0'); -- output temp signal mult
--signal MULT_FF:signed(2*nb-1 downto 0):=(others =>'0'); -- feedback signal mult
--signal MULT_FB:signed(2*nb-1 downto 0):=(others =>'0'); -- feedback signal mult
--signal FB:signed(nb-1 downto 0):=(others =>'0'); -- feedback signal 
--signal Ff:signed(nb-1 downto 0):=(others =>'0'); -- feedforward signal 
begin

        delay_proc: process(clk,RST_n,EN)
	begin	
		if (CLK' event and clk='1') then --reset sincrono o asincrono?
			if(RST_N='0') then
				V_1s<= (others =>'0');
				
			else
				if (EN='1') then
					V_1s<=V; 
				else 
					
					V_1s<=V_1s; 
				end if;
			end if;
		end if;
	end process delay_proc; 
	V_1<=V_1s;
	
	DIN_EXP<=resize(DIN,nb+g);
	a1_EXP<=resize(a1,nb+g);
	b1_EXP<=resize(b1,nb+g);
	b0_EXP<=resize(b0,nb+g);
	
	
	MULT_FB<=shift_right(signed(V_1*a1_EXP),nb-1+g); 
	FB<=MULT_FB(nb-1+g downto 0);
	MULT_FF<=shift_right(signed(V_1*b1_EXP),nb-1+g);
	FF<=MULT_FF(nb-1+g downto 0);
	V<=DIN_EXP-FB; --il meno del -a1 é qua
	MULT_DOUT_T<=shift_right(signed(V*b0_EXP),nb-1+g);
	DOUT_T<=MULT_DOUT_T(nb-1+g downto 0);
	
	DOUT_EXP<=shift_left(signed(DOUT_T+FF),2*g); -- riportati su scale factor corretto
	DOUT<=DOUT_EXP(nb-1+g downto g); --forse é perchè riseleziono fino al LSB+1 quindi é come se prendessi un numero più grande
	
	


end behavioural;
