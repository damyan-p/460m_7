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
            4'b0000: r = 7'b1000000;    //  x0 = x40
            4'b0001: r = 7'b1111001;    //  x1 = x79
            4'b0010: r = 7'b0100100;    //  x2 = x24
            4'b0011: r = 7'b0110000;    //  x3 = x30
            4'b0100: r = 7'b0011001;    //  x4 = x19
            4'b0101: r = 7'b0010010;    //  x5 = x12
            4'b0110: r = 7'b0000010;    //  x6 = x02
            4'b0111: r = 7'b1111000;    //  x7 = x78
            4'b1000: r = 7'b0000000;    //  x8 = x00
            4'b1001: r = 7'b0010000;    //  x9 = x10
            4'b1010: r = 7'b0001000;    //  xA = x08
            4'b1011: r = 7'b0000011;    //  xB = x03
            4'b1100: r = 7'b1000110;    //  xC = x46
            4'b1101: r = 7'b0100001;    //  xD = x21
            4'b1110: r = 7'b0000110;    //  xE = x06
            4'b1111: r = 7'b0001110;    //  xF = x0E
        endcase
endmodule