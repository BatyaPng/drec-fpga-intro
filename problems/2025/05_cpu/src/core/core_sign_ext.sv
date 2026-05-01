module sign_extender
    import core_pkg::*;
(
    input  instruction_t i_instr,

    output logic [31:0] o_i_imm,
    output logic [31:0] o_s_imm,
    output logic [31:0] o_b_imm,
    output logic [31:0] o_u_imm,
    output logic [31:0] o_j_imm
);

    assign o_i_imm = {{20{i_instr.payload.i.imm[11]}}, i_instr.payload.i.imm};

    assign o_s_imm = {{20{i_instr.payload.s.imm_11_5[6]}}, i_instr.payload.s.imm_11_5, i_instr.payload.s.imm_4_0};

    assign o_b_imm = {{20{i_instr.payload.b.imm_12}}, i_instr.payload.b.imm_11, i_instr.payload.b.imm_10_5, i_instr.payload.b.imm_4_1, 1'b0};

    assign o_u_imm = {i_instr.payload.u.imm_31_12, 12'b0};

    assign o_j_imm = {{12{i_instr.payload.j.imm_20}}, i_instr.payload.j.imm_19_12, i_instr.payload.j.imm_11, i_instr.payload.j.imm_10_1, 1'b0};

endmodule
