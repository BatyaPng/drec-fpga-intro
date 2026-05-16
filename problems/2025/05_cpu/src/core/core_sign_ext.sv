module core_sign_ext
    import core_pkg::*;
(
    input  instruction_t i_instr,

    output logic [31:0] o_i_imm,
    output logic [31:0] o_s_imm,
    output logic [31:0] o_b_imm,
    output logic [31:0] o_u_imm,
    output logic [31:0] o_j_imm
);

`ifdef FPGA

payload_i_t p_i;
payload_s_t p_s;
payload_b_t p_b;
payload_u_t p_u;
payload_j_t p_j;

assign p_i = i_instr.payload;
assign p_s = i_instr.payload;
assign p_b = i_instr.payload;
assign p_u = i_instr.payload;
assign p_j = i_instr.payload;

assign o_i_imm = {{20{p_i.imm_11_0[11]}}, p_i.imm_11_0};
assign o_s_imm = {{20{p_s.imm_11_5[6]}}, p_s.imm_11_5, p_s.imm_4_0};
assign o_b_imm = {{20{p_b.imm_12}}, p_b.imm_11, p_b.imm_10_5, p_b.imm_4_1, 1'b0};
assign o_u_imm = {p_u.imm_31_12, 12'b0};
assign o_j_imm = {{12{p_j.imm_20}}, p_j.imm_19_12, p_j.imm_11, p_j.imm_10_1, 1'b0};

`else

assign o_i_imm = {{20{i_instr.payload.i.imm_u.imm_11_0[11]}}, i_instr.payload.i.imm_u.imm_11_0};
assign o_s_imm = {{20{i_instr.payload.s.imm_11_5[6]}}, i_instr.payload.s.imm_11_5, i_instr.payload.s.imm_4_0};
assign o_b_imm = {{20{i_instr.payload.b.imm_12}}, i_instr.payload.b.imm_11, i_instr.payload.b.imm_10_5, i_instr.payload.b.imm_4_1, 1'b0};
assign o_u_imm = {i_instr.payload.u.imm_31_12, 12'b0};
assign o_j_imm = {{12{i_instr.payload.j.imm_20}}, i_instr.payload.j.imm_19_12, i_instr.payload.j.imm_11, i_instr.payload.j.imm_10_1, 1'b0};

`endif

endmodule
