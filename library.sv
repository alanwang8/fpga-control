//`default_nettype none // Required in every sv file


//Comparator:returns if A equal to B
module Comparator
  #(parameter WIDTH = 4)
  ( input logic [WIDTH-1:0] A, [WIDTH-1:0] B,
    output logic AeqB);

  assign AeqB = (A == B);

endmodule : Comparator

//MagComp: compares magnitude
module MagComp
  #(parameter WIDTH = 8)
  ( input logic [WIDTH-1:0] A, [WIDTH-1:0] B,
    output logic AltB, AeqB, AgtB);

  assign AltB = (A < B);
  assign AeqB = (A == B);
  assign AgtB = (A > B);

endmodule : MagComp


//Adder: Sum becomes A + B with the carryout and carry out being set
// on overflow
module Adder
  #(parameter WIDTH = 4)
  (input logic [WIDTH-1:0] A, [WIDTH-1:0] B,
    input logic cin,
    output logic [WIDTH-1:0] sum,
    output logic cout);
  
  //will never overflow since we are adding n bit and n bit so 
  //output is always n+1 bit
  logic [WIDTH:0] result;
  logic [WIDTH-1:0] zeros = {WIDTH{1'b0}};
  assign result = A + B + {zeros,cin};

  assign sum = result[WIDTH-1:0];
  assign cout = result[WIDTH];

endmodule : Adder

//Subtracter: diff becomes A - B with the bin and bou out being set
// on overflow
module Subtracter
  #(parameter WIDTH = 4)
  (input logic [WIDTH-1:0] A, [WIDTH-1:0] B,
    input logic bin,
    output logic [WIDTH-1:0] diff,
    output logic bout);
  
  //will never overflow since we are subtracting n bit and n bit so 
  //output is always n+1 bit
  logic [WIDTH:0] result;
  logic [WIDTH-1:0] zeros = {WIDTH{1'b0}};
  assign result = A - B - {zeros,bin};

  assign diff = result[WIDTH-1:0];
  assign bout = result[WIDTH];

endmodule : Subtracter


//Multiplexer. traditional multiplexer
module Multiplexer
  #(parameter WIDTH = 4)
  ( input logic [WIDTH-1:0] I, [$clog2(WIDTH)-1:0] S,
    output logic Y);

  assign Y = I[S];

endmodule : Multiplexer

//Mux2to1: n bit multiplexer
module Mux2to1
  #(parameter WIDTH = 7)
  ( input logic S, [WIDTH-1:0] I0, [WIDTH-1:0] I1,
    output logic [WIDTH-1:0] Y);
    
  always_comb begin
    if(S)
      Y = I1;
    else
      Y = I0;
  end

endmodule : Mux2to1

//Decoder. the Ith bit of D is turned on iff en
module Decoder
  #(parameter WIDTH = 8)
  (input logic en, [$clog2(WIDTH)-1:0] I,
    output logic [WIDTH-1:0] D);

  always_comb begin
    D = {WIDTH{1'b0}};
    if(en)
      D[I] = 1'b1;
  end

endmodule : Decoder


//Definition of Dflipflop with both preset and reset options
module DFlipFlop
  (input logic D,
   input logic clock, preset_L, reset_L,
   output logic Q);
  
  logic reset, preset;

  always_ff @(posedge clock, negedge reset_L, negedge preset_L)
  begin
    reset = ~reset_L;
    preset = ~preset_L;
    case ({reset, preset}) 
      2'b00: Q <= D;
      2'b01: Q <= 1'b1;
      2'b10: Q <= 1'b0;
      2'b11: Q <= 1'bx;
    endcase
  end
    
endmodule : DFlipFlop


//Definition of Register
module Register 
  #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] D,
   input logic clock, clear, en,
   output logic [WIDTH-1:0] Q);
  
  always_ff @(posedge clock)
    unique casez ({en, clear})
      2'b00 : Q <= Q;
      2'b01 : Q <= {WIDTH{1'b0}};
      2'b1? : Q <= D;
      default : Q <= Q;
    endcase
    
endmodule : Register

//Definition of counter
module Counter 
  #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] D,
   input logic clock, clear, en,
   input logic load, up,
   output logic [WIDTH-1:0] Q);
  
  always_ff @(posedge clock)
    unique casez ({clear, load, en, up})
      4'b1??? : Q <= {WIDTH{1'b0}};
      4'b01?? : Q <= D;
      4'b0011 : Q <= Q + 1;
      4'b0010 : Q <= Q - 1;
      4'b000? : Q <= Q;
      default : Q <= Q;
    endcase

endmodule : Counter


//Definition of Serial in Parralel out shift register
module ShiftRegisterSIPO 
  #(parameter WIDTH = 8)
  (input logic serial,
   input logic clock, left, en,
   output logic [WIDTH-1:0] Q);
  
  always_ff @(posedge clock)
    unique casez ({en, left})
      2'b0? : Q <= Q;
      2'b10 : Q <= {serial, Q[WIDTH-1:1]};
      2'b11 : Q <= {Q[WIDTH-2:0], serial};
      default : Q <= Q;
    endcase

endmodule : ShiftRegisterSIPO

//Definition of Parralel in Parralel out shift register
module ShiftRegisterPIPO 
  #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] D,
   input logic clock, left, en, load,
   output logic [WIDTH-1:0] Q);
  
  always_ff @(posedge clock)
    unique casez ({load, en, left})
      3'b1?? : Q <= D;
      3'b00? : Q <= Q;
      3'b011 : Q <= Q << 1;
      3'b010 : Q <= Q >> 1;
    endcase

endmodule : ShiftRegisterPIPO

//Definition of barrel shift register
module BarrelShiftRegister
  #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] D,
   input logic clock, en, load,
   input logic [1:0] by,
   output logic [WIDTH-1:0] Q);
  
  always_ff @(posedge clock)
    unique casez ({load, en})
      2'b1? : Q <= D;
      2'b00 : Q <= Q;
      2'b01 : Q <= Q << by;
    endcase

endmodule : BarrelShiftRegister


//Definition of Synchronizer
module Synchronizer
  (input logic clock, async,
   output logic sync);
  
  always_ff @(posedge clock)
    sync <= async;

endmodule : Synchronizer

//Definition of busDriver
module BusDriver
  #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] data,
   output logic [WIDTH-1:0] buff,
   input logic en,
   inout wire [WIDTH-1:0] bus);
  
  assign buff = bus;
  assign bus = en ? data : {WIDTH{1'bz}};

endmodule : BusDriver


//Definition of memory
module Memory
  #(parameter AW = 8,
    parameter DW = 8)
  (input logic [AW-1:0] addr,
   input wire re, we, clock,
   inout wire [DW-1:0] data);

  logic [2**AW-1:0] [DW-1:0] RAM;
  logic [DW-1:0] rData;

  assign data = (re) ? rData: {DW{1'bz}};

  always_comb
    rData = RAM[addr];

  always_ff @(posedge clock)
    if (we)
      RAM[addr] <= data;

endmodule : Memory