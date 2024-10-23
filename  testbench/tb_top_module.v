`timescale 1ps/1ps
module tb_top_module;
	parameter	 TIME = 10;
	reg		      clk;
	reg		      rst_n;
	reg  [3:0] clk_in;
  //port for timer8bit
	reg		        psel;
	reg 		       pwrite;
	reg		        penable;
  reg	  [7:0]	 paddr;
	reg	  [7:0]	 pwdata;
	wire	 [7:0]	 prdata;
	wire		       pready;
	wire		       pslverr;

	reg	  [7:0]	 value_tdr;
	reg	  [7:0]	 value_tcr;
	reg	  [7:0]	 value_tsr;

	reg  [15:0]  thread_1_debug =0;
	reg  [15:0]  thread_2_debug =0;
  reg  [15:0]  value_debug    =0;
  
  

top_module		uut(
  .clk(clk),
  .clk_in(clk_in),
  .rst_n(rst_n),
  .psel(psel),
  .pwrite(pwrite),
  .penable(penable),
  .paddr(paddr),
  .pwdata(pwdata),
  .prdata(prdata),
  .pready(pready),
  .pslverr(pslverr)
);

initial begin
		clk = 1;
	forever #(TIME/2)	clk = ~clk;
end
initial begin
		clk_in[0] = 1;
	forever #(2*TIME/2)	clk_in[0]	 = ~clk_in[0];
end
initial begin
		clk_in[1] = 1;	
	forever #(4*TIME/2) 	clk_in[1]   = ~clk_in[1];
end
initial begin
		clk_in[2] = 1;
	forever #(8*TIME/2) 	clk_in[2]   = ~clk_in[2];
end
initial begin
		clk_in[3] = 1;
	forever #(16*TIME/2)	clk_in[3]   = ~clk_in[3];
end

//`define reset_test
`define tdr_test
`define tcr_test
`define tsr_test
`define null_address
`define read_null_address

`define countup_forkjoin_clk2
`define countup_forkjoin_clk4
`define countup_forkjoin_clk8
`define countup_forkjoin_clk16

`define countdw_forkjoin_clk2
`define countdw_forkjoin_clk4
`define countdw_forkjoin_clk8
`define countdw_forkjoin_clk16

`define countup_pause_countup_clk2
`define countup_pause_countup_clk4
`define countup_pause_countup_clk8
`define countup_pause_countup_clk16

`define countdw_pause_countup_clk2
`define countdw_pause_countup_clk4
`define countdw_pause_countup_clk8
`define countdw_pause_countup_clk16 
     
`define countdw_pause_countdw_clk2
`define countdw_pause_countdw_clk4
`define countdw_pause_countdw_clk8
`define countdw_pause_countdw_clk16

`define countup_reset_countdw_clk2
`define countup_reset_countdw_clk4
`define countup_reset_countdw_clk8
`define countup_reset_countdw_clk16

`define countdw_reset_countup_clk2
`define countdw_reset_countup_clk4
`define countdw_reset_countup_clk8
`define countdw_reset_countup_clk16

`define countup_reset_load_countdw_clk2
`define countdw_reset_load_countdw_clk2
`define fake_underflow
`define fake_overflow
`define fake_faulty_setupstate_to_accessstate_apb
`define fake_set_state_faulty


  initial begin  
	   // reset_test
	   `ifdef reset_test
	      @ (posedge clk);
	     rst_n = 0;
	     #200;
	      @ (posedge clk);
	     rst_n = 1;
	     #200
	      @ (posedge clk);
	     rst_n = 0;
	   `endif
	     
	     @ (posedge clk);// start testcases
	     rst_n = 1;
	    
	   // tdr_test
	   `ifdef tdr_test
      READ(0, value_tdr);
      if(value_tdr != 0) begin
        $display("FAULTY");
        $finish;
        #200;  
      end
      WRITE(8'hEA, 0);
     repeat (20) begin
        READ(0, value_tdr);
        if(value_tdr == 0) begin
 
          $display("FAULTY");
          $finish;
          #200; 
        end  
        else begin
        $display("PASS");
    end
      end 
    `endif  
      
    // tcr_test
    `ifdef tcr_test
      READ(1, value_tcr);
      if(value_tcr != 0) begin
        $display("FAULTY");
//        $finish;
        #200;   
      end
      WRITE($random, 1);
      repeat (20) begin
        READ(1, value_tcr);
        if(value_tcr == 0) begin
          $display("FAULTY");
          $finish;
        #200; 
        end 
        else begin
        $display("PASS");
    end 
      end  
      `endif
      
      // tsr_test
      `ifdef tsr_test
      READ(2, value_tsr);
      if(value_tsr != 0) begin
        $display("FAULTY");  
//        $finish;
        #200;
      end
      WRITE($random, 2);
      repeat (20) begin
        READ(2, value_tsr);
        if(value_tsr == 0) begin
          $display("FAULTY");
          $finish;
          #200;
        end  
        else begin
        $display("PASS");
    end 
      end 
      `endif
      
      //null_address
      `ifdef null_address
      repeat (20) begin
        @(posedge clk);
        WRITE($random,$random); 
       if(pslverr) begin
        $display ("NULL_ADDRESS");
       // $finish;        
       end
       else begin
        READ(0, value_tdr);
        READ(1, value_tcr);
        READ(2, value_tsr);
         repeat (20) begin
           @(posedge clk);
        WRITE($random, 0);
        WRITE($random, 1);
        WRITE($random, 2);  
          READ(0, value_tdr);
          READ(1, value_tcr);
          READ(2, value_tsr);
          end
       end
      end
      `endif
      
      //read_null_address
      `ifdef read_null_address
          READ(4, value_tdr);
          READ(5, value_tcr);
          READ(6, value_tsr);
          @(posedge clk)
          if(pslverr) begin
        $display ("NULL_ADDRESS");
       //$finish;
       //#200; 
     end
      `endif
      
      //countup_forkjoin_clk2
      `ifdef countup_forkjoin_clk2
      $display("runing countup");
	     WRITE ($random, 0);
	    
	     WRITE (8'b10110000, 1);	     
      fork 
      begin//thread 1
       WRITE (8'b00110000, 1);
       READ (0, value_tdr);
 
       while (uut.u_counter.count < 255) begin
       thread_1_debug = thread_1_debug + 1;
       #20;
       end
       repeat(4) begin
      
         @(posedge clk);
         if(uut.u_counter.overflow) begin

          $display("FAULTY"); 
        
//        $finish;
          #200; 
        end
       else begin
         $display("PASS"); 
              
          end
        end

        @(posedge clk);
        @(posedge clk);
       if(uut.u_counter.overflow) begin
          $display("PASS"); 
        // $finish;
        //  #200; 
        end
       else begin
         $display("FAULTY"); 
//          $finish;
          #200;        
          end        
      end

      
      begin//thread 2
      WRITE (8'b00110000, 1);
      READ (0, value_tdr);
      
       while (uut.u_counter.count < 170) begin
       thread_2_debug = thread_2_debug +1;
       #20;
       end
       @(posedge clk)
       if(uut.u_counter.overflow) begin
          $display("FAULTY");
          $finish;
          #200; 
       end
       else begin
         $display("PASS"); 

          //$finish;
          //#200; 
       end
      end
      join
      
      `endif
      
    
      // countup_forkjoin_clk4
      `ifdef countup_forkjoin_clk4
       
       WRITE ($random, 0);
	     WRITE (8'b10110001, 1);	     
      fork 
      begin//thread 1
       WRITE (8'b00110001, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count < 255) begin
       thread_1_debug = thread_1_debug +1;
       #20;
       end
       repeat(5) begin
         @(posedge clk);

         if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
         $finish;
          #200; 
        end
       else begin
         $display("PASS"); 
                
          end
        end
       @ (posedge clk)
       @ (posedge clk)
       if(tb_top_module.uut.u_counter.overflow) begin
          $display("PASS"); 
         // $finish;
         // #200; 
        end
       else begin
         $display("FAULTY"); 
//          $finish;
          #200;        
       end
      end
      
      
      begin //thread 2
       WRITE (8'b00110001, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count < 170) begin
       thread_2_debug = thread_2_debug +1;
       #20;
       end
       @(posedge clk);

       if(uut.u_counter.overflow) begin
          $display("FAULTY");
          $finish;
          #200; 
       end
       else begin
         $display("PASS"); 
         
       end
      end
      join
      `endif
      
      // countup_forkjoin_clk8
      `ifdef countup_forkjoin_clk8
        
       WRITE ($random, 0);
	     WRITE (8'b10110010, 1);	     
      fork 
      begin//thread 1
       WRITE (8'b00110010, 1);
       READ (0, value_tdr);
       while (tb_top_module.uut.u_counter.count < 255) begin
       thread_1_debug = thread_1_debug +1;
       #20;
       end
       repeat(8) begin
         @(posedge clk);

         if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
//         $finish;
          #200; 
        end
       else begin
         $display("PASS"); 
                
          end
        end

       @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("PASS"); 
         
        end
       else begin
         $display("FAULTY"); 

          #200; 
       
       end
      end
      
      begin//thread 2
       WRITE (8'b00110010, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count < 170) begin
       thread_2_debug = thread_2_debug +1;
       #20;
       end
       if(uut.u_counter.overflow) begin
          $display("FAULTY");
          $finish;
          #200; 
       end
       else begin
         $display("PASS"); 
          //$finish;
          //#200; 
       end
      end
      join
      `endif
      
       // countup_forkjoin_clk16
       `ifdef countup_forkjoin_clk16
       
       WRITE ($random, 0);
	     WRITE (8'b10110011, 1);	     
      fork 
      begin//thread 1
       WRITE (8'b00110011, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count < 255) begin
       thread_1_debug = thread_1_debug +1;
       #20;
       end
       repeat(16) begin
         @(posedge clk);

         if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
//         $finish;
          #200; 
        end
       else begin
         $display("PASS"); 
              
          end
        end

       @ (posedge clk)
       if(uut.u_counter.overflow) begin
          $display("PASS"); 
       
        end
       else begin
         $display("FAULTY"); 
          
          #200; 
       
       end
      end
      
      begin//thread 2
       WRITE (8'b00110011, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count < 170) begin
       thread_2_debug = thread_2_debug +1;
       #20;
       end
       if(uut.u_counter.overflow) begin
          $display("FAULTY");
//          
          #200; 
       end
       else begin
         $display("PASS"); 
        
       end
      end
      join
    `endif
   
  
      // countdw_forkjoin_clk2
     `ifdef countdw_forkjoin_clk2
     $display("runing countdw");
       WRITE ($random, 0);
       WRITE (8'b10010000, 1);	     
      fork 
      begin//thread 1
       WRITE (8'b00010000, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count > 0) begin
       thread_1_debug = thread_1_debug - 1;
       #20;
       end
        repeat(4) begin
          @ (posedge clk);

       if(uut.u_counter.underflow) begin
          $display("FAULTY"); 
        $finish;
        #200; 
        end
       else begin
         $display("PASS"); 
        
       
       end
     end

        @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("PASS"); 
       
        end
       else begin
         $display("FAULTY"); 
       
          #200; 
       
       end
      end
      
      begin//thread 2
       WRITE (8'b00010000, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count > 100) begin
       thread_2_debug = thread_2_debug -1;
       #20;
       end
       @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("FAULTY");
          $finish;
          #200; 
       end
       else begin
         $display("PASS"); 
          
       end
      end
      join
      `endif
    
      // countdw_forkjoin_clk4
      `ifdef countdw_forkjoin_clk4
       WRITE ($random, 0);
	     WRITE (8'b10010001, 1);	     
      fork 
      begin//thread 1
       WRITE (8'b00010001, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count > 0) begin
       thread_1_debug = thread_1_debug -1;
       #20;
       end
       repeat(4) begin
          @ (posedge clk);

       if(uut.u_counter.underflow) begin
          $display("FAULTY"); 
        $finish;
        #200; 
        end
       else begin
         $display("PASS"); 
        
       
       end
     end

       @ (posedge clk)
       if(uut.u_counter.underflow) begin
          $display("PASS"); 
         
        end
       else begin
         $display("FAULTY"); 
       
          #200; 
       
       end
      end
      
      begin//thread 2
       WRITE (8'b00010001, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count > 100) begin
       thread_2_debug = thread_2_debug -1;
       #20;
       end
       if(uut.u_counter.underflow) begin
          $display("FAULTY");
          
          #200; 
       end
       else begin
         $display("PASS"); 
          
       end
      end
      join
      `endif
      
      // countdw_forkjoin_clk8
      `ifdef countdw_forkjoin_clk8
       WRITE ($random, 0);
       WRITE (8'b10010010, 1);	     
      fork 
      begin//thread 1
       WRITE (8'b00010010, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count > 0) begin
       thread_1_debug = thread_1_debug -1;
       #20;
       end
       repeat(8) begin
          @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("FAULTY"); 
  
        #200; 
        end
       else begin
         $display("PASS"); 
          
       
       end
     end

        @ (posedge clk)
       if(uut.u_counter.underflow) begin
          $display("PASS"); 
         
        end
       else begin
         $display("FAULTY"); 
     
          #200; 
       
       end
      end
      
      begin//thread 2
       WRITE (8'b00010010, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count > 100) begin
       thread_2_debug = thread_2_debug -1;
       #20;
       end
       if(uut.u_counter.underflow) begin
          $display("PASS");
        
          #200; 
       end
       else begin
         $display("FAULTY"); 
        
       end
      end
      join
    `endif
      
      // countdw_forkjoin_clk16
      `ifdef countdw_forkjoin_clk16
       WRITE ($random, 0);
	     WRITE (8'b10010011, 1);	     
      fork 
      begin//thread 1
       WRITE (8'b00010011, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count > 0) begin
       thread_1_debug = thread_1_debug -1;
       #20;
       end
       repeat(16) begin
          @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("FAULTY"); 
       
        #200; 
        end
       else begin
         $display("PASS"); 
       
       
       end
     end

       @ (posedge clk)
       if(uut.u_counter.underflow) begin
          $display("PASS"); 
      
        end
       else begin
         $display("FAULTY"); 
        
          #200; 
       
       end
      end
      
      begin//thread 2
       WRITE (8'b00010011, 1);
       READ (0, value_tdr);
       while (uut.u_counter.count > 100) begin
       thread_2_debug = thread_2_debug -1;
       #20;
       end
       if(uut.u_counter.underflow) begin
          $display("FAULTY");
        
          #200; 
       end
       else begin
         $display("PASS"); 
          
       end
      end
      join
      `endif
     
    //countup_pause_countup_clk2
    `ifdef countup_pause_countup_clk2
	    WRITE($random, 0);
	    WRITE (8'b10110000, 1);
      WRITE (8'b00110000, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count < 200) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00000000, 1);
       if(uut.u_counter.overflow) begin
          $display("FAULTY");
    
          #200; 
       end
       else begin
         $display("PASS"); 
         
       end
       WRITE (8'b00110000, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
    repeat(3) begin
         @(posedge clk);
         if(uut.u_counter.overflow) begin
          $display("FAULTY"); 

          #200; 
        end
       else begin
         $display("PASS"); 
              
          end
        end
       @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("PASS");
          
       end
       else begin
         $display("FAULTY"); 
   
          #200; 
       end
       `endif

//countup_pause_countup_clk4
`ifdef countup_pause_countup_clk4
	    WRITE($random, 0);
	    WRITE (8'b10110001, 1);
      WRITE (8'b00110001, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count < 200) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00100001, 1);
       if(uut.u_counter.overflow) begin
          $display("FAULTY");
    
          #200; 
       end
       else begin
         $display("PASS"); 
         
       end
       WRITE (8'b00110001, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
    repeat(5) begin
         @(posedge clk);
         if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
         
          #200; 
        end
       else begin
         $display("PASS"); 
                 
          end
        end
       @ (posedge clk)
       if(uut.u_counter.overflow) begin
          $display("PASS");
         
       end
       else begin
         $display("FAULTY"); 
         
          #200; 
       end
       `endif

//countup_pause_countup_clk8
`ifdef countup_pause_countup_clk8
	    WRITE($random, 0);
	    WRITE (8'b10110010, 1);
      WRITE (8'b00110010, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count < 200) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00100010, 1);
       if(uut.u_counter.overflow) begin
          $display("FAULTY");
          $finish;
          #200; 
       end
       else begin
         $display("PASS"); 
          
       end
       WRITE (8'b00110010, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
    repeat(9) begin
         @(posedge clk);
         if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
         $finish;
          #200; 
        end
       else begin
         $display("PASS"); 
            
          end
        end
       @ (posedge clk)
       if(uut.u_counter.overflow) begin
          $display("PASS");
           
       end
       else begin
         $display("FAULTY"); 
    
          #200; 
       end
       `endif

//countup_pause_countup_clk16
`ifdef countup_pause_countup_clk16
	    WRITE($random, 0);
	    WRITE (8'b10110011, 1);
      WRITE (8'b00110011, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count < 200) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00100011, 1);
       if(uut.u_counter.overflow) begin
          $display("FAULTY");
     
          #200; 
       end
       else begin
         $display("PASS"); 
         
       end
       WRITE (8'b00110011, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
    repeat(17) begin
         @(posedge clk);
         if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
     
          #200; 
        end
       else begin
         $display("PASS"); 
               
          end
        end
       @ (posedge clk)
       if(uut.u_counter.overflow) begin
          $display("PASS");
          
       end
       else begin
         $display("FAULTY"); 
        
          #200; 
       end
       `endif

      //countdw_pause_countup_clk2
      `ifdef countdw_pause_countup_clk2
	    WRITE($random, 0);
	    WRITE (8'b10010000, 1);
      WRITE (8'b00010000, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count > 10) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00000000, 1);
       if(uut.u_counter.underflow) begin
          $display("FAULTY");
      
          #200; 
       end
       else begin
         $display("PASS"); 
         
       end
       WRITE (8'b00110000, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
    repeat(3) begin
         @(posedge clk);
         if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
     
          #200; 
        end
       else begin
         $display("PASS"); 
          
          end
        end
       @ (posedge clk)
       if(uut.u_counter.overflow) begin
          $display("PASS");
          
       end
       else begin
         $display("FAULTY"); 
       
          #200; 
       end
       `endif

      //countdw_pause_countup_clk4
      `ifdef countdw_pause_countup_clk4
	    WRITE($random, 0);
	    WRITE (8'b10010001, 1);
      WRITE (8'b00010001, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count > 10) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00000001, 1);
       if(uut.u_counter.underflow) begin
          $display("FAULTY");
          
          #200; 
       end
       else begin
         $display("PASS"); 
        
       end
       WRITE (8'b00110001, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
    repeat(5) begin
         @(posedge clk);
         if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
         
          #200; 
        end
       else begin
         $display("PASS"); 
           
          end
        end
       @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("PASS");
          //$finish;
          #200; 
       end
       else begin
         $display("FAULTY"); 
          
          #200; 
       end
       `endif

      //countdw_pause_countup_clk8
      `ifdef countdw_pause_countup_clk8
	    WRITE($random, 0);
	    WRITE (8'b10010010, 1);
      WRITE (8'b00010010, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count> 10) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00000010, 1);
       @(posedge clk);
       if(uut.u_counter.underflow) begin
          $display("FAULTY");
          
          #200; 
       end
       else begin
         $display("PASS"); 
       
       end
       WRITE (8'b00110010, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
    repeat(9) begin
         @(posedge clk);
         if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
         
          #200; 
        end
       else begin
         $display("PASS"); 
             
          end
        end
       @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("PASS");
          
       end
       else begin
         $display("FAULTY"); 
          
          #200; 
       end
       `endif

      //countdw_pause_countup_clk16
      `ifdef countdw_pause_countup_clk16
	    WRITE($random, 0);
	    WRITE (8'b10010011, 1);
      WRITE (8'b00010011, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count > 10) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00000011, 1);
       if(uut.u_counter.underflow) begin
          $display("FAULTY");
          
          #200; 
       end
       else begin
         $display("PASS"); 
          
       end
       WRITE (8'b00110011, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
    repeat(17) begin
         @(posedge clk);
         if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
        
          #200; 
        end
       else begin
         $display("PASS"); 
            
          end
        end
       @ (posedge clk)
       if(uut.u_counter.overflow) begin
          $display("PASS");
       
       end
       else begin
         $display("FAULTY"); 
          
          #200; 
       end
       `endif
       
      //countdw_pause_countdw_clk2
      `ifdef countdw_pause_countdw_clk2
	    WRITE($random, 0);
	    WRITE (8'b10010000, 1);
      WRITE (8'b00010000, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count > 10) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00000000, 1);
       if(uut.u_counter.underflow) begin
          $display("FAULTY");
          $finish;
          #200; 
       end
       else begin
         $display("PASS"); 
         
       end
       WRITE (8'b00010000, 1);
       while (uut.u_counter.count > 0) begin
      value_debug = value_debug + 1;
      #20;
    end
       repeat(3) begin
          @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("FAULTY"); 
        $finish;
        #200; 
        end
       else begin
         $display("PASS"); 
         
       end
     end
        @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("PASS"); 
       //  $finish;
       //  #200; 
        end
       else begin
         $display("FAULTY"); 
          $finish;
          #200; 
       
       end 
      
       `endif
    
      //countdw_pause_countdw_clk4
      `ifdef countdw_pause_countdw_clk4
	 
	    WRITE($random, 0);
	    WRITE (8'b10010001, 1);
      WRITE (8'b00010001, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count > 10) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00000000, 1);
       if(uut.u_counter.underflow) begin
          $display("FAULTY");
         
          #200; 
       end
       else begin
         $display("PASS"); 
         
       end
       WRITE (8'b00010001, 1);
       while (uut.u_counter.count > 0) begin
      value_debug = value_debug + 1;
      #20;
    end
       repeat(5) begin
          @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("FAULTY"); 
   
        #200; 
        end
       else begin
         $display("PASS"); 
         
       end
     end
        @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("PASS"); 
       //  $finish;
       //  #200; 
        end
       else begin
         $display("FAULTY"); 
    
          #200; 
       
       end 
      
       `endif

      //countdw_pause_countdw_clk8
      `ifdef countdw_pause_countdw_clk8
	   
	    WRITE($random, 0);
	    WRITE (8'b10010010, 1);
      WRITE (8'b00010010, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count > 10) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00000000, 1);
       if(uut.u_counter.underflow) begin
          $display("FAULTY");
         
          #200; 
       end
       else begin
         $display("PASS"); 
         
       end
       WRITE (8'b00010010, 1);
       while (uut.u_counter.count > 0) begin
      value_debug = value_debug + 1;
      #20;
    end
       repeat(9) begin
          @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("FAULTY"); 
     
        #200; 
        end
       else begin
         $display("PASS"); 
         
       end
     end
        @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("PASS"); 
       //  $finish;
       //  #200; 
        end
       else begin
         $display("FAULTY"); 
        
          #200; 
       
       end 
      
       `endif

      //countdw_pause_countdw_clk16
      `ifdef countdw_pause_countdw_clk16
	   
	    WRITE($random, 0);
	    WRITE (8'b10010011, 1);
      WRITE (8'b00010011, 1);
      READ (0, value_tdr);
      while (uut.u_counter.count > 10) begin
      value_debug = value_debug + 1;
      #20;
    end
       WRITE (8'b00000000, 1);
       if(uut.u_counter.underflow) begin
          $display("FAULTY");
         
          #200; 
       end
       else begin
         $display("PASS"); 
         
       end
       WRITE (8'b00010011, 1);
       while (uut.u_counter.count > 0) begin
      value_debug = value_debug + 1;
      #20;
    end
       repeat(17) begin
          @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("FAULTY"); 
   
        #200; 
        end
       else begin
         $display("PASS"); 
         
       end
     end
        @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("PASS"); 
       
        end
       else begin
         $display("FAULTY"); 
          
          #200; 
       
       end 
      
       `endif

  
      //countup_reset_countdw_clk2
     `ifdef countup_reset_countdw_clk2
    WRITE($random, 0);
    WRITE(8'b10100000, 1);
    WRITE(8'b00110000, 1);
    READ (0, value_tdr);
    
    while (uut.u_counter.count < 255) begin
        value_debug = value_debug + 1;
        #20;
    end
    
    WRITE(8'b00000000, 0);
    WRITE(8'b00000000, 1);
    WRITE(8'b00000000, 2);
    
    @(posedge clk);
    if (uut.u_apb_controller.reg_tdr == 0 && uut.u_apb_controller.reg_tcr == 0 && uut.u_apb_controller.reg_tsr == 0) begin
        $display("PASS");
    end else begin
        $display("FAULTY");
        $finish;
        #200;
    end
    
    WRITE(value_debug, 0); // write similar value before the reset
    WRITE(8'b10010000, 1);
    WRITE(8'b00010000, 1);
    
    while (uut.u_counter.count > 0) begin
        value_debug = value_debug + 1;
        #20;
    end
    
    repeat(2) begin
        @(posedge clk);
        if (uut.u_counter.underflow) begin
            $display("FAULTY");
            $finish;
            #200;
        end else begin
            $display("PASS");
        end
    end
    
    @(posedge clk);
    if (uut.u_counter.underflow) begin
        $display("PASS");
    end else begin
        $display("FAULTY");
       
        #200;
    end
`endif


     //countup_reset_countdw_clk4
`ifdef countup_reset_countdw_clk4
    WRITE($random, 0);
    WRITE(8'b10100001, 1);
    WRITE(8'b00110001, 1);
    READ (0, value_tdr);
    
    while (uut.u_counter.count < 255) begin
        value_debug = value_debug + 1;
        #20;
    end
    
    WRITE(8'b00000000, 0);
    WRITE(8'b00000000, 1);
    WRITE(8'b00000000, 2);
    @(posedge clk);
    if (uut.u_apb_controller.reg_tdr == 0 && uut.u_apb_controller.reg_tcr == 0 && uut.u_apb_controller.reg_tsr == 0) begin
        $display("PASS");
    end else begin
        $display("FAULTY");
     
        #200;
    end
    
    WRITE(value_debug, 0); // write similar value before the reset
    WRITE(8'b10010001, 1);
    WRITE(8'b00010001, 1);
    
    while (uut.u_counter.count > 0) begin
        value_debug = value_debug + 1;
        #20;
    end
    
    repeat(4) begin
        @(posedge clk);
        if (uut.u_counter.underflow) begin
            $display("FAULTY");
            $finish;
            #200;
        end else begin
            $display("PASS");
        end
    end
    
    @(posedge clk);
    if (uut.u_counter.underflow) begin
        $display("PASS");
    end else begin
        $display("FAULTY");
      
        #200;
    end
`endif

//countup_reset_countdw_clk8
`ifdef countup_reset_countdw_clk8
    WRITE($random, 0);
    WRITE(8'b10100010, 1);
    WRITE(8'b00110010, 1);
    READ (0, value_tdr);
    
    while (uut.u_counter.count < 255) begin
        value_debug = value_debug + 1;
        #20;
    end
    
    WRITE(8'b00000000, 0);
    WRITE(8'b00000000, 1);
    WRITE(8'b00000000, 2);
    @(posedge clk);
    if (uut.u_apb_controller.reg_tdr == 0 && uut.u_apb_controller.reg_tcr == 0 && uut.u_apb_controller.reg_tsr == 0) begin
        $display("PASS");
    end else begin
        $display("FAULTY");
   
        #200;
    end
    
    WRITE(value_debug, 0); // write similar value before the reset
    WRITE(8'b10010010, 1);
    WRITE(8'b00010010, 1);
    
    while (uut.u_counter.count > 0) begin
        value_debug = value_debug + 1;
        #20;
    end
    
    repeat(8) begin
        @(posedge clk);
        if (uut.u_counter.underflow) begin
            $display("FAULTY");
     
            #200;
        end else begin
            $display("PASS");
        end
    end
    
    @(posedge clk);
    if (uut.u_counter.underflow) begin
        $display("PASS");
    end else begin
        $display("FAULTY");
 
        #200;
    end
`endif

//countup_reset_countdw_clk16
`ifdef countup_reset_countdw_clk16
    WRITE($random, 0);
    WRITE(8'b10100011, 1);
    WRITE(8'b00110011, 1);
    READ (0, value_tdr);
    
    while (uut.u_counter.count < 255) begin
        value_debug = value_debug + 1;
        #20;
    end
    
    WRITE(8'b00000000, 0);
    WRITE(8'b00000000, 1);
    WRITE(8'b00000000, 2);
    @(posedge clk);
    if (uut.u_apb_controller.reg_tdr == 0 && uut.u_apb_controller.reg_tcr == 0 && uut.u_apb_controller.reg_tsr == 0) begin
        $display("PASS");
    end else begin
        $display("FAULTY");
      
        #200;
    end
    
    WRITE(value_debug, 0); // write similar value before the reset
    WRITE(8'b10010011, 1);
    WRITE(8'b00010011, 1);
    
    while (uut.u_counter.count > 0) begin
        value_debug = value_debug + 1;
        #20;
    end
    
    repeat(16) begin
        @(posedge clk);
        if (uut.u_counter.underflow) begin
            $display("FAULTY");
            #200;
        end else begin
            $display("PASS");
        end
    end
    
    @(posedge clk);
    if (uut.u_counter.underflow) begin
        $display("PASS");
    end else begin
        $display("FAULTY");
       
        #200;
    end
`endif

      
      //countdw_reset_countup_clk2
      `ifdef countdw_reset_countup_clk2
        WRITE($random, 0);
        WRITE(8'b10000000, 1);
        WRITE(8'b00010000, 1);
        READ (0, value_tdr);
        while (uut.u_counter.count > 0) begin
          value_debug = value_debug + 1;
          #20;
        end
        
        WRITE(8'b00000000, 0);
        WRITE(8'b00000000, 1);
        WRITE(8'b00000000, 2);
        @(posedge clk);
        if(uut.u_apb_controller.reg_tdr == 0  & uut.u_apb_controller.reg_tcr == 0 & uut.u_apb_controller.reg_tsr == 0) begin
          $display("PASS"); 
       
        end
       else begin
         $display("FAULTY"); 
          
          #200;        
       end 
       
        WRITE(value_debug, 0);//write similar value before the reset
        WRITE(8'b10110000, 1);
        WRITE(8'b00110000, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
       repeat(2) begin
          @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
      
        #200; 
        end
       else begin
         $display("PASS"); 
           
       
       end
     end
        @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("PASS"); 
     
        end
       else begin
         $display("FAULTY"); 
       
          #200; 
       
       end             
      `endif

      //countdw_reset_countup_clk4
      `ifdef countdw_reset_countup_clk4
         WRITE($random, 0);
        WRITE(8'b10000001, 1);
        WRITE(8'b00010001, 1);
        READ (0, value_tdr);
        while (uut.u_counter.count > 0) begin
          value_debug = value_debug + 1;
          #20;
        end
        
        WRITE(8'b00000000, 0);
        WRITE(8'b00000000, 1);
        WRITE(8'b00000000, 2);
        @(posedge clk);
        if(uut.u_apb_controller.reg_tdr == 0  & uut.u_apb_controller.reg_tcr == 0 & uut.u_apb_controller.reg_tsr == 0) begin
          $display("PASS"); 
       
        end
       else begin
         $display("FAULTY"); 
          
          #200;        
       end 
       
        WRITE(value_debug, 0);//write similar value before the reset
        WRITE(8'b10110001, 1);
        WRITE(8'b00110001, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
       repeat(4) begin
          @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
    
        #200; 
        end
       else begin
         $display("PASS"); 
           
       
       end
     end
        @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("PASS"); 
     
        end
       else begin
         $display("FAULTY"); 
    
          #200; 
       
       end             
      `endif

      //countdw_reset_countup_clk8
      `ifdef countdw_reset_countup_clk8
         WRITE($random, 0);
        WRITE(8'b10000010, 1);
        WRITE(8'b00010010, 1);
        READ (0, value_tdr);
        while (uut.u_counter.count > 0) begin
          value_debug = value_debug + 1;
          #20;
        end
        
        WRITE(8'b00000000, 0);
        WRITE(8'b00000000, 1);
        WRITE(8'b00000000, 2);
        @(posedge clk);
        if(uut.u_apb_controller.reg_tdr == 0  & uut.u_apb_controller.reg_tcr == 0 & uut.u_apb_controller.reg_tsr == 0) begin
          $display("PASS"); 
       
        end
       else begin
         $display("FAULTY"); 
          
          #200;        
       end 
       
        WRITE(value_debug, 0);//write similar value before the reset
        WRITE(8'b10110010, 1);
        WRITE(8'b00110010, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
       repeat(8) begin
          @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
   
        #200; 
        end
       else begin
         $display("PASS"); 
           
       
       end
     end
        @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("PASS"); 
     
        end
       else begin
         $display("FAULTY"); 
 
          #200; 
       
       end             
      `endif

      //countdw_reset_countup_clk16
      `ifdef countdw_reset_countup_clk16
         WRITE($random, 0);
        WRITE(8'b10000011, 1);
        WRITE(8'b00010011, 1);
        READ (0, value_tdr);
        while (uut.u_counter.count > 0) begin
          value_debug = value_debug + 1;
          #20;
        end
        
        WRITE(8'b00000000, 0);
        WRITE(8'b00000000, 1);
        WRITE(8'b00000000, 2);
        @(posedge clk);
        if(uut.u_apb_controller.reg_tdr == 0  & uut.u_apb_controller.reg_tcr == 0 & uut.u_apb_controller.reg_tsr == 0) begin
          $display("PASS"); 
       
        end
       else begin
         $display("FAULTY"); 
          
          #200;        
       end 
       
        WRITE(value_debug, 0);//write similar value before the reset
        WRITE(8'b10110011, 1);
        WRITE(8'b00110011, 1);
       while (uut.u_counter.count < 255) begin
      value_debug = value_debug + 1;
      #20;
    end
       repeat(16) begin
          @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("FAULTY"); 
  
        #200; 
        end
       else begin
         $display("PASS"); 
           
       
       end
     end
        @ (posedge clk);
       if(uut.u_counter.overflow) begin
          $display("PASS"); 
     
        end
       else begin
         $display("FAULTY"); 
      
          #200; 
       
       end             
      `endif

      //countup_reset_load_countdw_clk2
      `ifdef countup_reset_load_countdw_clk2
        WRITE($random, 0);
        WRITE(8'b10100000, 1);
        WRITE(8'b00110000, 1);
        READ (0, value_tdr);
        while (uut.u_counter.count < 255) begin
          value_debug = value_debug + 1;
          #20;
        end
        
        WRITE(8'b00000000, 0);
        WRITE(8'b00000000, 1);
        WRITE(8'b00000000, 2);
        @(posedge clk);
       if(uut.u_apb_controller.reg_tdr == 0  & uut.u_apb_controller.reg_tcr == 0 & uut.u_apb_controller.reg_tsr == 0) begin
          $display("PASS"); 
        end
       else begin
         $display("FAULTY"); 
       
          #200;        
       end 
       
        WRITE($random, 0);//write new random value after the reset
        WRITE(8'b10010000, 1);
        WRITE(8'b00010000, 1);
       while (uut.u_counter.count > 0) begin
      value_debug = value_debug + 1;
      #20;
    end
       repeat(2) begin
          @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("FAULTY"); 
      
        #200; 
        end
       else begin
         $display("PASS"); 
        
       end
     end
        @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("PASS"); 
       
        end
       else begin
         $display("FAULTY"); 
 
          #200; 
       
       end
      `endif
        
        //countdw_reset_load_countdw_clk2
        `ifdef countdw_reset_load_countdw_clk2
         WRITE($random, 0);
        WRITE(8'b10000000, 1);
        WRITE(8'b00010000, 1);
        READ (0, value_tdr);
        while (uut.u_counter.count < 255) begin
          value_debug = value_debug + 1;
          #20;
        end
        
        WRITE(8'b00000000, 0);
        WRITE(8'b00000000, 1);
        WRITE(8'b00000000, 2);
        @(posedge clk);
       if(uut.u_apb_controller.reg_tdr == 0  & uut.u_apb_controller.reg_tcr == 0 & uut.u_apb_controller.reg_tsr == 0) begin
          $display("PASS"); 
        end
       else begin
         $display("FAULTY"); 
   
          #200;        
       end 
       
        WRITE($random, 0);//write new random value after the reset
        WRITE(8'b10010000, 1);
        WRITE(8'b00010000, 1);
       while (uut.u_counter.count > 0) begin
      value_debug = value_debug + 1;
      #20;
    end
       repeat(2) begin
          @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("FAULTY"); 
      
        #200; 
        end
       else begin
         $display("PASS"); 
        
       end
     end
        @ (posedge clk);
       if(uut.u_counter.underflow) begin
          $display("PASS"); 
       
        end
       else begin
         $display("FAULTY"); 
 
          #200; 
       
       end
      `endif
      
        //fake_underflow
        `ifdef fake_underflow
        WRITE(8'h00, 0);
        WRITE(10000000, 1);
        WRITE(00000000, 1);
        WRITE(8'hFF, 0);
        WRITE(10000000, 1);
        WRITE(00000000, 1);
        if(uut.u_apb_controller.reg_tsr == 2) begin
          $display("underflow");
           
        end
      else begin
          $display("not underflow");
          $finish;
          #200; 
     end   
         `endif 
          
          //fake_overflow
        `ifdef fake_overflow
        WRITE(8'hFF, 0);
        WRITE(10100000, 1);
        WRITE(00100000, 1);
        WRITE(8'h00, 0);
        WRITE(10100000, 1);
        WRITE(00100000, 1);
        if(uut.u_apb_controller.reg_tsr == 1) begin
          $display("overflow");
         
        end
      else begin
          $display("not overflow");
          
     end   
         `endif
         
         //fake_faulty_setupstate_to_accessstate_apb
        `ifdef fake_faulty_setupstate_to_accessstate_apb
            @(posedge clk);
            WRITE_FAULTE(10, 0);
            @(posedge clk);
            if(uut.u_apb_controller.next_state == 0) begin
            $display("PASS");
            end
            else begin
            $display("FAULTY");
            $finish;
            #200;
            end
        `endif 
        
        //fake_set_state_faulty
        `ifdef fake_set_state_faulty
            @(posedge clk);
            uut.u_apb_controller.state = 3;
            @(posedge clk);
            if (uut.u_apb_controller.next_state == 0) begin
                $display("PASS");
            end
            else begin
            $display("FAULTY");
            $finish;
            #200;
            end
        `endif
        
$stop;
 end
//*****

task WRITE;
	input	[7:0]	data_in;
	input	[7:0]	addr;
	begin
		@(posedge clk); //none
		penable	= 0;
		pwrite	= 0;
		psel	= 0;
		pwdata	= 0;
		paddr	= 0;
		@(posedge clk); //setup
		pwrite  = 1;
   	psel    = 1;
    pwdata  = data_in;
    paddr   = addr;    
		@(posedge clk); //access		
		penable	= 1;
		wait (pready == 1);
		@(posedge clk);
		penable	= 0;
		pwrite	= 0;
		psel	= 0;
		pwdata	= 0;
		paddr	= 0;
		if(pslverr)
			$display ("write %d to %d unsuccessfully\n", data_in, addr);
		else
			$display ("write %d to %d successfully\n", data_in, addr);
	end
endtask			

task WRITE_FAULTE;
  	input	[7:0]	data_in;
	 input	[7:0]	addr;
	 begin
	@(posedge clk); //none
    penable	= 0;
		pwrite	= 0;
		psel	= 0;
		pwdata	= 0;
	  paddr	= 0;
		@(posedge clk); //setup
		pwrite  = 1;
 	  psel    = 1;
    pwdata  = data_in;
    paddr   = addr;
    @(posedge clk); //IDLE
    penable	= 0;	

  end
endtask		
    				
task READ;
	input	[7:0]	addr;
	output	[7:0]	data_out;	
	begin
		@(posedge clk); //none                 
		penable	= 0;
		pwrite	 = 0;
		psel    = 0;
		pwdata	 = 0;
		paddr	  = 0;
		@(posedge clk); //setup
   	psel    = 1;
    paddr   = addr;
		@(posedge clk); //access
		penable	= 1;
		wait (pready == 1);
		@(posedge clk);
		penable	= 0;
		pwrite	 = 0;
		psel	   = 0;
		pwdata	 = 0;
		paddr	  = 0;
		data_out= prdata;		
		if(pslverr)
			$display ("read from %d unsuccessfully\n", addr);			
		else
			$display ("read from %d successfully\n", addr);			
	end
endtask						

endmodule











