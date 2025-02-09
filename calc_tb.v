`timescale 1ps/1ps // 1ns time_unit, 1ps resolution/precision
//So, in the simulation, time will progress in increments of 1 nanosecond, 
//and the simulation will be able to represent time with a precision of 1 picosecond.
`include "calc.v"

module calc_tb();
    reg [15:0] sw;
    reg clk, btnc, btnl, btnu, btnr, btnd;
    wire [15:0] led;
    
    calc DUT ( .led(led), .sw(sw), .clk(clk), .btnc(btnc), .btnl(btnl), .btnu(btnu), .btnr(btnr), .btnd(btnd) );
    
    initial begin
        clk = 1;
    end

    always begin
        #10 clk = ~clk;
    end

    always  begin
        #20 btnd = ~btnd;
        #1 btnd = ~btnd;
    end
    

    reg[15:0] expected_result;
    reg[15:0] previous_value;

    initial begin
        $dumpfile("calc_tb.vcd");
        $dumpvars(0, calc_tb);
        btnu = 0;
        btnd = 0;

        #15 btnu = 1;//reset 
        #15 btnu = 0; //release reset


        #10 btnl = 0; btnc = 1; btnr = 1; sw = 16'h1234 ;
        #20 btnl = 0; btnc = 1; btnr = 0; sw = 16'h0ff0 ;
        #20 btnl = 0; btnc = 0; btnr = 0; sw = 16'h324f ;
        #20 btnl = 0; btnc = 0; btnr = 1; sw = 16'h2d31 ;
        #20 btnl = 1; btnc = 0; btnr = 0; sw = 16'hffff ;
        #20 btnl = 1; btnc = 0; btnr = 1; sw = 16'h7346 ;
        #20 btnl = 1; btnc = 1; btnr = 0; sw = 16'h0004 ;
        #20 btnl = 1; btnc = 1; btnr = 1; sw = 16'h0004 ;
        #20 btnl = 1; btnc = 0; btnr = 1; sw = 16'hffff ;
        #60
        $finish;
    end
endmodule