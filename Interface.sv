`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2025 13:57:19
// Design Name: 
// Module Name: Interface
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


interface dlx_processor();

// processor inputs
//input reg clk;
logic clk, rst;
logic enable_ex;
logic [31:0] src1, src2, imm, mem_data_read_in;
logic [6:0] control_in;

// processor output and ALU input
logic [2:0] opselect, operation;
logic enable_arith, enable_shift;
logic [31:0] aluin1, aluin2;
logic [4:0] shift_number;

//outputs
logic carry, mem_data_wr_en;
logic [31:0] aluout, mem_data_write_out;

modport execute_processor(input clk, rst, input enable_ex, src1, src2, imm, mem_data_read_in, control_in, 
output operation, opselect, enable_arith, enable_shift, aluin1, aluin2, shift_number, mem_data_wr_en, mem_data_write_out);

modport ALU(input clk, rst, input enable_ex, operation, opselect, enable_arith, enable_shift, aluin1, aluin2, shift_number, 
output aluout, carry);

parameter CLK_PERIOD      = 10;      
parameter REGISTER_WIDTH  = 32;  
parameter INSTR_WIDTH     = 32;     
parameter IMMEDIATE_WIDTH = 16; 

// Instruction Types
parameter MEM_READ   = 3'b101;    
parameter MEM_WRITE  = 3'b100;   
parameter ARITH_LOGIC = 3'b001; 
parameter SHIFT_REG  = 3'b000;   

// ARITHMETIC 
parameter ADD  = 3'b000;         
parameter HADD = 3'b001;        
parameter SUB  = 3'b010;         
parameter NOT  = 3'b011;         
parameter AND  = 3'b100;         
parameter OR   = 3'b101;          
parameter XOR  = 3'b110;         
parameter LHG  = 3'b111;         

// SHIFTING 
parameter SHLEFTLOG  = 3'b000;   
parameter SHLEFTART  = 3'b001;   
parameter SHRGHTLOG  = 3'b010;   
parameter SHRGHTART  = 3'b011;   

// DATA TRANSFER
parameter LOADBYTE   = 3'b000;    
parameter LOADBYTEU  = 3'b100;   
parameter LOADHALF   = 3'b001;    
parameter LOADHALFU  = 3'b101;   
parameter LOADWORD   = 3'b011;
endinterface

