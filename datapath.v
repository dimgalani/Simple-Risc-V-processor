//`include "datapath_encoder.v"
`include "regfile.v"
`include "alu.v"
`include "parameters.v"

module datapath #(parameter [31:0] INITIAL_PC = 32'h00400000)                                                                                           
                 (output reg [31:0] PC, output wire Zero, output wire [31:0] dAddress /*memory address to write to (SW)*/, output wire [31:0] dWriteData, output wire [31:0] WriteBackData,
                 input wire clk, input wire rst, input wire [31:0] instr, input wire PCSrc, input wire ALUSrc, input wire RegWrite, input wire MemToReg, input wire [3:0] ALUCtrl, 
                 input wire loadPC, input wire [31:0] dReadData);

    //the output of the alu
    wire [31:0] writeData;            //the input of the regfile
    wire [31:0] readData1, readData2; //the output of the regfile
    
    //REGFILE
    //Registers values for the regfile - i assign all the registers although in same cases i dont use them all 
    wire [4:0] readReg1, readReg2, writeReg; //the inputs of the regfile rs1, rs2, rd
    assign readReg1 = instr[19:15];          //i define that but in the case of the LW command i dont use it
    assign readReg2 = instr[24:20];          //i define that but in the case of the I-type and the LW command i dont use it
    assign writeReg = instr[11:7];           //i define that but in the case of the B-type and SW command i dont use it
    
    //Instance of the regfile
    regfile my_regfile ( .readData1(readData1), .readData2(readData2), .readReg1(readReg1), .readReg2(readReg2), .writeReg(writeReg), .writeData(writeData), .clk(clk), .write(RegWrite) );
    //                                                                                                                                                          the RegWrite is the write enable             
    

    //IMMEDIATE GENERATOR
    wire [2:0] funct3;
    wire [6:0] opcode;
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    wire [31:0] branch_offset;
    wire [31:0] IG_data; //the output of the immediate generator

    assign IG_data = (opcode == `I_TYPE) && (funct3 == `FUNCT3_SRL_SRA || funct3 == `FUNCT3_SLL ) ? {{27{instr[24]}}, instr[24:20]} : //for the commands SRLI or SLLI or SRAI the immediate is the shamt=shift amount
                     (opcode == `I_TYPE) ? {{20{instr[31]}}, instr[31:20]} :                                    //for the rest I-type commands
                     (opcode == `B_TYPE) ? {{20{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8]} :  //for the BEQ command
                     (opcode == `SW) ? {{20{instr[31]}},instr[31:25], instr[11:7]} :                            //SW
                     (opcode == `LW) ? {{20{instr[31]}},instr[31:20]} : 0;                                      //LW

    assign branch_offset = IG_data << 1; //the branch offset is the immediate value shifted left by 1 bit

    //ALU CONTROL UNIT
    wire [31:0] alu_op1, alu_op2;//the inputs of the alu
    
    assign alu_op1 = readData1; //the first operand of the alu is the readData1
    
    //ALUSrc - MUX for the second operand of the alu
    assign alu_op2 = (ALUSrc) ? IG_data : readData2; //if ALUSrc is 0 then the second input of the alu is the readData2 else it is the immediate value from the instruction
    
    //instance of the alu
    alu my_alu ( .zero(Zero), .result(dAddress), .op1(alu_op1), .op2(alu_op2), .alu_op(ALUCtrl) );

 
    //WRITE BACK
    assign dWriteData = readData2;
    assign WriteBackData = (MemToReg) ? dReadData : dAddress;
    assign writeData = WriteBackData;

    //PC synchronous update
    always @(posedge clk) begin
        if (rst) begin
            PC <= INITIAL_PC;
        end else if (loadPC) begin
            if (PCSrc) begin //the Zero is already checked 
                PC <= PC + branch_offset;
            end else begin
                PC <= PC + 4;
            end
        end
    end
    //end of PC 


endmodule