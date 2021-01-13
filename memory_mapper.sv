`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// cturgeon
//////////////////////////////////////////////////////////////////////////////////


module memory_mapper(
    input wire cpu_wr,
    input wire [31:0] cpu_addr,
    output wire [31:0] cpu_readdata,
    output wire lights_wr,
    output wire sound_wr,
    input wire [31:0] accel_val,
    input wire [31:0] keyb_char,
    output wire smem_wr,
    input wire [31:0] smem_readdata,
    output wire dmem_wr,
    input wire [31:0] dmem_readdata,
    output wire seg_wr
    );
    
    assign seg_wr = (cpu_wr & cpu_addr[17:16] == 2'b00 & cpu_addr[3:2] == 2'b00) ? 1'b1: 0;
    
    assign lights_wr = (cpu_wr & cpu_addr[17:16] == 2'b11 & cpu_addr[3:2] == 2'b11) ? 1'b1 : 0;
    assign sound_wr = (cpu_wr & cpu_addr[17:16] == 2'b11 & cpu_addr[3:2] == 2'b10) ? 1'b1 : 0;
    
    assign smem_wr = (cpu_wr & cpu_addr[17:16] == 2'b10) ? 1'b1 : 0;
    assign dmem_wr = (cpu_wr & cpu_addr[17:16] == 2'b01) ? 1'b1 : 0;
    
    
    assign cpu_readdata = (cpu_addr[17:16] == 2'b11 & cpu_addr[3:2] == 2'b01) ? accel_val:
                          (cpu_addr[17:16] == 2'b11 & cpu_addr[3:2] == 2'b00) ? keyb_char:
                          (cpu_addr[17:16] == 2'b10) ? smem_readdata: 
                          (cpu_addr[17:16] == 2'b01) ? dmem_readdata: 0;
       
endmodule
