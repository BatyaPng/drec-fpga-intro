`timescale 1ps/1ps

`include "cmp_inc.vh"

module cmp_tb;

reg [31:0] i_a;
reg [31:0] i_b;
br_op_t i_op;

wire o_taken;

cmp dut (
    .i_a    (i_a),
    .i_b    (i_b),
    .i_op   (i_op),
    .o_taken(o_taken)
);

task test_op;
    input br_op_t op;
    input [31:0] a;
    input [31:0] b;
    input expected;
    reg eq;
    begin
        i_op = op;
        i_a  = a;
        i_b  = b;
        #10;

        eq = (o_taken === expected);
        $display("OP: %0d | A: %h | B: %h | TAKEN: %b | EXP: %b | EQ: %b", op, a, b, o_taken, expected, eq);

        if (!eq) begin
            $display("ERROR: Mismatch on OP %0d!", op);
        end
    end
endtask

initial begin
    test_op(BEQ,  32'd10,  32'd10,  1'b1);
    test_op(BEQ,  32'd10,  32'd20,  1'b0);

    test_op(BNE,  32'd10,  32'd20,  1'b1);
    test_op(BNE,  32'd10,  32'd10,  1'b0);

    test_op(BLT, -32'd5,   32'd5,   1'b1);
    test_op(BLT,  32'd5,  -32'd5,   1'b0);

    test_op(BGE,  32'd5,  -32'd5,   1'b1);
    test_op(BGE, -32'd5,   32'd5,   1'b0);

    test_op(BLTU, 32'd5,  -32'd5,   1'b1);
    test_op(BLTU,-32'd5,   32'd5,   1'b0);

    test_op(BGEU,-32'd5,   32'd5,   1'b1);
    test_op(BGEU, 32'd5,  -32'd5,   1'b0);

    $finish;
end

endmodule
