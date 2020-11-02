library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filt_behavioural is
generic(nb: integer:=6; g: integer:=1);
port(
DIN:   in signed(nb-1 downto 0); --data in
DOUT:  out signed(nb-1 downto 0); --data out
CLK:   in std_logic; 
RST_N: in std_logic;
EN1:    in std_logic; -- enable prepipe
EN2:    in std_logic; -- enable pipe 1
EN3:    in std_logic; -- enable pipe 2
--coefficients
a1:   in signed(nb-1 downto 0); 
b0:   in signed(nb-1 downto 0); 
b1:   in signed(nb-1 downto 0);
a1_2: in signed(nb-1 downto 0)
);
end filt_behavioural;

architecture behavioural of filt_behavioural is 

--signal DIN_G:signed(nb downto 0):=(others =>'0'); --signal guarded
signal DOUT_EXP:signed(nb-1+g downto 0):=(others =>'0');
signal DIN_EXP:signed(nb-1+g downto 0):=(others =>'0'); --nb+1 bits, 1 extra internal bit for 1 bit guard
signal a1_EXP:signed(nb-1+g downto 0):=(others =>'0');
signal b1_EXP:signed(nb-1+g downto 0):=(others =>'0');
signal b0_EXP:signed(nb-1+g downto 0):=(others =>'0');
signal a1_2_exp:signed(nb-1+g downto 0):=(others =>'0');

--FIR-like PART 1
signal M_FF1:signed(2*(nb+g)-1 downto 0):=(others =>'0'); -- output of the first multiplication, part FIR-like 1
signal FF1_IN:signed(nb-1+g downto 0):=(others =>'0'); -- input retiming register 1st FIR-like stage
signal FF1_OUT:signed(nb-1+g downto 0):=(others =>'0'); -- output retiming register 1st FIR-like stage
signal Z:signed(nb-1+g downto 0):=(others =>'0'); -- input of the 1st pipeline stage

--IIR-like PART
signal Z_OUT:signed(nb-1+g downto 0):=(others =>'0'); -- output of the 1st pipeline stage
signal V:signed(nb-1+g downto 0):=(others =>'0'); -- input of the 2nd pipeline stage
signal FB_OUT:signed(nb-1+g downto 0):=(others =>'0'); -- output retiming register 2
signal FB_IN:signed(nb-1+g downto 0):=(others =>'0'); -- input retiming register 2
signal M_FB:signed(2*(nb+g)-1 downto 0):=(others =>'0'); -- feedback signal after mult. of the IIR-like
signal V_OUT_FB:signed(nb-1+g downto 0):=(others =>'0'); -- output retiming register 1

--FIR-like PART 2
signal V_OUT_FF:signed(nb-1+g downto 0):=(others =>'0'); -- output pipeline register 2
signal M_FF2:signed(2*(nb+g)-1 downto 0):=(others =>'0'); -- output multiplication FIR-like part 2
signal FF2_OUT:signed(nb-1+g downto 0):=(others =>'0'); -- output retiming register 2nd FIR-like stage
signal FF3_IN:signed(nb-1+g downto 0):=(others =>'0'); -- input pipe register 3 2nd FIR-like stage
signal FF3_OUT:signed(nb-1+g downto 0):=(others =>'0'); -- output pipe register 3 2nd FIR-like stage
signal FF4_IN:signed(nb-1+g downto 0):=(others =>'0'); -- input pipe register 4 2nd FIR-like stage
signal FF4_OUT:signed(nb-1+g downto 0):=(others =>'0'); -- output pipe register 4 2nd FIR-like stage
signal M_DOUBLE:signed(2*(nb+g)-1 downto 0):=(others =>'0'); -- output multiplication (b0) FIR-like part 2
signal M : signed(nb-1+g downto 0):=(others =>'0'); -- signal M

--
signal s_FF1_OUT:signed(nb-1+g downto 0):=(others =>'0');
signal s_Z_OUT:signed(nb-1+g downto 0):=(others =>'0');
signal s_FB_OUT:signed(nb-1+g downto 0):=(others =>'0');
signal s_V_OUT_FB:signed(nb-1+g downto 0):=(others =>'0');
signal s_V_OUT_FF:signed(nb-1+g downto 0):=(others =>'0');
signal s_FF2_OUT:signed(nb-1+g downto 0):=(others =>'0');
signal s_FF3_OUT:signed(nb-1+g downto 0):=(others =>'0');
signal s_FF4_OUT:signed(nb-1+g downto 0):=(others =>'0');

begin

        delay_proc1: process(clk,RST_n,EN1) --prepipe
			begin	
				if (CLK' event and clk='1') then 
					if(RST_N='0') then
						
						s_FF1_OUT<=(others=>'0');
						s_Z_OUT<=(others=>'0');
						
					else
						if (EN1='1') then
							
							s_FF1_OUT	<=	  FF1_IN;
							s_Z_OUT     <=    Z;
						else 
							s_FF1_OUT	<=	  s_FF1_OUT;
						   s_Z_OUT     <=    s_Z_OUT;
							
							
						end if;
					end if;
				end if;
			end process delay_proc1; 
			
					
	
	
	
	delay_proc2: process(clk,RST_n,EN2) --pipe1
    begin	
	    if (CLK' event and clk='1') then 
		    if(RST_N='0') then
			   
			   
			    
			    s_FB_OUT<=(others=>'0');
			    s_V_OUT_FB<=(others=>'0');
			    s_V_OUT_FF<=(others=>'0');
			   
		    else
			    if (EN2='1') then
				   
				    
				    s_V_OUT_FF  <=    V; 
				    s_FB_OUT    <=    FB_IN;
				    s_V_OUT_FB  <=    V;
				   
			    else 
				    
			       
			        s_V_OUT_FF  <=    s_V_OUT_FF;
			        s_FB_OUT    <=    s_FB_OUT;
			        s_V_OUT_FB  <=    s_V_OUT_FB;
			       
				   
				   
			    end if;
		    end if;
	    end if;
    end process delay_proc2; 
   
    
	
	
	
	delay_proc3: process(clk,RST_n,EN3) --pipe2
    begin	
	    if (CLK' event and clk='1') then 
		    if(RST_N='0') then
			   
			    
			    
			    s_FF2_OUT<=(others=>'0');
			    s_FF3_OUT<=(others=>'0');
				s_FF4_OUT<=(others=>'0');
		    else
			    if (EN3='1') then
				   
				    
				    
				    s_FF2_OUT   <=    V_OUT_FF;
					s_FF3_OUT   <=    FF3_IN;
					s_FF4_OUT   <=    M;
			    else 
				    
			        
				    s_FF2_OUT   <=    s_FF2_OUT;
				    s_FF2_OUT   <=    s_FF2_OUT;
				    s_FF4_OUT   <=    s_FF4_OUT;
			    end if;
		    end if;
	    end if;
    end process delay_proc3; 
   
    FF1_OUT   <=	  s_FF1_OUT; 
    Z_OUT     <=      s_Z_OUT;   
    FB_OUT    <=      s_FB_OUT;  
    V_OUT_FB  <=      s_V_OUT_FB; 
    V_OUT_FF  <=      s_V_OUT_FF; 
    FF2_OUT   <=      s_FF2_OUT;  
	FF3_OUT   <=      s_FF3_OUT;  
	FF4_OUT   <=      s_FF4_OUT;  
	
	
	DIN_EXP<=resize(DIN,nb+g);
	a1_EXP<=resize(a1,nb+g);
	b1_EXP<=resize(b1,nb+g);
	b0_EXP<=resize(b0,nb+g);
	a1_2_exp<=resize(a1_2,nb+g);
	
	
	--comute 1st feedforward
	M_FF1<=shift_right(signed(DIN_EXP*a1_EXP),nb-1+g);  
	FF1_IN<=M_FF1(nb-1+g downto 0);
	
	--compute 2nd feedforward
	M_FF2<=shift_right(signed(FF2_OUT*b1_EXP),nb-1+g);  
	FF3_IN<=M_FF2(nb-1+g downto 0);
	
	--compute feedback
	M_FB<=shift_right(signed(V_OUT_FB*a1_2_EXP),nb-1+g);  
	FB_IN<=M_FB(nb-1+g downto 0);
	
	--compute mult b0
	M_DOUBLE<=shift_right(signed(V_OUT_FF*b0_EXP),nb-1+g);  
	M<=M_DOUBLE(nb-1+g downto 0);
	
	--compute sum FIR-like part 1
	Z<=DIN_EXP-FF1_OUT; --il meno del -a1 e' qua
		
	
	--compute sum IIR-like 
	V<=Z_OUT+FB_OUT;
	
	--compute output
	DOUT_EXP<=shift_left(signed(FF4_OUT+FF3_OUT),2*g); -- riportati su scale factor corretto
	DOUT<=DOUT_EXP(nb-1+g downto g);
	


end behavioural;
