module vga( // 20x15 
  input clk, reset,
  input  [7:0] vdata,
  output [7:0] vaddr, // 2^9 = 512
  output [2:0] VGA_R, VGA_G, 
  output [1:0] VGA_B, 
  output VGA_HS_O, VGA_VS_O);

  reg [7:0] CounterX, CounterY;
  reg inDisplayArea;
  reg vga_HS, vga_VS;

  wire CounterXmaxed = (CounterX == 800); // 16 + 48 + 96 + 640
  wire CounterYmaxed = (CounterY == 525); // 10 +  2 + 33 + 480
  wire [4:0] col;
  wire [3:0] row;

  always @(posedge clk or posedge reset)
    if (reset)
      CounterX <= 0;
    else 
      if (CounterXmaxed)
        CounterX <= 0;
      else
        CounterX <= CounterX + 1;

  always @(posedge clk or posedge reset)
    if (reset)
      CounterY <= 0;
    else 
      if (CounterXmaxed)
        if(CounterYmaxed)
          CounterY <= 0;
        else
          CounterY <= CounterY + 1;

  assign row = (CounterY>>5); // 32 pixels x
  assign col = (CounterX>>5); // 32 pixels 
  assign vaddr = col + (row<<4) + (row<<2); // addr = col + row x 20

  always @(posedge clk)
  begin
    vga_HS <= (CounterX > (640 + 16) && (CounterX < (640 + 16 + 96)));   // active for 96 clocks
    vga_VS <= (CounterY > (480 + 10) && (CounterY < (480 + 10 +  2)));   // active for  2 clocks
    inDisplayArea <= (CounterX < 640) && (CounterY < 480);
  end

  assign VGA_HS_O = ~vga_HS;
  assign VGA_VS_O = ~vga_VS;  

  assign VGA_R = inDisplayArea ? {vdata[5:4], 2'b00} : 4'b0000;
  assign VGA_G = inDisplayArea ? {vdata[3:2], 2'b00} : 4'b0000;
  assign VGA_B = inDisplayArea ? {vdata[1:0], 2'b00} : 4'b0000;
endmodule

module mojo_top(
    // 50MHz clock input
    input        clk,
    // Our stuff
    input        extrun,
    input        extload,
    input        extauto,
    input        extstep,
    input        extclear,
    input        extstart,
    input  [3:0] extaddr,
    input  [7:0] extdata,
    input  [7:0] vdata,
    output [7:0] DBOUT,
    output [3:0] ABOUT,
    output [6:0] ss,
    output       an0,
    output       an1,
  	output [7:0] led,
  	output [7:0] vaddr,
  	output logic [7:0] VGA_COLOR,
  	output logic VGA_HS_O, VGA_VS_O
);
  
    // Buses and control signals
    wire		pixel_clk;
  	wire		reset;
    wire  [7:0] DBUS; // Data Bus
    wire  [3:0] ABUS; // Address
    wire        CLK;
    wire        nCLK;
    wire        CLR;
    wire        nCLR;
    wire        Cp;
    wire        Ep;
    //wire        nLm;
    wire        nWE;
    wire        nCE;
    wire        CS;
    wire        nLi;
    wire        nEi;
    wire        nLa;
    wire        Ea;
    wire        Su;
    wire        Eu;
    wire        nLb;
    wire        nLo;
    wire [7:0]  alua;
    wire [7:0]  alub;
    wire        run;
    wire        nHLT;
    wire [3:0]  opcode;
    wire [7:0]  OBUS;
    wire [5:0]  state;
    
    assign led[0] = state[0];
    assign led[1] = state[1];
    assign led[2] = state[2];
    assign led[3] = state[3];
    assign led[4] = state[4];
    assign led[5] = state[5];
    assign led[6] = 1'b0;
    assign led[7] = CLK;
    
    in IN(
      .clk(clk),
      .extaddr(extaddr),
      .extdata(extdata),
      .extrun(extrun),
      .extload(extload),
      .extauto(extauto),
      .extstep(extstep),
      .extclear(extclear),
      .extstart(extstart),
      .nHLT(nHLT),
      .ABUS(ABUS),
      .DBUS(DBUS),
      .nWE(nWE),
       .CS(CS),
      .CLR(CLR),
      .nCLR(nCLR),
      .CLK(CLK),
      .nCLK(nCLK),
      .run(run)    
    );
    
    cu CU(
      .CLK(CLK),
      .nCLR(nCLR),
      .run(run),
      .opcode(opcode),
      .Cp(Cp),
      .Ep(Ep),
      .nWE(nWE),
      .nCE(nCE),
      //.nLm(nLm),
      .CS(CS),
      .nLi(nLi),
      .nEi(nEi),
      .nLa(nLa),
      .Ea(Ea),
      .Su(Su),
      .Eu(Eu),
      .nLb(nLb),
      .nLo(nLo),
      .nHLT(nHLT),
      .state(state)
    );
    
    pc PC(
      .Cp(Cp),
      .nCLK(nCLK),
      .nCLR(nCLR),
      .Ep(Ep),
      .ABUS(ABUS)
    );  
    
    ir IR(
      .CLK(CLK),
      .nLi(nLi),
      .nEi(nEi),
      .CLR(CLR),
      .DBUS(DBUS),
      .ABUS(ABUS),
      .opcode(opcode)
    );
    
    mem MEM(
      //.CLK(CLK),
      //.nLm(nLm),
      .nWE(nWE),
      .nCE(nCE),
       .CS(CS),
      .ABUS(ABUS),
      .DBUS(DBUS),
      .ma(ABOUT),
      .md(DBOUT)
    );
    
    accumulator ACCUMULATOR(
      .CLK(CLK),
      .nLa(nLa),
      .Ea(Ea),
      .DBUS(DBUS),
      .ALU(alua)
    );
    
    regb REGB(
      .CLK(CLK),
      .nLb(nLb),
      .DBUS(DBUS),
      .ALU(alub)
    );
    
    alu ALU(
      .ina(alua),
      .inb(alub),
      .Su(Su),
      .Eu(Eu),
      .DBUS(DBUS)
    );
    
    out OUT(
      .CLK(CLK),
      .CLR(CLR),
      .nLo(nLo),
      .DBUS(DBUS),
      .OBUS(OBUS)
    );
    
    sevseg SEVSEG(
      .clk(clk),
      .CLR(CLR),
      .OBUS(OBUS),
      .ss(ss),
      .an0(an0),
      .an1(an1)
    );
  
  vga vga(
    pixel_clk,
    reset,
    vdata,
    vaddr,
    VGA_COLOR[2:0],
    VGA_COLOR[5:3],
    VGA_COLOR[7:6],
    VGA_HS_O,
    VGA_VS_O
  );

endmodule







`timescale 1ns / 1ps
/**
* Accumulator / Register A
*
* CLK    = Clock.
* nLa    = Load Register A (Write). 0 - Write
* Ea     = Write to WBUS.
* in     = From the WBUS
* out    = To the WBUS
* ALU    = Data to ALU
*/
module accumulator(
    input        CLK,
    input        nLa,
    input        Ea,
    inout  [7:0] DBUS,
    output [7:0] ALU
);
  
    reg  [7:0] accreg;
    
    initial
    begin
        accreg <= 8'b0000_0000;
    end
    
    assign DBUS = (Ea) ? accreg : 8'bzzzz_zzzz;
    assign ALU  =  accreg;
    
    always @(posedge CLK)
    begin
        if(!nLa)
        begin
            // Load from DBUS
            //$display("%t ACC - Loading: %b", $realtime, DBUS);
            accreg <= DBUS;
        end
        else if(Ea)
        begin
            //$display("%t ACC - OUTPUTTING: %b", $realtime, accreg);
        end
        /**
        else
        begin
            accreg <= accreg;
        end
        **/
    end
endmodule
`timescale 1ns / 1ns
/**
 * 8-bit simple ALU
 *
 * ina  = From Accumulator (Register A)
 * inb  = From Register B.
 * Su   = Operation. 0 = Add, 1 = Sub.
 * Eu   = Enable output to WBUS
 * DBUS = Data bus.
 */
module alu(
  input  [7:0] ina,
  input  [7:0] inb,
  input        Su,
  input        Eu,
  output [7:0] DBUS
);

  // If Eu is high and Su is high, subtract Register B from Accumulator and output to the DBUS
  // If Eu is high and Su is low, Add Accumulator to Register B and output to the DBUS
  // If Eu is low, then go hi-impededance on the DBUS.
  assign DBUS = (Eu) ? ((Su) ? (ina - inb) : (ina + inb)) : 8'bzzzz_zzzz;
  
  always @(DBUS or Eu)
  begin
    if(Eu)
    begin
        //$display("%t ALU IS OUTPUTING", $realtime);
    end
  end
endmodule
`timescale 1ns / 1ps
/**
* Control Unit (CU)
*
* CLK    = Clock
* nCLR   = Clear (inversed)
* run    = From in
* state  = T-State from RC
* opcode = From IR
*
* Control Signals:
* Cp     = Increment PC
* Ep     = Enable PC ouput to WBUS (1 = Enable)
* nWE    = Write Enable (load) to RAM (0 = load)
* nCE    = Enable output of RAM data to WBUS (0 = enable)
* nLi    = Load Instruction Register from WBUS (0 = load)
* nEi    = Enable ouput of address from Instruction Register to lower 4 bits of WBUS (0 = enable)
* nLa    = Load data into the accumulator from WBUS (0 = load)
* Ea     = Enable ouput of accumulator to WBUS (1 = enable)
* Su     = ALU operation (0 = Add, 1 = Subtract)
* Eu     = Enable output of ALU to WBUS (1 = enable)
* nLb    = Load data into Register B from WBUS (0 = load)
* nLo    = Load data into Output Register (0 = load)
* enio   = Enable output from Input Register (1 = enable)
* nHLT   = Inverse Halt operation. (0 = HALT)
*/
module cu(
    input            CLK,
    input            nCLR,
    input            run,
    input      [3:0] opcode,
    output reg       Cp,
    output reg       Ep,
    output           CS,
    output           nWE,
    output reg       nCE,
    output reg       nLi,
    output reg       nEi,
    output reg       nLa,
    output reg       Ea,
    output reg       Su,
    output reg       Eu,
    output reg       nLb,
    output reg       nLo,
    output reg       nHLT,
    output     [5:0] state
);

    // Ring Counter (rc.v)
    rc RC(
        .CLK(CLK),
        .nCLR(nCLR),
        .state(state)
    );  

    // T-States
    parameter T1    = 6'b000001;
    parameter T2    = 6'b000010;
    parameter T3    = 6'b000100;
    parameter T4    = 6'b001000;
    parameter T5    = 6'b010000;
    parameter T6    = 6'b100000;
    
    reg CSreg;
    
    // Assign some of our signals out of the door.
    assign    nWE   = (!run) ? 1'bz : 1'b1;
    assign    CS    = (!run) ? 1'bz : CSreg;
    
    initial
    begin
        //nLm   <= 1;
        Cp    <= 0;
        Ep    <= 0;
        nLb   <= 1;
        nCE   <= 1;
        CSreg <= 0;
        nLi   <= 1;
        nEi   <= 1;
        Ea    <= 0;
        nLa   <= 1;
        Su    <= 0;
        Eu    <= 0;
        nLo   <= 1;
        nHLT  <= 1;
      end
      
      always @(negedge CLK)
      begin
        if(!nCLR)
        begin
            // Reset out values
            //$display("%t CU RESET", $realtime);
            Cp    <= 0;
            Ep    <= 0;
            nLb   <= 1;
            nCE   <= 1;
            CSreg <= 0;
            nLi   <= 1;
            nEi   <= 1;
            Ea    <= 0;
            nLa   <= 1;
            Su    <= 0;
            Eu    <= 0;
            nLo   <= 1;
            nHLT  <= 1;
        end
        else if(!run)
        begin
            // Program mode
            //$display("%t CU IN PROGRAM MODE", $realtime);
            Cp    <= 0;
            Ep    <= 0;
            nLb   <= 1;
            nCE   <= 1;
            CSreg <= 0;
            nLi   <= 1;
            nEi   <= 1;
            Ea    <= 0;
            nLa   <= 1;
            Su    <= 0;
            Eu    <= 0;
            nLo   <= 1;
            nHLT  <= 1;
        end
        else if(run && nHLT)
        begin
            // Running mode
            //$display("CU IN RUNNING MODE");
            case (state)
                T1:
                begin
                    // Ouput the PC, pull data from memory and store in IR.
                    // Clear previous signals
                    Cp    <= 0;
                    nLb   <= 1;
                    nEi   <= 1;
                    Ea    <= 0;
                    nLa   <= 1;
                    Su    <= 0;
                    Eu    <= 0;
                    nLo   <= 1;
                    nHLT  <= 1;             
                       
                    // Set
                    //nLm   <= 0;
                    Ep    <= 1;
                    nCE   <= 0;
                    nLi   <= 0;
                    CSreg <= 1;
                    //$display("%t CU T1: EP=1, nCE=0, nLi=0", $realtime);
                end
                  
                T2:
                begin
                    // Clear previous signals
                    //nLm   <= 1;
                    Ep    <= 0;
                    nCE   <= 1;
                    CSreg <= 0;
                    nLi   <= 1;
                    // Set
                    //$display("%t CU T2", $realtime);
                end
                T3:
                begin
                    // Set
                    Cp    <= 1;
                       
                    case(opcode)
                        4'b0000:
                        begin
                            // LDA (Output from mem based on IR address)
                            nCE   <= 0;
                            //CSreg <= 1;
                            nEi   <= 0;
                            nLa   <= 0;
                            //$display("%t CU T3: LDA - nEi = 0, nCE = 0, nLa = 0", $realtime);
                        end
                        
                        4'b0001:
                        begin
                            // ADD  (Output from mem based on IR address)
                            nCE   <= 0;
                            //CSreg <= 1;
                            nEi   <= 0;
                            nLb   <= 0;
                            //$display("%t CU T3: ADD - nEi = 0, nCE = 0, nLb = 0", $realtime);
                        end
                        
                        4'b0010:
                        begin
                            // SUB (Output from mem based on IR address)
                            nCE   <= 0;
                            //CSreg <= 1;
                            nEi   <= 0;
                            nLb   <= 0;
                            //$display("%t CU T3: SUB - nEi = 0, nCE = 0, nLb = 0", $realtime);
                        end
                        4'b1110:
                        begin
                            // OUT (Output data from Accumulator)
                            Ea  <= 1;
                            nLo <= 0;
                            //$display("%t CU T3: OUT - Ea = 1, nLo = 0", $realtime);
                        end
                        4'b1111:
                        begin
                            // HTL (Stop this crazy thing!)
                            nHLT <= 0;
                            //$display("%t CU T3: HLT - nHLT = 0", $realtime);
                        end
                        default:
                        begin
                            //$display("%t CU T3: Unknow OPCODE", $realtime);
                        end
                    endcase
                end
                  
                T4:
                begin
                    // Clear previous signals
                    //nLm   <= 1;
                    nEi   <= 1;
                    nCE   <= 1;
                    CSreg <= 0;
                    nLa   <= 1;
                    nLb   <= 1;
                    Ea    <= 0;
                    nLo   <= 1;
                    Cp    <= 0;
                
                    case(opcode)
                        4'b0000:
                        begin
                            // LDA
                            //$display("%t CU T4: LDA", $realtime);
                        end
                        
                        4'b0001:
                        begin
                            // ADD  (Load from ALU to Accumlator)
                            Eu  <= 1;
                            nLa <= 0;
                            //$display("%t CU T4: ADD - Eu = 1, nLa = 0", $realtime);
                        end
                        
                        4'b0010:
                        begin
                            // SUB (Load from ALU to Accumlator)
                            Eu  <= 1;
                            Su  <= 1;
                            nLa <= 0;
                            //$display("%t CU T4: SUB - Eu = 1, Su = 1, nLa = 0", $realtime);
                        end
                        4'b1110:
                        begin
                            // OUT
                            //$display("%t CU T4: OUT", $realtime);
                        end
                        4'b1111:
                        begin
                            // HLT
                            //$display("%t CU T4: HLT - Eu = 1, nLa = 0", $realtime);
                        end
                        default:
                        begin
                            Cp    <= 0;
                            Ep    <= 0;
                            nLb   <= 1;
                            nCE   <= 1;
                            CSreg <= 0;
                            nLi   <= 1;
                            nEi   <= 1;
                            Ea    <= 0;
                            nLa   <= 1;
                            Su    <= 0;
                            Eu    <= 0;
                            nLo   <= 1;
                            nHLT  <= 1;
                            //$display("%t CU T4: Unknown OPCODE - Reset", $realtime);
                        end
                    endcase
                end
                
                default:
                begin
                    Cp    <= 0;
                    Ep    <= 0;
                    nLb   <= 1;
                    nCE   <= 1;
                    CSreg <= 0;
                    nLi   <= 1;
                    nEi   <= 1;
                    Ea    <= 0;
                    nLa   <= 1;
                    Su    <= 0;
                    Eu    <= 0;
                    nLo   <= 1;
                    nHLT  <= 1;
                    //$display("%t CU: Unknown State - RESET", $realtime);
                end
            endcase
        end
        else
        begin
            Cp    <= 0;
            Ep    <= 0;
            nLb   <= 1;
            nCE   <= 1;
            CSreg <= 0;
            nLi   <= 1;
            nEi   <= 1;
            Ea    <= 0;
            nLa   <= 1;
            Su    <= 0;
            Eu    <= 0;
            nLo   <= 1;
            nHLT  <= 1;
            //$display("%t CU: Unknown Input state - RESET", $realtime);
        end
    end
endmodule
`timescale 1ns / 1ps
module debounce(
    input      clk,
    input      in,
    output     out
);
	reg [19:0] ctr_d;
	reg [19:0] ctr_q;
	reg [1:0]  sync_d;
	reg [1:0]  sync_q;
 
	assign out = ctr_q == {20{1'b1}};
 
	always @(*)
	begin
		sync_d[0] = in;
		sync_d[1] = sync_q[0];
		ctr_d     = ctr_q + 1'b1;
 
		if (ctr_q == {20{1'b1}})
		begin
			ctr_d = ctr_q;
		end
 
		if (!sync_q[1])
		begin
			ctr_d = 20'd0;
		end
	end
 
	always @(posedge clk)
	begin
		ctr_q  <= ctr_d;
		sync_q <= sync_d;
	end
endmodule
/**
 * Input from external buttons and switches
 */
 
`timescale 1ns / 1ps
module in (
    input        clk,
    input  [3:0] extaddr,
    input  [7:0] extdata,
    input        extrun,
    input        extload,
    input        extauto,
    input        extstep,
    input        extclear,
    input        extstart,
    input        nHLT,
    inout [3:0] ABUS,
    inout [7:0] DBUS,
    output       nWE,
    output       CS,
    output       CLR,
    output       nCLR,
    output       CLK,
    output       nCLK,
    output       run  
);
  
    reg         creg             = 1'b0;
    reg  [24:0] ccnt             = 25'd0;
    reg         start            = 1'b0;
    reg         sprev            = 1'b0;
    
    debounce stepclean (clk, extstep,  step);
    debounce startclean(clk, extstart, startc);
    
    assign load                  = extload;
    assign CLR                   = extclear;
    assign nCLR                  = ~extclear;
    assign run                   = extrun;
    assign auto                  = extauto;
    assign CLK                   = (run && !auto) ? step : (run && auto) ? creg :  1'b0;
    assign nCLK                  = ~CLK;
    assign {ABUS, DBUS, nWE, CS} = (!run) ? {extaddr, extdata, ~load, load} : {4'bzzzz, 8'bzzzz_zzzz, 1'bz, 1'bz};
    
    // Clock generator and stuff
    always @(posedge clk or posedge CLR)
    begin
        if(CLR)
        begin
            // CLEAR
            start <= 1'b0;
            sprev <= 1'b0;
            ccnt  <= 3'b000;
            creg  <= 1'b0;
        end
        else
        begin
            if(!nHLT)
            begin
                creg <= 1'b0;
            end
            else if(run && auto)
            begin
                if(start)
                begin
                    // 1Hz Clock
                    {ccnt, creg} <= (ccnt == 25'd24_999_999) ? {25'd0, ~creg} : { ccnt + 1'b1, creg};
                    //{ccnt, creg} <= (ccnt == 25'd4) ? {25'd0, ~creg} : { ccnt + 1'b1, creg};
                end
                if(startc)
                begin
                    // Stop the spamming of start
                    if(!sprev)
                    begin
                        sprev <= 1'b1;
                        start <= ~start;
                    end
                end
                else
                begin
                    if(sprev)
                    begin
                        sprev <= 1'b0;
                    end
                end
            end
        end
    end
endmodule
module sevseg(
    input        clk,
    input        CLR,
    input  [7:0] OBUS,
    output [6:0] ss,
    output       an0,
    output       an1
);
  
    //reg        sclk;
    reg [12:0] sscnt;
    reg [6:0]  ssreg;
    reg [3:0]  sstmp;
    reg        aclk;
    //reg [7:0]  ncnt;
    reg [3:0]  stmp;
    
    assign ss        = ssreg;
    assign an0       = aclk;
    assign an1       = ~aclk;
    
    initial
    begin
        //sclk  <= 1'b0;
        //ncnt  <= 1'b0;
        sscnt <= 16'b0;
        ssreg <= 7'b0111111;
        sstmp <= 4'b0;
        aclk  <= 1'b0;
        stmp  <= 1'b0;
    end
    
    always @(posedge clk or posedge CLR)
    begin
        if (CLR)
        begin
            //sclk  <= 1'b0;
            sscnt <= 16'b0;
            ssreg <= 7'b0111111;
            sstmp <= 4'b0;
            aclk  <= 1'b0;
            //ncnt  <= 1'b0;
            stmp  <= 1'b0;
        end
        else
        begin
            // 1KHz clocking for the 7 segement display selection (an0 and an1).
            if(sscnt == 4999)
            begin
                sstmp <= (aclk) ? {OBUS[3], OBUS[2], OBUS[1], OBUS[0]} : {OBUS[7], OBUS[6], OBUS[5], OBUS[4]};
                
                case(sstmp)
                    4'h0:
                    begin
                      ssreg <= 7'b1000000;
                    end
                    4'h1:
                    begin
                      ssreg <= 7'b1111001;
                    end
                    4'h2:
                    begin
                      ssreg <= 7'b0100100;
                    end
                    4'h3:
                    begin
                      ssreg <= 7'b0110000;
                    end
                    4'h4:
                    begin
                      ssreg <= 7'b0011001;
                    end
                    4'h5:
                    begin
                      ssreg <= 7'b0010010;
                    end
                    4'h6:
                    begin
                      ssreg <= 7'b0000010;
                    end
                    4'h7:
                    begin
                      ssreg <= 7'b1111000;
                    end
                    4'h8:
                    begin
                      ssreg <= 7'b0000000;
                    end
                    4'h9:
                    begin
                      ssreg <= 7'b0011000;
                    end
                    4'ha:
                    begin
                      ssreg <= 7'b0001000;
                    end
                    4'hb:
                    begin
                      ssreg <= 7'b0000011;
                    end
                    4'hc:
                    begin
                      ssreg <= 7'b1000110;
                    end
                    4'hd:
                    begin
                      ssreg <= 7'b0100001;
                    end
                    4'he:
                    begin
                      ssreg <= 7'b0000110;
                    end
                    4'hf:
                    begin
                      ssreg <= 7'b0001110;
                    end
                    default:
                    begin
                      ssreg <= 7'b0111111;
                    end
                endcase
                
                aclk  <= ~aclk;
            end
            else
            begin
                sstmp <= sstmp;
                ssreg <= ssreg;
            end
            
            sscnt <= (sscnt == 13'd4999) ? 13'd0 : sscnt + 1'd1;
        end
    end
endmodule
`timescale 1ns / 1ps
/**
 * Reg B / Register B
 *
 * CLK    = Clock.
 * nLb    = Load to Register B. 0 = Load
 * DBUS   = The data bus. 
 * ALU    = Data to ALU
 */
module regb(
  input        CLK,
  input        nLb,
  input  [7:0] DBUS,
  output [7:0] ALU
);

    reg [7:0] regbreg;
  
    initial
    begin
        regbreg <= 8'b0000_0000;
    end

    assign ALU  = regbreg;
  
    always @(posedge CLK)
    begin 
        if(!nLb)
        begin
            // Load Reg B from DBUS
            //$display("%t REGB Loading: %d", $realtime, DBUS);
            regbreg <= DBUS;
        end
    end
endmodule
/**
 * Ring counter
 * Generates the T-States for the Control Unit (CU)
 */
`timescale 1ns / 1ps
module rc (
  input            CLK,
  input            nCLR,
  output reg [5:0] state
);
  
    initial
    begin
      state <= 6'b00000;
    end
    
    always @(negedge CLK or negedge nCLR)
    begin
        if(!nCLR)
        begin
            state <= 6'b000000;
        end
        else
        begin
            case(state)
                6'b00000:
                begin
                  state <= 6'b000001;
                end
                6'b00001:
                begin
                  state <= 6'b000010;
                end
                6'b000010:
                begin
                  state <= 6'b000100;
                end
                6'b000100:
                begin
                  state <= 6'b001000;
                end
                6'b001000:
                begin
                  //state <= 6'b010000;
                  state <= 6'b000001;
                end
                6'b010000:
                begin
                  state <= 6'b000001;
                end
                default:
                begin
                  state <= 6'b000000;
                end
            endcase
        end
    end
endmodule
`timescale 1ns / 1ps
/**
* 4-Bit Program Counter - Increment or Clear operation
*
* Cp   = Increment Count
* nCLK = Clock - Triggered on negative edge of CLK.
* nCLR = Clear - 0 = Clear
* Ep   = Enable output to ABUS.
*/
module pc(
    input        Cp,
    input        nCLK,
    input        nCLR,
    input        Ep,
    output [3:0] ABUS
);
  
    reg    [3:0] cnt;

    initial
    begin
      cnt <= 4'b0000;
    end
      
    assign ABUS = (Ep) ? cnt : 4'bzzzz;
    
    always @(negedge nCLK or negedge nCLR)
    begin
        if(!nCLR)
        begin
            cnt <= 4'b0000;
        end  
        else if(Cp)
        begin
            //$display("%t Incrementing the PC", $realtime);
            cnt <= (cnt == 4'd15) ? 4'b0 : cnt + 1'b1;
        end
        else if(Ep)
        begin
            //$display("%t Ouputting the PC", $realtime);
        end
        else 
        begin
            cnt <= cnt;
        end
    end
endmodule
`timescale 1ns / 1ps
/**
* Ouput Register /
*
* CLK  = Clock
* nLo  = Load data from ABUS & DBUS
* ABUS = Address bus
* DBUS = Data bus
* OBUS = Output bus
*/
module out(
    input        CLK,
    input        CLR,
    input        nLo,
    input  [7:0] DBUS,
    output [7:0] OBUS
);
  
  reg [7:0] OBUSreg;
  
  assign OBUS = OBUSreg;

  initial
  begin
    OBUSreg <= 8'b0000_0000;
  end

  always @(negedge CLK or posedge CLR)
  begin
    if(CLR)
      begin
        OBUSreg <= 8'b0000_0000;
      end
    else if(!nLo)
      begin
      // Load from DBUS
      OBUSreg <= DBUS;
    end
  end
endmodule


`timescale 1ns / 1ps
/**
* Program Memory (RAM) - 16 Bytes (8 bits x 16 address)
* No need for MAR, since we have a seperate address bus.
* nWE  = Write Enable. 0 - Write to memory.
* nCE  = Chip Enable / Enabled the output. 0 - Read from RAM.
* nLm  = Load address. 0 - Load.
* ABUS = Address bus.
* ma   = LED Output for address.
* md   = LED Output for data.
*/
module mem (
    //input            CLK,
    //input            nLm,  // Store address (0 = store)
    input      [3:0] ABUS, // Address Bus
    input            nWE,  // Write enable (0 = write)
    input            nCE,  // Read enable (0 = read)
    input            CS,   // Chip Select
    inout      [7:0] DBUS, // Data Bus
    output     [3:0] ma,
    output     [7:0] md
);
  
    reg [7:0] ram [0:15]; // Memory array
    reg [4:0] addr;
    reg [7:0] out;
    
    initial
    begin
        ram[0]  = 8'b0000_0000;
        ram[1]  = 8'b0000_0000;
        ram[2]  = 8'b0000_0000;
        ram[3]  = 8'b0000_0000;
        ram[4]  = 8'b0000_0000;
        ram[5]  = 8'b0000_0000;
        ram[6]  = 8'b0000_0000;
        ram[7]  = 8'b0000_0000;
        ram[8]  = 8'b0000_0000;
        ram[9]  = 8'b0000_0000;
        ram[10] = 8'b0000_0000;
        ram[11] = 8'b0000_0000;
        ram[12] = 8'b0000_0000;
        ram[13] = 8'b0000_0000;
        ram[14] = 8'b0000_0000;
        ram[15] = 8'b0000_0000;
    end
    
    assign ma   = ABUS;
    assign md   = ram[ABUS];
    assign DBUS = (!nCE) ? out : 8'bzzzz_zzzz;
    
    /**
    always @(CLK or nLm)
    begin
      if(!nLm)
         begin
          $display("%t MEM SAVING ADDRESS: %b", $realtime, ABUS);
          addr <= ABUS;
       end
    end
    **/
    
    always @(nWE or nCE or DBUS or ABUS)
    begin
        if(!nWE)
        begin
            // Write data from DBUS to memory @ address from ABUS
            //$display("%t MEM LOADING: %b to ADDR: %b", $realtime, DBUS, ABUS);
            ram[ABUS] <= DBUS;
        end
        else if(!nCE)
        begin
            // Ouput the data @ address from ABUS
            //$display("%t MEM OUTPUTTING: %b from ADDR: %b", $realtime, ram[ABUS], ABUS);
            //out <= ram[addr];
            out <= ram[ABUS];
        end
        else
        begin
        end
    end
endmodule
`timescale 1ns / 1ps
/**
* Instruction Registor (IR)
*
* CLK       = Clock.
* nLi       = Load Load from WBUS (8-bit). 0 = load.
*             Bits 7 - 4 = opcode
*             Bits 7 - 0 = address
* nEi       = Output Address. 0 = Output to lower part of WBUS (4-bit).
* CLR       = Clear.
* WBUS      = 8-Bit data bus.
*
* ABUS   = Address is put back on ABUS.
* opcode    = OP Code is sent to CU.
*/
module ir(
    input            CLK,
    input            nLi,
    input            nEi,
    input            CLR,
    input      [7:0] DBUS,
    output reg [3:0] ABUS,
    output     [3:0] opcode
);
  
    // Some registers
    reg    [3:0] OPCODEreg;
    reg    [3:0] ADDRreg;
    
    assign opcode = OPCODEreg;
    
    initial
    begin
      OPCODEreg <= 4'b0000;
      ADDRreg   <= 4'b0000;
      ABUS      <= 4'bzzzz;
    end
    
    always @(CLR or nLi or nEi or DBUS)
    begin
        if(CLR)
        begin
            OPCODEreg <= 4'b0000;
            ADDRreg   <= 4'b0000;
            ABUS      <= 4'bzzzz;
            //$display("%t IR: CLR - RESET", $realtime);
        end
        else if(!nLi)
        begin
            // Load our data
            //$display("%t IR LOADING: %b", $realtime, DBUS);
            OPCODEreg <= DBUS[7:4];
            ADDRreg   <= DBUS[3:0];
            ABUS      <= 4'bzzzz;
        end
        else if(!nEi)
        begin
            ABUS <= ADDRreg;
        end
        else
        begin
            // Stop the latch warnings.
            OPCODEreg <= OPCODEreg;
            ADDRreg   <= ADDRreg;
            ABUS      <= 4'bzzzz;
        end
    end
endmodule