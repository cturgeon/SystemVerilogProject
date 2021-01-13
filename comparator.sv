`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2020 12:30:37 PM
// Design Name: 
// Module Name: comparator
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


module comparator(
  input wire FlagN, FlagV, FlagC, bool0,
  output wire comparison
    );
    
    assign comparison = (bool0) ? ~FlagC : (~bool0) ? FlagN ^ FlagV : 1'b1;
    
endmodule
