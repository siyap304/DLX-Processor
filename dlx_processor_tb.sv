//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 31.03.2025 17:11:04
//// Design Name: 
//// Module Name: dlx_processor_tb
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module dlx_processor_tb();

//    // Instantiate the interface
//    dlx_processor if_inst();

//    // Instantiate the Execute Preprocessor and ALU modules.
//    Ex_Processor uut1 (.if1(if_inst));
//    ALU_Unit     uut2 (.if2(if_inst));
    
//    // Generate a clock with period = 10 ns.
//    initial begin
//        if_inst.clk = 0;
//        forever #5 if_inst.clk = ~if_inst.clk;
//    end
    
//    // Stimulus generation
//    initial begin
//        // Initialize reset and all signals
//        if_inst.rst = 0;
//        if_inst.enable_ex = 0;
//        if_inst.src1 = 32'd0;
//        if_inst.src2 = 32'd0;
//        if_inst.imm  = 32'd0;
//        if_inst.control_in = 7'd0;
//        if_inst.mem_data_read_in = 32'd0;
        
//        // Hold reset for a few clock cycles
//        #15;
//        if_inst.rst = 1;
//        #10;
        
//        // ----- Test Case 1: Arithmetic Addition -----
//        // Using ARITH_LOGIC operation with ADD.
//        // Definitions from the appendix: 
//        //   ARITH_LOGIC = 3'b001, ADD = 3'b000.
//        // control_in = {operation, immediate flag, opselect} 
//        // For addition with src2 (immediate flag = 0):
//        //   control_in = {3'b001, 1'b0, 3'b000} = 7'b0010_000.
//        if_inst.enable_ex = 1;
//        if_inst.src1 = 32'd10;
//        if_inst.src2 = 32'd20;
//        if_inst.imm  = 32'd100; // Not used when immediate flag is 0.
//        if_inst.control_in = 7'b0010000;
//        #10;
        
//        // ----- Test Case 2: Arithmetic Subtraction -----
//        // For subtraction, set opselect = 3'b010 (SUB) while keeping ARITH_LOGIC.
//        if_inst.src1 = 32'd50;
//        if_inst.src2 = 32'd15;
//        // control_in = {3'b001, 1'b0, 3'b010} = 7'b0010010.
//        if_inst.control_in = 7'b0010010;
//        #10;
        
//        // ----- Test Case 3: Shift Operation -----
//        // For shifting, opselect should be SHIFT_REG (3'b000).
//        // The testbench demonstrates selection of the shift amount via imm[10:6] when imm[2] is 0.
//        if_inst.src1 = 32'h0000000F;   // Data to shift.
//        if_inst.src2 = 32'h00000002;   // Alternative source for shift amount if imm[2]==1.
//        // Set imm such that bit2==0 and imm[10:6] = shift amount (e.g., shift by 2)
//        if_inst.imm = 32'b0;
//        if_inst.imm[10:6] = 5'b00010;
//        // control_in = {operation, immediate flag, opselect} where opselect is SHIFT_REG.
//        // Here, we use operation = 3'b001 (arbitrarily chosen) and immediate flag = 0.
//        if_inst.control_in = {3'b001, 1'b0, 3'b000};
//        #10;
        
//        // ----- Test Case 4: Memory Read (Load Byte) -----
//        // For a memory read operation, opselect should be MEM_READ (3'b101) with immediate flag = 1.
//        // The specification indicates that when control_in[3]==1, aluin2 is taken from mem_data_read_in.
//        if_inst.src2 = 32'd0;  // Not used here.
//        if_inst.mem_data_read_in = 32'h000000FF;  // Simulate reading 0xFF from memory.
//        // control_in = {operation, immediate flag, opselect} = {3'b101, 1'b1, 3'b101} = 7'b1011101.
//        if_inst.control_in = 7'b1011101;
//        #10;
        
//        // End simulation after a few more cycles.
////        #200;
//        $finish;
//    end

//endmodule


`timescale 1ns/1ps

module tb_dlx;
  // Instantiate the shared interface
  dlx_processor dut_if();

  // Instantiate DUT modules
  Ex_Processor ex_proc (dut_if);
  ALU_Unit      alu_unit (dut_if);

  // Clock Generation: 10 ns period (5 ns high, 5 ns low)
  initial begin
    dut_if.clk = 0;
    forever #5 dut_if.clk = ~dut_if.clk;
  end

  // Define arrays for opselect and operation values (0 to 7)
  int unsigned opselect_vals[8] = '{0,1,2,3,4,5,6,7};
  int unsigned operation_vals[8]  = '{0,1,2,3,4,5,6,7};
  bit control_bit[2] = '{0,1}; // Represents control_in[3]

  // Task: Loop first over opselect values, then for every opselect, sweep all operation values
  task run_by_opselect();
    int unsigned op_sel;
    int unsigned oper;
    bit ctrl_bit;
    foreach (opselect_vals[i]) begin
      op_sel = opselect_vals[i];
      foreach (control_bit[j]) begin
        ctrl_bit = control_bit[j];
        foreach (operation_vals[k]) begin
          oper = operation_vals[k];
          // Form the 7-bit control signal:
          // [6:4] = operation, [3] = ctrl_bit, [2:0] = op_sel
          dut_if.control_in = {oper[2:0], ctrl_bit, op_sel[2:0]};
          $display("Time=%0t | (ByOpSelect) opselect=%b, control_bit=%b, operation=%b => control_in=%b", 
                    $time, op_sel[2:0], ctrl_bit, oper[2:0], dut_if.control_in);
          #10; // Wait one clock cycle for evaluation
        end
      end
    end
  endtask

  // Task: Loop first over operation values, then for every operation, sweep all opselect values
  task run_by_operation();
    int unsigned op_sel;
    int unsigned oper;
    bit ctrl_bit;
    foreach (operation_vals[i]) begin
      oper = operation_vals[i];
      foreach (control_bit[j]) begin
        ctrl_bit = control_bit[j];
        foreach (opselect_vals[k]) begin
          op_sel = opselect_vals[k];
          // Form the 7-bit control signal:
          // [6:4] = operation, [3] = ctrl_bit, [2:0] = op_sel
          dut_if.control_in = {oper[2:0], ctrl_bit, op_sel[2:0]};
          $display("Time=%0t | (ByOperation) operation=%b, control_bit=%b, opselect=%b => control_in=%b", 
                    $time, oper[2:0], ctrl_bit, op_sel[2:0], dut_if.control_in);
          #10; // Wait one clock cycle for evaluation
        end
      end
    end
  endtask

  // Main test stimulus
  initial begin
    // Initialize/reset signals and drive large test values
    dut_if.rst = 0;
    dut_if.enable_ex = 0;
    dut_if.src1 = 32'hA5A5_A5A5;           // Large value for aluin1
    dut_if.src2 = 32'h5A5A_5A5A;           // Large value for aluin2
    dut_if.imm  = 32'hFFFF_0000;           // Large immediate value
    dut_if.mem_data_read_in = 32'h1234_5678; // Arbitrary test value

    // Apply reset for a few cycles
    #20;
    dut_if.rst = 1;
    #10;
    dut_if.enable_ex = 1;
    
    // Call tasks to exercise control_in
    $display("\nStarting test using opselect outer loop:");
    run_by_opselect();

    $display("\nStarting test using operation outer loop:");
    run_by_operation();

    $finish;
  end

endmodule
