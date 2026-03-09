`timescale 1ns / 1ps

module alu_tb;

typedef enum reg [3:0] {
    ADD,
    SUB,
    SLL,
    SLT,
    SLTU,
    XOR,
    SRL,
    SRA,
    OR,
    AND
} op_t;

reg [31:0] i_a;
reg [31:0] i_b;
op_t i_op;

wire [31:0] o_res;

alu alu (
    .i_a  (i_a),
    .i_b  (i_b),
    .i_op (i_op),
    .o_res(o_res)
);

task test_op;
    input op_t   op;
    input [31:0] a;
    input [31:0] b;
    input [31:0] expected;
    reg eq;
    begin
        i_op = op;
        i_a  = a;
        i_b  = b;
        #10;

        eq = (o_res === expected);
        $display("OP: %0d | A: %h | B: %h | RES: %h | EXP: %h | EQ: %b", op, a, b, o_res, expected, eq);

        if (!eq) begin
            $display("ERROR: Mismatch on OP %0d!", op);
        end
    end
endtask

initial begin
    $dumpvars;

    test_op(ADD,  32'd10,         32'd20,         32'd30);
    test_op(SUB,  32'd50,         32'd20,         32'd30);
    test_op(SLL,  32'd1,          32'd4,          32'd16);
    test_op(SLT,  -32'd10,        32'd5,          32'd1);
    test_op(SLTU, -32'd10,        32'd5,          32'd0);
    test_op(XOR,  32'hAAAA_AAAA,  32'h5555_5555,  32'hFFFF_FFFF);
    test_op(SRL,  32'hF000_0000,  32'd4,          32'h0F00_0000);
    test_op(SRA,  32'hF000_0000,  32'd4,          32'hFF00_0000);
    test_op(OR,   32'hF0F0_F0F0,  32'h0F0F_0F0F,  32'hFFFF_FFFF);
    test_op(AND,  32'hF0F0_F0F0,  32'h00FF_00FF,  32'h00F0_00F0);

    $finish;
end

endmodule
