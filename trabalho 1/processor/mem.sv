module mem #(parameter filename = "ram.hex")
          (input clock, we,
           input [7:0] address,
           inout [7:0] data);

  logic [7:0] RAM[255:0];

  initial
    // $readmemh(filename, RAM); //Hex file
    $readmemb(filename, RAM); //Bin file

  assign data = we ? 'bz : RAM[address]; 

  always @(posedge clock)
    if (we) RAM[address] <= data;
endmodule

