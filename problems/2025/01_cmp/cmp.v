`include "cmp_inc.vh"

module cmp (
    input  wire [31:0] i_a,
    input  wire [31:0] i_b,

    input  br_op_t i_op,

    output reg o_taken
);

always @(*) begin
    case (i_op)
        BEQ:     o_taken = i_a == i_b;
        BNE:     o_taken = i_a != i_b;
        BLT:     o_taken = $signed(i_a) < $signed(i_b);
        BGE:     o_taken = $signed(i_a) >= $signed(i_b);
        BLTU:    o_taken = i_a < i_b;
        BGEU:    o_taken = i_a >= i_b;
        default: o_taken = 'X;
    endcase
end

endmodule
