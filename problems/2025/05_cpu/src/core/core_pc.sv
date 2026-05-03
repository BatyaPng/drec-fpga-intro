module core_pc (
    input  logic clk,
    input  logic rst_n,

    input  logic        i_branch,
    input  logic [31:0] i_branch_addr,

    output logic [31:0] o_pc,
    output logic [31:0] o_pc_next
);

logic [31:0] pc_next;
logic [31:0] pc_ff;

assign pc_next = i_branch ? i_branch_addr : pc_ff + 4;

always_ff @(posedge clk or negedge rst_n)
    if (!rst_n)
        pc_ff <= 32'h1000;
    else
        pc_ff <= pc_next;

assign o_pc      = pc_ff;
assign o_pc_next = pc_next;

endmodule
