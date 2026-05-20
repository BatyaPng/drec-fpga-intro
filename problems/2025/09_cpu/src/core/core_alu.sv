module core_alu
    import core_pkg::*;
(
    input  wire [31:0] i_a,
    input  wire [31:0] i_b,

    input  alu_op_t i_op,

    output reg [31:0] o_res
);

always @(*) begin
    case (i_op)
        ADD:     o_res = i_a + i_b;
        SUB:     o_res = i_a - i_b;
        SLL:     o_res = i_a << i_b[4:0];
        SLT:     o_res = $signed(i_a) < $signed(i_b);
        SLTU:    o_res = i_a < i_b;
        XOR:     o_res = i_a ^ i_b;
        SRL:     o_res = i_a >> i_b[4:0];
        SRA:     o_res = $signed(i_a) >>> i_b[4:0];
        OR:      o_res = i_a | i_b;
        AND:     o_res = i_a & i_b;
        NOP:     o_res = 0;
        default: o_res = 'X;
    endcase
end

endmodule

