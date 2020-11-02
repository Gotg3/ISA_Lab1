//`timescale 1ns

module tb_iir ();

   wire CLK_i;
   wire RST_n_i;
   wire [12:0] DIN_i;
   wire VIN_i;
   wire [12:0] H0_i;
   wire [12:0] H1_i;
   wire [12:0] H2_i;
   wire [12:0] H3_i;	//a1^2
  // wire [15:0] H3_i;
   wire [12:0] DOUT_i;
   wire VOUT_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker SM(.CLK(CLK_i),
	         .RST_n(RST_n_i),
		 .VOUT(VIN_i), // genera VIN
		 .DOUT(DIN_i),
		 .H0(H0_i), //assegnazione posizionale? si gli ordini sono rispettati nelle altre tre strutture
		 .H1(H1_i), //b0
		 .H2(H2_i), //b1
		 .H3(H3_i), //a1^2
		 .END_SIM(END_SIM_i));

   myiir UUT(
	     
	     .DIN(DIN_i),
		 .DOUT(DOUT_i),
		 .VIN(VIN_i),
		 .VOUT(VOUT_i),
		 .CLK(CLK_i),
		 .RST_n(RST_n_i),
         .a1(H0_i),   //a1 -649
	     .b0(H1_i),   //b0 1723
	     .b1(H2_i),   //b1 1723
        .a1_2(H3_i)); //a1^2 102
	     //.H3(H3_i),
            
             

   data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));   

endmodule

		   
