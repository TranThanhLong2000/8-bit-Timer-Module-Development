`timescale 1ps/1ps
module top_module (
    input           clk, 
    input   [3:0]   clk_in,        
    input           rst_n,          
    input           psel,                    
    input           penable,       
    input           pwrite,      
    input   [7:0]   paddr,         
    input   [7:0]   pwdata,        
    output  [7:0]   prdata,       
    output          pready,        
    output          pslverr       
   
    
);

  
    wire            load;
    wire            up_down;
    wire            enable;
    wire    [1:0]   clk_sel; 
    wire            clk_ena; 
    wire	overflow, underflow;
    wire  [7:0]    start_counter;
 

  
    apb_controller u_apb_controller (
        .clk           (clk),
        .rst_n         (rst_n),
        .psel          (psel),
        .penable       (penable),
        .pwrite        (pwrite),
        .paddr         (paddr),
        .pwdata        (pwdata),
        .prdata        (prdata),
        .pready        (pready),
        .pslverr       (pslverr),
        .start_counter (start_counter),
        .load          (load),
        .up_down       (up_down),
        .enable        (enable),
        .clk_sel       (clk_sel),
        .overflow       (overflow),
        .underflow       (underflow)
        
       
    );

  
    clock_selection u_clock_selection (
        .clk           (clk),
        .rst_n         (rst_n),
        .clk_sel       (clk_sel),
        .clk_in        (clk_in),
        .clk_ena       (clk_ena)
    );

    counter  u_counter (
        .clk           (clk),
        .rst_n         (rst_n),
        .clk_ena       (clk_ena),
        .start_counter (start_counter),
        .up_down       (up_down),
        .load          (load),
        .enable        (enable),
        .overflow      (overflow),
        .underflow     (underflow) 
    );

endmodule


   