`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// cturgeon
//////////////////////////////////////////////////////////////////////////////////


module memIO #(
    parameter wordsize = 32,                      
    parameter dmem_size = 1024,
    parameter dmem_init = "noname.mem",
    parameter Nchars = 4,
    parameter smem_size = 1200,
    parameter smem_init = "noname.mem"
    )(
    input wire cpu_wr,
    input wire [31:0] cpu_addr,
    output wire [31:0] cpu_readdata,
    input wire [31:0] cpu_writedata,
    input wire clk,
    output logic [15:0] lights,
    output logic [31:0] period, 
    input wire [31:0] accel_val, 
    input wire [31:0] keyb_char, 
    
    input wire [10:0] vga_addr,    // screen addr / smem_addr
    output wire [3:0] vga_readdata, // charcode  / char_code
    output logic [31:0] segdisplay
    );
    wire lights_wr;
    wire sound_wr;
    wire smem_wr;
    wire dmem_wr;
    wire seg_wr;
    
    always_ff @(posedge clk)
    begin
        if (seg_wr)
            segdisplay = cpu_writedata[31:0];  
    end
    
    always_ff @(posedge clk)
        begin
            if (lights_wr)
                lights = cpu_writedata[15:0]; 
        end
        
    always_ff @(posedge clk)
        begin
            if (sound_wr)
                period = cpu_writedata[31:0];  
        end
     
    wire [3:0] cpu_charcode; // comes out of read-write port of smem
    ram_module_2port #(smem_size, Nchars, smem_init) myscreenmem(clk, smem_wr, cpu_addr[31:2], vga_addr, cpu_writedata, cpu_charcode, vga_readdata); // 2port ram module
   
    wire [31:0] dmem_readdata;
    ram_module #(dmem_size, wordsize, dmem_init) mydatamem(clk, dmem_wr, cpu_addr[31:2], cpu_writedata, dmem_readdata);
    
    wire [31:0] smem_readdata = {27'b0, cpu_charcode}; // pad charcode with 0s before going to memory mapper
    memory_mapper mymemorymapper(cpu_wr, cpu_addr, cpu_readdata, lights_wr, sound_wr, accel_val, keyb_char, smem_wr, smem_readdata, dmem_wr, dmem_readdata, seg_wr); 
endmodule
