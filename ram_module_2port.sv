//////////////////////////////////////////////////////////////////////////////////
// cturgeon
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none



module ram_module_2port #(
   parameter Nloc = 16,                      // Number of memory locations
   parameter Dbits = 4,                      // Number of bits in data
   parameter initfile = "noname.mem"         // Name of file with initial values (file should not exist)
)(
   input wire clock,
   input wire wr,                            // WriteEnable:  if wr==1, data is written into mem
   input wire [$clog2(Nloc)-1 : 0] addr1,     // Address for specifying memory location
   input wire [$clog2(Nloc)-1 : 0] addr2,
                                             //   num of bits in addr is ceiling(log2(number of locations))
   input wire [Dbits-1 : 0] din,             // Data for writing into memory (if wr==1)
   output wire [Dbits-1 : 0] dout1,            // Data read from memory (asynchronously, i.e., continuously)
   output wire [Dbits-1 : 0] dout2
   );

   logic [Dbits-1 : 0] mem [Nloc-1 : 0];     // The actual storage where data resides
   initial $readmemh(initfile, mem, 0, Nloc-1); // Initialize memory contents from a file

   always_ff @(posedge clock)                // Memory write: only when wr==1, and only at posedge clock
      if(wr)
         mem[addr1] <= din;

   assign dout1 = mem[addr1];                  // Memory read: read continuously, no clock involved
   assign dout2 = mem[addr2];

endmodule