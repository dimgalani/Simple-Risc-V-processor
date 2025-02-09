`include "parameters.v"
module alu (    output wire zero,
                output wire [31:0] result,
                input wire [31:0] op1,
                input wire [31:0] op2,
                input wire [3:0] alu_op);
  
  wire signed [31:0] op1_signed, op2_signed;
  assign op1_signed = op1;
  assign op2_signed = op2;

  //ALU MULTIPLEXER
  assign result = (alu_op == `ALUOP_AND)   ? op1 & op2  :
                  (alu_op == `ALUOP_OR)    ? op1 | op2  :
                  (alu_op == `ALUOP_ADD)   ? op1 + op2   :
                  (alu_op == `ALUOP_SUB)   ? op1 - op2   :
                  (alu_op == `ALUOP_SLT)   ? op1_signed < op2_signed   :
                  (alu_op == `ALUOP_SRL)   ? op1 >> op2[4:0]  :
                  (alu_op == `ALUOP_SLL)   ? op1 << op2[4:0]  :
                  (alu_op == `ALUOP_SRA)   ? op1_signed >>> op2[4:0] :
                  (alu_op == `ALUOP_XOR)   ? op1 ^ op2   : 0;

    assign zero = (result == 0) ? 1 : 0;
    
endmodule