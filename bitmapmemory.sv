`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2020 04:26:36 PM
// Design Name: 
// Module Name: bitmapmemory
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


module bitmapmemory #(
    parameter Abits=12,
    parameter Dbits=12,
    parameter Nloc=2560,
    parameter bmem_init = "noname.mem"
)(
    input wire [Abits-1:0] bitmap_addr,
    output wire [Dbits-1:0] color_value
    );
    
    logic [Dbits-1:0] mem [Nloc-1:0];
    initial $readmemh(bmem_init, mem, 0, Nloc-1);
    
    assign color_value = mem[bitmap_addr];
    
endmodule
