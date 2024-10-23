`timescale 1ps/1ps
module clock_selection (
    input          clk,
    input          rst_n,
    input   [1:0]  clk_sel,
    input   [3:0]  clk_in,
    output      clk_ena     
);

    reg  prev_clk_in;
    reg  reg_clk_in;
    reg  reg_clk_in_ena;
   

    always @(posedge clk) begin
        if (!rst_n) begin
            reg_clk_in <= 0;
           
        end else begin
          case(clk_sel) 
            	0: reg_clk_in 	<= clk_in[0];
		         1: reg_clk_in 	<= clk_in[1];
		         2: reg_clk_in 	<= clk_in[2];
		         3: reg_clk_in 	<= clk_in[3];
              endcase
        end
    end

   
    always @(posedge clk ) begin
    prev_clk_in	<= reg_clk_in;
    reg_clk_in_ena	<= reg_clk_in & ~prev_clk_in;
       
        end
     assign clk_ena = reg_clk_in_ena;
   

endmodule



