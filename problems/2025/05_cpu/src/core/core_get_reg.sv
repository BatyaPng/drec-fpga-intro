module core_get_reg
    import core_pkg::*;
(
    input  instruction_t i_instr,

    output logic [4:0] o_rs1,
    output logic [4:0] o_rs2,
    output logic [4:0] o_rd
);

assign o_rs1 = i_instr[19:15];
assign o_rs2 = i_instr[24:20];
assign o_rd  = (i_instr.opcode != STORE & i_instr.opcode != BRANCH) ? i_instr[11:7] : '0;

endmodule
