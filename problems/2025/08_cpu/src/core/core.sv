module core
    import core_pkg::*;
(
    input  logic clk,
    input  logic rst_n,

    input  logic [31:0] i_raw_instr,
    output logic [29:0] o_instr_addr,
    output logic        o_instr_stall,

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
logic [31:0] alu_res;

logic [1:0] o_alu_sel_b;
logic [1:0] o_alu_sel_a;
alu_op_t    alu_op;
mem_op_t    mem_op;
logic       mem_load;
logic       is_load;
logic       mem_out;
br_op_t     br_op;
logic       branch;
logic       jump;

logic [1:0] wb_sel;

logic [31:0] lsu_data;

logic bru_res;
logic branch_taken;
logic taken;

logic [31:0] pc;
logic [31:0] pc_inc;

logic [4:0] rs1;
logic [4:0] rs2;

logic [31:0] src1;
logic [31:0] src2;

logic [31:0] dst;
logic  [4:0] rd;

core_pc core_pc (
    .clk           (clk         ),
    .rst_n         (rst_n       ),

    .i_branch      (taken       ),
    .i_load        (is_load     ),
    .i_branch_addr (alu_res     ),

    .o_instr_addr  (o_instr_addr),
    .o_pc          (pc          ),
    .o_pc_inc      (pc_inc      )
);

core_get_reg core_get_reg (
    .i_instr (instr_data  ),
    .o_rs1   (rs1         ),
    .o_rs2   (rs2         ),
    .o_rd    (rd          )
);

core_sign_ext core_sign_ext (
    .i_instr (instr_data  ),
    .o_i_imm (i_imm       ),
    .o_s_imm (s_imm       ),
    .o_b_imm (b_imm       ),
    .o_u_imm (u_imm       ),
    .o_j_imm (j_imm       )
);

core_mem_out core_mem_out (
    .clk        (clk    ),
    .rst_n      (rst_n  ),

    .i_mem_load (is_load),
    .o_mem_out  (mem_out)
);

core_and load_and (
    .i_a (mem_load),
    .i_b (!mem_out),

    .o_c (is_load )
);

core_reg core_reg (
    .clk    (clk  ),
    .rst_n  (rst_n),

    .i_rs1  (rs1  ),
    .i_rs2  (rs2  ),

    .i_dst  (dst  ),
    .i_rd   (rd   ),

    .o_src1 (src1 ),
    .o_src2 (src2 )
);

core_control core_control (
    .i_isntr     (instr_data  ),

    .o_alu_sel_a (o_alu_sel_a ),
    .o_alu_sel_b (o_alu_sel_b ),
    .o_alu_op    (alu_op      ),
    .o_mem_op    (mem_op      ),
    .o_mem_load  (mem_load    ),
    .o_br_op     (br_op       ),
    .o_branch    (branch      ),
    .o_jump      (jump        ),
    .o_wb_sel    (wb_sel      )
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

    .o_res (alu_res)
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

core_lsu core_lsu(
    .i_addr          (alu_res[31:2]),
    .i_mem_op        (mem_op       ),
    .i_data_core2mem (src2         ),
    .i_data_mem2core (i_mem_data   ),

    .o_core2mem_addr (o_mem_addr   ),
    .o_core2mem_data (o_mem_data   ),
    .o_core2mem_we   (o_mem_we     ),
    .o_core2mem_mask (o_mem_mask   ),

    .o_mem2core_data (lsu_data     )
);

core_mux4 mux_wb (
    .i_sel  (wb_sel ),
    .i_data ({u_imm,
             alu_res,
             lsu_data,
             pc_inc}),

    .o_data (dst    )
);
endmodule
