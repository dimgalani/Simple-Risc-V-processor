//`include "regfile.v"
//`include "alu.v"
`include "datapath.v"
`include "parameters.v"
module multicycle #(parameter [31:0] INITIAL_PC = 32'h00400000) (
                  output wire [31:0] PC,
                  output wire [31:0] dAddress,
                  output wire [31:0] dWriteData,
                  output reg MemRead,
                  output reg MemWrite,
                  output wire [31:0] WriteBackData,
                  input clk,
                  input rst,
                  input wire [31:0] instr,
                  input wire [31:0] dReadData);

    wire PCSrc, ALUSrc,  MemToReg; 
    wire [3:0] ALUCtrl;
    wire Zero; 
    reg RegWrite, loadPC;

    //Instance the datapath
    datapath #(.INITIAL_PC(INITIAL_PC))my_datapath (  
                            .PC(PC), 
                            .Zero(Zero), 
                            .dAddress(dAddress), 
                            .dWriteData(dWriteData), 
                            .WriteBackData(WriteBackData), 
                            .clk(clk), 
                            .rst(rst), 
                            .instr(instr), 
                            .PCSrc(PCSrc), 
                            .ALUSrc(ALUSrc), 
                            .RegWrite(RegWrite), 
                            .MemToReg(MemToReg), 
                            .ALUCtrl(ALUCtrl), 
                            .loadPC(loadPC),
                            .dReadData(dReadData) );   


   //ALU CONTROL UNIT
    wire [2:0] funct3; 
    wire [6:0] funct7;
    wire [6:0] opcode;
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    
    
                     // funct7       rs2    rs1   funct3  rd            opcode
                     // imm[11:0]           rs1   010     rd            0000011 LW  
                     // imm[11:5]    rs2    rs1   010     imm[4:0]      0100011 SW
                     // imm[12|10:5] rs2    rs1   000     imm[4:1|11]   1100011 BEQ
    assign ALUCtrl = (opcode == `B_TYPE) ? `ALUOP_SUB : //BEQ command BEC has unique opcode
                     (opcode == `LW)     ? `ALUOP_ADD : //LW command has unique opcode and should be above SLT because they have the same funct3
                     (opcode == `SW)     ? `ALUOP_ADD : //SW command has unique opcode and should be above SLT because they have the same funct3
                     (funct3 == `FUNCT3_AND) ? `ALUOP_AND :
                     (funct3 == `FUNCT3_OR)  ? `ALUOP_OR  :
                     (funct3 == `FUNCT3_ADD) && (funct7 == `FUNCT7_ADD) /*&& (opcode == 7'b0110011 )*/? `ALUOP_ADD : //ADD command
                     // the check for the funct7 is necessary to recognize the ADD command from the SUB command
                     // the check for the opcode is necessary to recognize the ADDI command from the SUB command because ADDI doesnt have funct7 -> I-type from B-type
                     (funct3 == `FUNCT3_ADD) && (opcode == `I_TYPE)          ? `ALUOP_ADD : //ADDI command
                     (funct3 == `FUNCT3_SUB) && (funct7 == `FUNCT7_SUB)      ? `ALUOP_SUB :
                     (funct3 == `FUNCT3_SLT)                                 ? `ALUOP_SLT :
                     (funct3 == `FUNCT3_SLL)                                 ? `ALUOP_SLL :
                     (funct3 == `FUNCT3_SRL_SRA) && (funct7 == `FUNCT7_SRL)  ? `ALUOP_SRL :
                     (funct3 == `FUNCT3_SRL_SRA) && (funct7 == `FUNCT7_SRA)  ? `ALUOP_SRA :
                     (funct3 == `FUNCT3_XOR)                                 ? `ALUOP_XOR :
                     0; 


    //ALUSrc - independent from the FSM cycle
    assign ALUSrc = (opcode == `I_TYPE) || (opcode == `LW) || (opcode == `SW) ? 1 : 0; // if i have I-type or LW or SW then 1 else 0
    // I-type instructions are: ADDI, SLTI, XORI, ORI, ANDI, SLLI, SRLI, SRAI
   
               
    //MemToReg - doesnt care for the rest of the stages only relevant for the WB stage
    assign MemToReg = (opcode == `LW) ? 1 : 0; //if LW then MemToReg is 1

    //PCSrc
    assign PCSrc = (opcode == `B_TYPE) && (Zero) ? 1 : 0;

    //FSM
    reg [2:0] current_state, next_state; //because i have 5 states
    parameter reg [2:0] IF  = 3'b000,   //IF  = Instruction Fetch
                        ID  = 3'b001,   //ID  = Instruction Decode
                        EX  = 3'b010,   //EX  = Execute
                        MEM = 3'b011,   //MEM = Memory Access
                        WB  = 3'b100;   //WB  = Write Back

    //STATE MEMORY
    always @(posedge clk) begin
        if (rst) begin
            current_state <= IF;
        end else begin
            current_state <= next_state;
        end
    end

    //NEXT STATE LOGIC
    always @(current_state) begin
        case (current_state)
            IF: begin
                next_state = ID;
            end
            ID: begin

                next_state = EX;
            end
            EX: begin
                next_state = MEM;
            end
            MEM: begin
                next_state = WB;
            end
            WB: begin
                next_state = IF;
            end
            default: begin
                next_state = IF;
            end
        endcase
    end

    //OUTPUT LOGIC
    always @(current_state) begin 
        case (current_state)
            IF: begin
                MemRead = 0;
                MemWrite = 0;
                RegWrite = 0;
                loadPC = 0;

            end
            ID: begin
                MemRead = 0;
                MemWrite = 0;
                RegWrite = 0;
                loadPC = 0;
            end
            EX: begin
                MemRead = 0;
                MemWrite = 0;
                RegWrite = 0;
                loadPC = 0;
            end
            MEM: begin
                MemRead =  (opcode == `LW) ? 1 : 0;
                MemWrite = (opcode == `SW) ? 1 : 0;
                RegWrite = 0;
                loadPC = 0;
            end
            WB: begin
                MemRead = 0;
                MemWrite = 0;
                RegWrite = (opcode == `SW) || (opcode == `B_TYPE) ? 0 : 1; //if SW or LW then RegWrite is 0 else 1
                loadPC = 1;
            end
        endcase
    end 


endmodule