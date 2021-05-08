module up_tb;
  logic clock, reset, we;
  logic [7:0] address, ir, pc;
  wire [7:0] data;
  
  uP proc(clock, reset, data, we, address, pc, ir);
//  mem #("fibo.hex") ram(clock, we, address, data); 
  mem #("fibo.bin") ram(clock, we, address, data); 
  
  initial
    begin
      $dumpfile("dump.vcd"); $dumpvars(0);
      reset <= 1; #22; reset <= 0;
      #5000; $stop;
    end

  always
    begin
      clock <= 1; #5; clock <= 0; #5;
    end
endmodule
