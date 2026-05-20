module core
    import core_pkg::*;
(
    input  logic clk,
    input  logic rst_n,

    input  logic [31:0] i_raw_instr,
    output logic [29:0] o_instr_addr,

    output logic [29:0] o_mem_addr,
    output logic [31:0] o_mem_data,
    output logic        o_mem_we,
    output logic [3:0]  o_mem_mask,
    input  logic [31:0] i_mem_data
);

instruction_t instr_data_s0;
instruction_t instr_data_s1;

assign instr_data_s0 = i_raw_instr;

logic [31:0] i_imm_s0;
logic [31:0] s_imm_s0;
logic [31:0] b_imm_s0;
logic [31:0] u_imm_s0;
logic [31:0] j_imm_s0;

logic [31:0] i_imm_s1;
logic [31:0] s_imm_s1;
logic [31:0] b_imm_s1;
logic [31:0] u_imm_s1;
logic [31:0] j_imm_s1;

logic [31:0] alu_a;
logic [31:0] alu_b;
logic [31:0] alu_res;

logic bp_wb_1;
logic bp_wb_2;

logic [1:0] o_alu_sel_b;
logic       o_alu_sel_a;
alu_op_t    alu_op;

logic        mem_off_sel;
logic [31:0] mem_off;
mem_op_t     mem_op;

br_op_t     br_op;
logic       branch;
logic       jump;

logic wb_sel_1;

logic wb_sel_2_s1;
logic wb_sel_2_s2;

logic [31:0] lsu_data;

logic [31:0] pc_offset;
logic [31:0] pc_pre_target;
logic [31:0] pc_target;

logic [1:0] pc_off_sel;
logic pc_sel;

logic bru_res;
logic branch_taken;
logic taken;

logic [31:0] pc_s0;
logic [31:0] pc_inc_s0;

logic [31:0] pc_s1;
logic [31:0] pc_inc_s1;

logic [4:0] rs1;
logic [4:0] rs2;

logic [31:0] src1_s0;
logic [31:0] src2_s0;

logic [31:0] src1_s1;
logic [31:0] src2_s1;

logic [31:0] bp_src1;
logic [31:0] bp_src2;

logic [31:0] wb1_s1;
logic [31:0] wb1_s2;

logic [31:0] dst;

logic  [4:0] rd_s0;
logic  [4:0] rd_s1;
logic  [4:0] rd_s2;

localparam WIDTH_S01 = $bits(instr_data_s0) +$bits(rd_s0) + 5 * $bits(i_imm_s0) + 2 * $bits(src1_s0) + 2* $bits(pc_s0);
localparam WIDTH_S12 = $bits(rd_s1) + $bits(wb_sel_2_s1) + $bits(wb1_s1);

core_pc core_pc (
    .clk           (clk         ),
    .rst_n         (rst_n       ),

    .i_branch      (taken       ),
    .i_branch_addr (pc_target   ),

    .o_instr_addr  (o_instr_addr),
    .o_pc          (pc_s0       ),
    .o_pc_inc      (pc_inc_s0   )
);

core_get_reg core_get_reg (
    .i_instr (instr_data_s0),
    .o_rs1   (rs1          ),
    .o_rs2   (rs2          ),
    .o_rd    (rd_s0        )
);

core_sign_ext core_sign_ext (
    .i_instr (instr_data_s0  ),
    .o_i_imm (i_imm_s0       ),
    .o_s_imm (s_imm_s0       ),
    .o_b_imm (b_imm_s0       ),
    .o_u_imm (u_imm_s0       ),
    .o_j_imm (j_imm_s0       )
);

core_reg core_reg (
    .clk    (clk  ),
    .rst_n  (rst_n),

    .i_rs1  (rs1  ),
    .i_rs2  (rs2  ),

    .i_dst  (dst  ),
    .i_rd   (rd_s2),

    .o_src1 (src1_s0 ),
    .o_src2 (src2_s0 )
);

core_rs_gen #(
    .WIDTH(WIDTH_S01)
) s01 (
    .clk   (clk),
    .rst_n (rst_n),

    .i_data({instr_data_s0,
             rd_s0,
             i_imm_s0,
             s_imm_s0,
             b_imm_s0,
             u_imm_s0,
             j_imm_s0,
             src1_s0,
             src2_s0,
             pc_s0,
             pc_inc_s0}),

    .o_data({instr_data_s1,
             rd_s1,
             i_imm_s1,
             s_imm_s1,
             b_imm_s1,
             u_imm_s1,
             j_imm_s1,
             src1_s1,
             src2_s1,
             pc_s1,
             pc_inc_s1})
);

core_control core_control (
    .i_instr       (instr_data_s1),
    .i_rd_s2       (rd_s2),

    .o_bp_wb_1     (bp_wb_1),
    .o_bp_wb_2     (bp_wb_2),
    .o_alu_sel_a   (o_alu_sel_a),
    .o_alu_sel_b   (o_alu_sel_b),
    .o_alu_op      (alu_op     ),
    .o_mem_off_sel (mem_off_sel),
    .o_mem_op      (mem_op     ),
    .o_br_op       (br_op      ),
    .o_pc_off_sel  (pc_off_sel ),
    .o_pc_sel      (pc_sel     ),
    .o_branch      (branch     ),
    .o_jump        (jump       ),
    .o_wb_sel_1    (wb_sel_1   ),
    .o_wb_sel_2    (wb_sel_2_s1)
);

core_mux2 mux_bp_src1 (
    .i_sel  (bp_wb_1 ),

    .i_data ({dst,
             src1_s1}),

    .o_data (bp_src1 )
);

core_mux2 mux_bp_src2 (
    .i_sel  (bp_wb_2 ),

    .i_data ({dst,
             src2_s1}),

    .o_data (bp_src2 )
);

core_mux2 mux_alu_a (
    .i_sel  (o_alu_sel_a),

    .i_data ({u_imm_s1,
             bp_src1}   ),

    .o_data (alu_a      )
);

core_mux3 mux_alu_b (
    .i_sel  (o_alu_sel_b),

    .i_data ({bp_src2,
             i_imm_s1,
             pc_s1}     ),

    .o_data (alu_b      )
);

core_alu core_alu (
    .i_a   (alu_a  ),
    .i_b   (alu_b  ),

    .i_op  (alu_op ),

    .o_res (alu_res)
);

core_bru core_bru (
    .i_a     (bp_src1),
    .i_b     (bp_src2),

    .i_op    (br_op  ),

    .o_taken (bru_res)
);

core_and br_and (
    .i_a (branch      ),
    .i_b (bru_res     ),

    .o_c (branch_taken)
);

core_mux2 pc_pre_target_mux (
    .i_sel  (pc_sel       ),
    .i_data ({bp_src1,
              pc_s0}      ),

    .o_data (pc_pre_target)
);

core_mux3 pc_off_mux (
    .i_sel  (pc_off_sel),
    .i_data ({j_imm_s1,
             i_imm_s1,
             b_imm_s1} ),

    .o_data (pc_offset )
);

core_sum core_sum (
    .i_a (pc_offset    ),
    .i_b (pc_pre_target),

    .o_c (pc_target    )
);

core_or jmp_or (
    .i_a (jump        ),
    .i_b (branch_taken),

    .o_c (taken       )
);

core_mux2 mux_wb1 (
    .i_sel  (wb_sel_1   ),
    .i_data ({alu_res,
              pc_inc_s1}),

    .o_data (wb1_s1     )
);

core_mux2 mem_off_mux (
    .i_sel  (mem_off_sel),
    .i_data ({s_imm_s1,
              i_imm_s1} ),

    .o_data (mem_off    )
);

core_lsu core_lsu(
    .i_addr          (bp_src1[31:2]),
    .i_offset        (mem_off      ),
    .i_mem_op        (mem_op       ),
    .i_data_core2mem (bp_src2      ),
    .i_data_mem2core (i_mem_data   ),

    .o_core2mem_addr (o_mem_addr   ),
    .o_core2mem_data (o_mem_data   ),
    .o_core2mem_we   (o_mem_we     ),
    .o_core2mem_mask (o_mem_mask   ),

    .o_mem2core_data (lsu_data     )
);

core_rs_gen #(
    .WIDTH(WIDTH_S12)
) s12 (
    .clk    (clk),
    .rst_n  (rst_n),

    .i_data ({rd_s1,
              wb_sel_2_s1,
              wb1_s1}),

    .o_data ({rd_s2,
              wb_sel_2_s2,
              wb1_s2})
);

core_mux2 mux_wb2 (
    .i_sel  (wb_sel_2_s2),
    .i_data ({wb1_s2,
              lsu_data} ),

    .o_data (dst        )
);

endmodule
