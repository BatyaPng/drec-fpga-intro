module core_control
    import core_pkg::*;
(
    input  instruction_t i_isntr,

    output logic [1:0] o_alu_sel_b,
    output logic [1:0] o_alu_sel_a,
    output alu_op_t    o_alu_op,
    output mem_op_t    o_mem_op,
    output br_op_t     o_br_op,
    output logic       o_branch,
    output logic       o_jump,
    output logic [1:0] o_wb_sel
);

`ifdef FPGA

payload_i_t p_i;
payload_r_t p_r;
payload_s_t p_s;
payload_b_t p_b;

assign p_i = i_isntr.payload;
assign p_r = i_isntr.payload;
assign p_s = i_isntr.payload;
assign p_b = i_isntr.payload;

wire [2:0] f3_i   = p_i.funct3;
wire       f7_5_i = p_i.imm_11_0[10];
wire [2:0] f3_r   = p_r.funct3;
wire       f7_5_r = p_r.funct7[5];
wire [2:0] f3_s   = p_s.funct3;
wire [2:0] f3_b   = p_b.funct3;

`else

wire [2:0] f3_i   = i_isntr.payload.i.funct3;
wire       f7_5_i = i_isntr.payload.i.imm_u.shift_op.funct7[5];
wire [2:0] f3_r   = i_isntr.payload.r.funct3;
wire       f7_5_r = i_isntr.payload.r.funct7[5];
wire [2:0] f3_s   = i_isntr.payload.s.funct3;
wire [2:0] f3_b   = i_isntr.payload.b.funct3;

`endif

always_comb begin
    o_alu_sel_a = 2'hX;
    o_alu_sel_b = 2'hX;
    o_alu_op    = alu_op_t'('X);
    o_mem_op    = mem_op_t'('X);
    o_br_op     = br_op_t'('X);
    o_branch    = 1'b0;
    o_jump      = 1'b0;
    o_wb_sel    = 2'hX;

    case (i_isntr.opcode)
        OP_IMM: begin
            case (f3_i)
                3'b000:  o_alu_op = ADD;                                         // ADDI
                3'b010:  o_alu_op = SLT;                                         // SLTI
                3'b011:  o_alu_op = SLTU;                                        // SLTIU
                3'b100:  o_alu_op = XOR;                                         // XORI
                3'b110:  o_alu_op = OR;                                          // ORI
                3'b111:  o_alu_op = AND;                                         // ANDI
                3'b001:  o_alu_op = SLL;                                         // SLLI
                3'b101:  o_alu_op = !f7_5_i ? SRL                                // SRLI
                                            : SRA;                               // SRAI
                default: o_alu_op = alu_op_t'('X);
            endcase
            o_alu_sel_a = 2'h0;
            o_alu_sel_b = 2'h2;
            o_wb_sel    = 2'h2;
            o_branch    = 1'b0;
            o_jump      = 1'b0;
        end
        OP: begin
            case (f3_r)
                3'b000:  o_alu_op = !f7_5_r ? ADD                                // ADD
                                            : SUB;                               // SUB
                3'b001:  o_alu_op = SLL;                                         // SLL
                3'b010:  o_alu_op = SLT;                                         // SLT
                3'b011:  o_alu_op = SLTU;                                        // SLTU
                3'b100:  o_alu_op = XOR;                                         // XOR
                3'b101:  o_alu_op = !f7_5_r ? SRL                                // SRL
                                            : SRA;                               // SRA
                3'b110:  o_alu_op = OR;                                          // OR
                3'b111:  o_alu_op = AND;                                         // AND
                default: o_alu_op = alu_op_t'('X);
            endcase
            o_alu_sel_a = 2'h0;
            o_alu_sel_b = 2'h3;
            o_wb_sel    = 2'h2;
            o_branch    = 1'b0;
            o_jump      = 1'b0;
        end
        STORE: begin
            case (f3_s)
                3'b000:  o_mem_op = SB;                                          // SB
                3'b001:  o_mem_op = SH;                                          // SH
                3'b010:  o_mem_op = SW;                                          // SW
                default: o_mem_op = mem_op_t'('X);
            endcase
            o_alu_sel_a = 2'h0;
            o_alu_sel_b = 2'h1;
            o_alu_op    = ADD;
            o_wb_sel    = 2'hX;
            o_branch    = 1'b0;
            o_jump      = 1'b0;
        end
        BRANCH: begin
            case (f3_b)
                3'b000:  o_br_op = BEQ;                                          // BEQ
                3'b001:  o_br_op = BNE;                                          // BNE
                3'b100:  o_br_op = BLT;                                          // BLT
                3'b101:  o_br_op = BGE;                                          // BGE
                3'b110:  o_br_op = BLTU;                                         // BLTU
                3'b111:  o_br_op = BGEU;                                         // BGEU
                default: o_br_op = br_op_t'('X);
            endcase
            o_alu_sel_a = 2'h2;
            o_alu_sel_b = 2'h0;
            o_alu_op    = ADD;
            o_wb_sel    = 2'hX;
            o_branch    = 1'b1;
            o_jump      = 1'b0;
        end
        LOAD: begin
            case (f3_i)
                3'b000:  o_mem_op = LB;                                          // LB
                3'b001:  o_mem_op = LH;                                          // LH
                3'b010:  o_mem_op = LW;                                          // LW
                3'b100:  o_mem_op = LBU;                                         // LBU
                3'b101:  o_mem_op = LHU;                                         // LHU
                default: o_mem_op = mem_op_t'('X);
            endcase
            o_alu_sel_a = 2'h0;
            o_alu_sel_b = 2'h2;
            o_alu_op    = ADD;
            o_wb_sel    = 2'h1;
            o_branch    = 1'b0;
            o_jump      = 1'b0;
        end
        JALR: begin                                                              // JALR;
            o_alu_sel_a = 2'h0;
            o_alu_sel_b = 2'h2;
            o_alu_op   = ADD;
            o_wb_sel   = 2'h0;
            o_branch   = 1'b0;
            o_jump     = 1'b1;
        end
        JAL: begin                                                               // JAL
            o_alu_sel_a = 2'h1;
            o_alu_sel_b = 2'h0;
            o_alu_op    = ADD;
            o_wb_sel    = 2'h0;
            o_branch    = 1'b0;
            o_jump      = 1'b1;
        end
        LUI: begin                                                               // LUI
            o_alu_sel_a = 2'h3;
            o_alu_sel_b = 2'h3;
            o_wb_sel    = 2'h3;
            o_branch    = 1'b0;
            o_jump      = 1'b0;
        end
        AUIPC: begin                                                             // AUIPC
            o_alu_sel_a = 2'h3;
            o_alu_sel_b = 2'h0;
            o_alu_op    = ADD;
            o_wb_sel    = 2'h3;
            o_branch    = 1'b0;
            o_jump      = 1'b0;
        end
    endcase
end

endmodule
