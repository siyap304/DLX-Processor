`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2025 13:56:19
// Design Name: 
// Module Name: Ex_Processor
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


module Ex_Processor(dlx_processor if1);

always_ff@(posedge if1.clk or negedge if1.rst)
begin
    //reset
    if(!if1.rst)
    begin
        if1.aluin1 = 0; if1.aluin2 = 0; if1.operation = 0; if1.opselect = 0; if1.shift_number = 0; 
        if1.enable_arith = 0; if1.enable_shift = 0;
    end 
    
    if(if1.enable_ex)
    begin
    
    //operation and opselect
    if1.operation = if1.control_in[6:4];
    if1.opselect = if1.control_in[2:0];
    
    //aluin1
    if1.aluin1 = if1.src1;
    
    //aluin2
    case(if1.opselect)
    if1.ARITH_LOGIC: if (if1.control_in[3]) if1.aluin2 = if1.imm;
                     else if1.aluin2 = if1.src2;
    if1.MEM_READ: if (if1.control_in[3]) if1.aluin2 = if1.mem_data_read_in;
                  else if1.aluin2 = if1.aluin2;
    default: if1.aluin2 = 0;
    endcase
    
    //shift_number
    if(if1.opselect == if1.SHIFT_REG)
    begin
        if(if1.imm[2]) if1.shift_number = if1.src2[4:0];
        else if1.shift_number = if1.imm[10:6];
    end 
    else if1.shift_number = if1.shift_number; 
    
    //enable_arith
    case(if1.opselect)
    if1.ARITH_LOGIC: if1.enable_arith = 1;
    if1.MEM_READ: if(if1.control_in[3]) if1.enable_arith = 1;
                  else if1.enable_arith = 0;
    default: if1.enable_arith = 0;
    endcase
    
    //enable_shift
    if(if1.opselect == if1.SHIFT_REG) if1.enable_shift = 1;
    else if1.enable_shift = 0;
    
    end
    
    else
    begin
        if1.aluin1 = if1.aluin1; 
        if1.aluin2 = if1.aluin2; 
        if1.operation = if1.operation; 
        if1.opselect = if1.opselect; 
        if1.shift_number = if1.shift_number; 
        if1.enable_arith = if1.enable_arith;
        if1.enable_shift = if1.enable_shift;
    end
end

always_comb
begin
    if1.mem_data_write_out = if1.src2;
    if1.mem_data_wr_en = (if1.opselect == if1.MEM_WRITE) && (if1.control_in[3] == 1);
end
endmodule
