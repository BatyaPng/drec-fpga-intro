module core_control
    import core_pkg::*;
(
    input  instruction_t i_isntr,

    output alu_op_t o_alu_op
);

always_comb begin
    case (i_isntr.opcode)
        OP_IMM: begin
            case (i_isntr.payload.i.funct3)
                3'b000:  o_alu_op = ADD;     // ADDI
                3'b010:  o_alu_op = SLT;     // SLTI
                3'b011:  o_alu_op = SLTU;    // SLTIU
                3'b100:  o_alu_op = XOR;     // XORI
                3'b110:  o_alu_op = OR;      // ORI
                3'b111:  o_alu_op = AND;     // ANDI
            endcase
        end
    endcase
end

endmodule
