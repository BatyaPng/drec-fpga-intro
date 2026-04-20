module core_control
    import core_pkg::*;
(
    instruction_t i_isntr
);

always_comb begin
    case (i_isntr.opcode)
        case (i_isntr.payload_t.payload_r_t.funct3)
            : 
            default: 
        endcase
    endcase
end

endmodule
