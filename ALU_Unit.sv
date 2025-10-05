`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2025 16:11:16
// Design Name: 
// Module Name: ALU_Unit
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


module ALU_Unit(dlx_processor if2);

logic [31:0]shift_aluout, arith_aluout;
logic h_carry;
logic [if2.IMMEDIATE_WIDTH -1:0]h_add;
always_ff@(posedge if2.clk or negedge if2.rst)
begin
    //reset
    if(!if2.rst)
    begin
        if2.aluout = 0; if2.carry = 0; shift_aluout = 0; arith_aluout = 0;
    end 
    
    //shift ALU
    if(if2.enable_shift)
    begin
        case(if2.opselect[1:0])
        if2.SHLEFTLOG : shift_aluout = {1'b0, if2.aluin1 << if2.operation};
        if2.SHLEFTART : shift_aluout = {if2.aluin1[if2.REGISTER_WIDTH-1], if2.aluin1 << if2.operation};
        if2.SHRGHTLOG : shift_aluout = {1'b0, if2.aluin1 >> if2.operation };
        if2.SHRGHTART : shift_aluout = {1'b0, $signed(if2.aluin1) >>> if2.operation };
        default       : shift_aluout = shift_aluout ;
        endcase
    end
    else
    begin
        shift_aluout = shift_aluout;
    end
    
    //arith ALU
    if(if2.enable_arith)
    begin
        case({if2.opselect,if2.operation})
        {if2.ARITH_LOGIC , if2.ADD}  :  arith_aluout =  $signed(if2.aluin1) + $signed(if2.aluin2) ; 
        {if2.ARITH_LOGIC , if2.HADD} : begin 
                                                {h_carry,h_add}   = if2.aluin1[if2.IMMEDIATE_WIDTH-1:0] + if2.aluin2[if2.IMMEDIATE_WIDTH-1:0];
                                                arith_aluout = {h_carry, $signed(h_add)};
                                           end
        {if2.ARITH_LOGIC , if2.SUB}  : arith_aluout =  $signed(if2.aluin1) - $signed(if2.aluin2);
        {if2.ARITH_LOGIC , if2.NOT}  : arith_aluout = {1'b0 ,~if2.aluin2};
        {if2.ARITH_LOGIC , if2.AND}  : arith_aluout = {1'b0 ,if2.aluin1 & if2.aluin2};
        {if2.ARITH_LOGIC , if2.OR}   : arith_aluout = {1'b0 ,if2.aluin1 | if2.aluin2};
        {if2.ARITH_LOGIC , if2.XOR}  : arith_aluout = {1'b0 ,if2.aluin1 ^ if2.aluin2};
        {if2.ARITH_LOGIC , if2.LHG}  : arith_aluout = {1'b0,if2.aluin2<<if2.IMMEDIATE_WIDTH}; 
        {if2.MEM_READ , if2.LOADBYTE}: arith_aluout = {1'b0,$signed(if2.aluin2[7:0])};
        {if2.MEM_READ , if2.LOADBYTEU}:arith_aluout = {1'b0,{(if2.REGISTER_WIDTH-8){1'b0}},  if2.aluin2[7:0]};
        {if2.MEM_READ , if2.LOADHALF}:arith_aluout = {1'b0,$signed(if2.aluin2[15:0])};
        {if2.MEM_READ , if2.LOADHALFU}:arith_aluout = {1'b0,{(if2.IMMEDIATE_WIDTH){1'b0}},  if2.aluin2[15:0]};
        {if2.MEM_READ , if2.LOADWORD}:arith_aluout = {1'b0,if2.aluin2};
        default                       :arith_aluout = (if2.opselect == if2.MEM_READ) ? {1'b0, if2.aluin2} : arith_aluout;                                               
                                                       
        endcase
    end
    else
    begin
        arith_aluout = arith_aluout;
        if2.carry = if2.carry;
    end
    
    //final MUX
    {if2.carry, if2.aluout} = (if2.enable_arith)? arith_aluout : shift_aluout;
end
endmodule
