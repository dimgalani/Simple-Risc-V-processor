`include "alu.v"
`include "decoder.v"

module calc(output reg [15:0] led,
            input wire [15:0] sw, input wire clk, input wire btnc, input wire btnl, input wire btnu, input wire btnr, input wire btnd);

//sign extend sw
wire [31:0] sw_extended;
assign sw_extended = {{16{sw[15]}}, sw }; //sw_extended is 32 bits long, with the first 16 bits being the same as sw[15] aka the sign bit // concatenation operator, it would be useful to know the difference between this and the replication

reg [15:0] accumulator ;
//sign extend accumulator
wire [31:0] accumulator_extended; 
assign accumulator_extended = {{16{accumulator[15]}}, accumulator}; //accumulator_extended is 32 bits long, with the first 16 bits being the same as accumulator[15] aka the sign bit
wire [31:0] op1_alu;
assign op1_alu = accumulator_extended;

wire [31:0] op2_alu;
assign op2_alu = sw_extended;

//define alu_op
wire [3:0] alu_op;

//define alu_result
wire [31:0] alu_result;

//instantiating the decoder module
decoder my_decoder ( .alu_op(alu_op), .btnr(btnr), .btnl(btnl), .btnc(btnc) ); //.name_of_port_in_the_decoder_module(name_of_wire_in_this_module)
alu my_alu ( .zero(zero), .result(alu_result), .op1(op1_alu), .op2(op2_alu), .alu_op(alu_op) );

always @(posedge clk) begin
    if (btnu) begin
        accumulator <= 16'b0000000000000000;
    end
end

always @(posedge btnd) begin
    accumulator <= alu_result[15:0];
    led <= accumulator[15:0]; 
end

endmodule