`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/29/2022 08:58:38 AM
// Design Name: 
// Module Name: dispFSM
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


module dispFSM(
input CLK_2,
input [6:0] in0,
input [6:0] in1,
input [6:0] in2,
input [6:0] in3,
output [3:0] an,
output [6:0] sseg
    );
    
    reg [6:0] sseg_reg;
    reg [3:0] an_reg;
    reg [1:0] state;
    reg [1:0] next_state;

    initial begin
    sseg_reg <= 0;
    an_reg <= 0;
    state <= 0;
    next_state <= 0;
    end
    
    assign an = an_reg;
    assign sseg = sseg_reg;
    
    always @ (*) begin
        case(state)
        default: begin
            state = 2'b00;
            next_state = 2'b01;
            end
        2'b00: next_state = 2'b01;
        2'b01: next_state = 2'b10;
        2'b10: next_state = 2'b11;
        2'b11: next_state = 2'b00;
        endcase
    end
    
    always @ (*) begin
        case(state)
        2'b00: begin
        an_reg = 4'b1110;
        sseg_reg = in0;
        end
        2'b01: begin
        an_reg = 4'b1101;
        sseg_reg = in1;
        end
        2'b10: begin
        an_reg = 4'b1011;
        sseg_reg = in2;
        end
        2'b11: begin
        an_reg = 4'b0111;
        sseg_reg = in3;
        end
        endcase
    end
    
    always @(posedge CLK_2) begin
    state <= next_state;
    end    


endmodule
