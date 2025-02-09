module decoder (output wire[3:0] alu_op,
                input wire btnr, input wire btnl, input wire btnc);

not U1 (nbtnr, btnr);
not U2 (nbtnl, btnl);
not U3 (nbtnc, btnc);

//alu_op[0] = (~btnr & btnl) | (btnr & (btnl ^X btnc));
and U4 (a1, nbtnr, btnl);
xor U5 (a2, btnc, btnl);
and U6 (a3, a2, btnr);
or U7 (alu_op[0], a1, a3);

//alu_op[1] = (btnr & btnl) | (~btnl & (~btnc));
and U8 (b1, btnr, btnl);
and U9 (b2, nbtnl, nbtnc);
or U10 (alu_op[1], b1, b2);

//alu_op[2] = ((btnr & btnl) | (btnr ^X btnl)) & ~btnc;
and U11 (c1, btnr, btnl);
xor U12 (c2, btnr, btnl);
or U13 (c3, c1, c2);
and U14 (alu_op[2], c3, nbtnc);

//alu_op[3] = ((~btnr & btnc) | (btnr & btnc)) & btnl;
and U15 (d1, nbtnr, btnc);
xnor U16 (d2, btnr, btnc);
or U17 (d3, d1, d2);
and U18 (alu_op[3], d3, btnl);
endmodule