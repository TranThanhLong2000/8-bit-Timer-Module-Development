module apb_controller (
    input  clk,
    input  rst_n,
    input  psel,
    input  penable,
    input  pwrite,
    input  [7:0] paddr,
    input  [7:0] pwdata,
    output reg [7:0] prdata,
    output reg pready,
    output reg pslverr,
    output [7:0] start_counter,  
    output load,                 
    output up_down,              
    output  enable,               
    output [1:0] clk_sel,        
    input overflow,
    input underflow
);

// IDLE, SETUP, ACCESS
localparam
    IDLE   = 0,
    SETUP  = 1,
    ACCESS = 2;

reg [1:0] state; // sequential logic
reg [1:0] next_state; // combinational logic
reg [7:0] reg_tdr, reg_tcr, reg_tsr;

// State machine logic

always @(*) begin
	case(state)
	IDLE: begin
		if (psel & !penable)
			next_state = SETUP;
		else 
			next_state = IDLE;
	end
	SETUP: begin
		if (psel & penable)
			next_state = ACCESS;
		else
			next_state = IDLE;
	end
	ACCESS: begin
			next_state = IDLE;
	end
	default: begin
			next_state = IDLE;
	end
	endcase
end

always @ (posedge clk) begin 
	if(!rst_n)
		state		<= IDLE;
	else
		state		<= next_state;
end

// Write operations
always @(posedge clk) begin
    if (!rst_n) begin
        reg_tdr <= 8'b0;
        reg_tcr <= 8'b0;
        reg_tsr <= 8'b0;
   end else if ((state == ACCESS) && pwrite) begin
  
        case (paddr)
            8'h0: reg_tdr <= pwdata;
            8'h1: reg_tcr <= pwdata;
            8'h2: reg_tsr <= pwdata;  
        endcase
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        reg_tsr <= 8'b0;
    end else if (overflow || underflow) begin
        reg_tsr <= {6'b0, underflow, overflow};  
    end else if (state == ACCESS && pwrite && (paddr == 8'h02)) begin
        reg_tsr[0] <= reg_tsr[0] & ~1'b1; // Clear overflow
        reg_tsr[1] <= reg_tsr[1] & ~1'b1;  // Clear underflow
    end
end



// Read operations
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prdata <= 8'b0;
  end else if (state == ACCESS && !pwrite) begin
      
        case (paddr)
            8'h0: prdata <= reg_tdr;
            8'h1: prdata <= reg_tcr;
            8'h2: prdata <= reg_tsr;
            default: prdata <= 8'b0;
        endcase
    end
end

// Ready and error signals
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pready <= 0;
        pslverr <= 0;
    end else begin
       // pready <= (state == ACCESS);
       pready <= (psel && penable);
       pslverr <= (state == ACCESS) && (paddr > 8'h02); // Error if address is greater than 0x02
        
    end
end

// Assign values to outputs

  assign start_counter  = reg_tdr;       
   assign load          = reg_tcr[7];   
   assign up_down       = reg_tcr[5];    
   assign enable        = reg_tcr[4];    
  assign clk_sel        = reg_tcr[1:0];  


endmodule
