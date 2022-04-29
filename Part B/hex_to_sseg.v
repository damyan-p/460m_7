`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2022 03:56:59 PM
// Design Name: 
// Module Name: hex_to_sseg
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


module hex_to_sseg(
    input [3:0] x,
    output reg [6:0] r
    );

    always @(*)
        case (x)                        //  4'bxxxx: r =    gfedcba;
            4'b0000: r = 7'b1000000;    //  40
            4'b0001: r = 7'b1111001;    //  79
            4'b0010: r = 7'b0100100;    //  24
            4'b0011: r = 7'b0110000;    //  30
            4'b0100: r = 7'b0011001;    //  19
            4'b0101: r = 7'b0010010;    //  12
            4'b0110: r = 7'b0000010;    //  02
            4'b0111: r = 7'b1111000;    //  78
            4'b1000: r = 7'b0000000;    //  00
            4'b1001: r = 7'b0010000;    //  10
            4'b1010: r = 7'b0001000;
            4'b1011: r = 7'b0000011;
            4'b1100: r = 7'b1000110;
            4'b1101: r = 7'b0100001;
            4'b1110: r = 7'b0000110;
            4'b1111: r = 7'b0001110;
        endcase
endmodule