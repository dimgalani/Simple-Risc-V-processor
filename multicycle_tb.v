`timescale 1ps/1ps
`include "multicycle.v"
`include "ram.v"
`include "rom.v"

module multicycle_tb();
    reg clk, rst;
    wire MemRead, MemWrite;
    wire [31:0] instr, dReadData;
    wire [31:0] PC, dAddress, dWriteData, WriteBackData;

    //loads the instruction based on the PC
    INSTRUCTION_MEMORY inst_mem (
        .clk(clk),
        .addr(PC[8:0]),
        .dout(instr) // Read instruction from instruction memory
    );

    DATA_MEMORY data_mem (
        .clk(clk),
        .we(MemWrite),
        .addr(dAddress[8:0]),
        .din(dWriteData),
        .dout(dReadData)
    );

    multicycle DUT ( 
        .PC(PC), 
        .dAddress(dAddress), 
        .dWriteData(dWriteData), 
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .WriteBackData(WriteBackData),
        .clk(clk), 
        .rst(rst), 
        .instr(instr), 
        .dReadData(dReadData));

    initial begin
        clk = 1;
        rst = 1;
    end

    always begin
        #10 clk = ~clk;
    end

    initial begin
        $dumpfile("multicycle_tb.vcd");
        $dumpvars(0, multicycle_tb);

        #20 rst = 0;

        #5000 $finish;

    end

endmodule