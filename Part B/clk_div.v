`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2022 03:59:14 PM
// Design Name: 
// Module Name: clk_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_div(
    input CLK,
    output CLK_2
    );
    reg [18:0] COUNT;
    
    assign CLK_2 = COUNT[18]; // 21 for part A
    //assign CLK_2 = CLK;
    //reg [21:0] COUNT; for part A
    
    initial begin
    COUNT <= 0;
    end
            
    always @(posedge CLK) begin
        COUNT <= COUNT + 1;
    end
    
endmodule