module core_pc (
    input  logic clk,
    input  logic rst_n,

    input  logic        i_branch,
    input  logic [31:0] i_branch_addr,

    output logic [29:0] o_instr_addr,
    output logic [31:0] o_pc,
    output logic [31:0] o_pc_inc
);

logic [29:0] pc_next;
logic [29:0] pc_ff;

assign pc_next = i_branch ? i_branch_addr[31:2] : pc_ff + 1;

always_ff @(posedge clk or negedge rst_n)
    if (!rst_n)
        pc_ff <= (32'h1000) >> 2;
    else
        pc_ff <= pc_next;

assign o_instr_addr = rst_n ? pc_next : (32'h1000) >> 2;
assign o_pc         = {pc_ff, 2'b0};
assign o_pc_inc     = {pc_ff + 1'b1, 2'b0};

endmodule
