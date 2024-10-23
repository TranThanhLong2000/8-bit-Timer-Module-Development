`timescale 1ps/1ps
module counter (
    input          clk,
    input          rst_n,
    input          enable,
    input          up_down,
    input          load,
    input          clk_ena,
    input  [7:0]   start_counter,
    output reg     overflow,
    output reg     underflow
);

    reg  [7:0] count;  
    reg [7:0] prev_count; 
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            prev_count <= 0;
            overflow <= 0;  
            underflow <= 0; 
        end else begin
            if (load) begin
                count <= start_counter;  
            end else if (enable & clk_ena) begin
                prev_count <= count;
                if (up_down) begin
                    count <= count + 1;  
                end else begin
                    count <= count - 1;  
                end

                // Check for overflow and underflow
                overflow <= (prev_count == 8'hFF && count == 8'h00);
                underflow <= (prev_count == 8'h00 && count == 8'hFF);
            end
        end
    end
endmodule
