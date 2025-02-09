// parameters.v
`ifndef PARAMETERS_V
`define PARAMETERS_V

`define ALUOP_AND 4'b0000 //AND = Bitwise AND
`define ALUOP_OR  4'b0001 //OR  = Bitwise OR
`define ALUOP_ADD 4'b0010 //ADD = addition
`define ALUOP_SUB 4'b0110 //SUB = subtraction
`define ALUOP_SLT 4'b0111 //SLT = Set Less Than
`define ALUOP_SRL 4'b1000 //SRL = Shift Right Logical OP2BITS
`define ALUOP_SLL 4'b1001 //SLL = Shift Left Logical OP2BITS
`define ALUOP_SRA 4'b1010 //SRA = Shift Right Arithmetic OP2BITS
`define ALUOP_XOR 4'b1101 //XOR = Exclusive OR

`define FUNCT3_ADD      3'b000
`define FUNCT3_SUB      3'b000 //sub i doesnt exists
`define FUNCT3_SLL      3'b001
`define FUNCT3_SLT      3'b010
`define FUNCT3_XOR      3'b100
`define FUNCT3_SRL_SRA  3'b101
`define FUNCT3_OR       3'b110
`define FUNCT3_AND      3'b111

`define R_TYPE 7'b0110011
`define I_TYPE 7'b0010011
`define B_TYPE 7'b1100011
`define SW     7'b0100011
`define LW     7'b0000011

`define FUNCT7_ADD 7'b0000000
`define FUNCT7_SUB 7'b0100000
`define FUNCT7_SRL 7'b0000000
`define FUNCT7_SRA 7'b0100000


`endif