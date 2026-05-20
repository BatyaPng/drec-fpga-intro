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

instruction_t instr_data;
assign instr_data = i_raw_instr;

logic [31:0] i_imm;
logic [31:0] s_imm;
logic [31:0] b_imm;
logic [31:0] u_imm;
logic [31:0] j_imm;

logic [31:0] alu_a;
logic [31:0] alu_b;
logic [31:0] alu_res_0;
logic [31:0] alu_res_1;

logic [1:0] o_alu_sel_b;
logic       o_alu_sel_a;
alu_op_t    alu_op;

logic        mem_off_sel;
logic [31:0] mem_off;
mem_op_t     mem_op;

br_op_t     br_op;
logic       branch;
logic       jump;

logic wb_sel_1_0;
logic wb_sel_2_0;

logic wb_sel_1_1;
logic wb_sel_2_1;

logic [31:0] lsu_data;

logic [31:0] pc_offset;
logic [31:0] pc_pre_target;
logic [31:0] pc_target;

logic [1:0] pc_off_sel;
logic pc_sel;

logic bru_res;
logic branch_taken;
logic taken;

logic [31:0] pc;
logic [31:0] pc_inc_0;
logic [31:0] pc_inc_1;

logic [4:0] rs1;
logic [4:0] rs2;

logic [31:0] src1;
logic [31:0] src2;

logic [31:0] wb1;
logic [31:0] dst;
logic  [4:0] rd_0;
logic  [4:0] rd_1;

localparam WIDTH_RS = $bits({wb_sel_1_0, wb_sel_2_0}) + $bits(pc_inc_0) + $bits(alu_res_0) + $bits(rd_0);

core_pc core_pc (
    .clk           (clk         ),
    .rst_n         (rst_n       ),

    .i_branch      (taken       ),
    .i_branch_addr (pc_target   ),

    .o_instr_addr  (o_instr_addr),
    .o_pc          (pc          ),
    .o_pc_inc      (pc_inc_0    )
);

core_get_reg core_get_reg (
    .i_instr (instr_data  ),
    .o_rs1   (rs1         ),
    .o_rs2   (rs2         ),
    .o_rd    (rd_0        )
);

core_sign_ext core_sign_ext (
    .i_instr (instr_data  ),
    .o_i_imm (i_imm       ),
    .o_s_imm (s_imm       ),
    .o_b_imm (b_imm       ),
    .o_u_imm (u_imm       ),
    .o_j_imm (j_imm       )
);

core_reg core_reg (
    .clk    (clk  ),
    .rst_n  (rst_n),

    .i_rs1  (rs1  ),
    .i_rs2  (rs2  ),

    .i_dst  (dst  ),
    .i_rd   (rd_1 ),

    .o_src1 (src1 ),
    .o_src2 (src2 )
);

core_control core_control (
    .i_instr       (instr_data ),

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
    .o_wb_sel_1    (wb_sel_1_0 ),
    .o_wb_sel_2    (wb_sel_2_0 )
);

core_mux2 mux_alu_a (
    .i_sel  (o_alu_sel_a),

    .i_data ({u_imm,
             src1}      ),

    .o_data (alu_a      )
);

core_mux3 mux_alu_b (
    .i_sel  (o_alu_sel_b),

    .i_data ({src2,
             i_imm,
             pc}        ),

    .o_data (alu_b      )
);

core_alu core_alu (
    .i_a   (alu_a  ),
    .i_b   (alu_b  ),

    .i_op  (alu_op ),

    .o_res (alu_res_0)
);

core_bru core_bru (
    .i_a     (src1 ),
    .i_b     (src2 ),

    .i_op    (br_op),

    .o_taken (bru_res)
);

core_and br_and (
    .i_a (branch      ),
    .i_b (bru_res     ),

    .o_c (branch_taken)
);

core_mux2 pc_pre_target_mux (
    .i_sel  (pc_sel       ),
    .i_data ({src1,
             pc}          ),

    .o_data (pc_pre_target)
);

core_mux3 pc_off_mux (
    .i_sel  (pc_off_sel),
    .i_data ({j_imm,
             i_imm,
             b_imm}    ),

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

core_rs_gen #(
    .WIDTH(WIDTH_RS)
 ) core_rs_gen (
    .clk    (clk),
    .rst_n  (rst_n),

    .i_data ({wb_sel_1_0,
              wb_sel_2_0,
              pc_inc_0,
              alu_res_0,
              rd_0}),

    .o_data ({wb_sel_1_1,
              wb_sel_2_1,
              pc_inc_1,
              alu_res_1,
              rd_1})
);

core_mux2 mem_off_mux (
    .i_sel  (mem_off_sel),
    .i_data ({s_imm,
             i_imm}     ),

    .o_data (mem_off    )
);

core_lsu core_lsu(
    .i_addr          (src1[31:2]     ),
    .i_offset        (mem_off        ),
    .i_mem_op        (mem_op         ),
    .i_data_core2mem (src2           ),
    .i_data_mem2core (i_mem_data     ),

    .o_core2mem_addr (o_mem_addr     ),
    .o_core2mem_data (o_mem_data     ),
    .o_core2mem_we   (o_mem_we       ),
    .o_core2mem_mask (o_mem_mask     ),

    .o_mem2core_data (lsu_data       )
);

core_mux2 mux_wb1 (
    .i_sel  (wb_sel_1_1),
    .i_data ({alu_res_1,
              lsu_data}),

    .o_data (wb1       )
);

core_mux2 mux_wb2 (
    .i_sel  (wb_sel_2_1),
    .i_data ({pc_inc_1,
              wb1}     ),

    .o_data (dst       )
);

endmodule
