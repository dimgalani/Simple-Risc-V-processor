module regfile(output reg [31:0] readData1, output reg [31:0] readData2, 
               input wire [4:0] readReg1, input wire [4:0] readReg2, input wire [4:0] writeReg, input wire [31:0] writeData, input wire clk, input wire write);
    reg [31:0] registers [0:31];
    
    initial begin
        for(integer i=0; i<32; i=i+1) begin
            registers[i] = 32'h00000000;
          end
    end
    
    
    always @(posedge clk) begin
            readData1 = registers[readReg1];
            readData2 = registers[readReg2];
        if (write) begin
            registers[writeReg] = writeData;
        end
    end
endmodule