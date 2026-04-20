module core_pc (
    input  logic clk,
    input  logic rst_n,

    input  logic        i_branch,
    input  logic [29:0] i_branch_addr,

    output logic [29:0] o_instr_addr
);

logic [29:0] pc_next;
logic [29:0] pc_ff;

assign pc_next = i_branch ? i_branch_addr : pc_ff + 1;

always_ff @(posedge clk or negedge rst_n)
    if (!rst_n)
        pc_ff <= 30'h1000;
    else
        pc_ff <= pc_next;

endmodule
