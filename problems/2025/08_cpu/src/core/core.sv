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
logic [1:0] o_alu_sel_a;
alu_op_t    alu_op;

mem_op_t    mem_op;

br_op_t     br_op;
logic       branch;
logic       jump;

logic [1:0] wb_sel_0;
logic [1:0] wb_sel_1;

logic [31:0] lsu_data;

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

logic [31:0] dst;
logic  [4:0] rd_0;
logic  [4:0] rd_1;

localparam WIDTH_RS = $size(wb_sel_0) + $size(pc_inc_0) + $size(alu_res_0) + $size(rd_0);

core_pc core_pc (
    .clk           (clk         ),
    .rst_n         (rst_n       ),

    .i_branch      (taken       ),
    .i_branch_addr (alu_res_0   ),

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
    .i_isntr     (instr_data  ),

    .o_alu_sel_a (o_alu_sel_a ),
    .o_alu_sel_b (o_alu_sel_b ),
    .o_alu_op    (alu_op      ),
    .o_mem_op    (mem_op      ),
    .o_br_op     (br_op       ),
    .o_branch    (branch      ),
    .o_jump      (jump        ),
    .o_wb_sel    (wb_sel_0    )
);

core_mux4 mux_alu_a (
    .i_sel  (o_alu_sel_a),

    .i_data ({u_imm,
             b_imm,
             j_imm,
             src1}      ),

    .o_data (alu_a      )
);

core_mux4 mux_alu_b (
    .i_sel  (o_alu_sel_b),

    .i_data ({src2,
             i_imm,
             s_imm,
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

    .i_data ({wb_sel_0,
              pc_inc_0,
              alu_res_0,
              rd_0}),

    .o_data ({wb_sel_1,
              pc_inc_1,
              alu_res_1,
              rd_1})
);

core_lsu core_lsu(
    .i_addr          (alu_res_0[31:2]),
    .i_mem_op        (mem_op         ),
    .i_data_core2mem (src2           ),
    .i_data_mem2core (i_mem_data     ),

    .o_core2mem_addr (o_mem_addr     ),
    .o_core2mem_data (o_mem_data     ),
    .o_core2mem_we   (o_mem_we       ),
    .o_core2mem_mask (o_mem_mask     ),

    .o_mem2core_data (lsu_data       )
);

core_mux3 mux_wb (
    .i_sel  (wb_sel_1 ),
    .i_data ({alu_res_1,
             lsu_data,
             pc_inc_1}),

    .o_data (dst    )
);
endmodule
