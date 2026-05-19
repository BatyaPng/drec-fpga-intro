module rf_2r1w (
    input  logic clk,
    input  logic rst_n,

    input  logic [4:0] i_rs1,
    input  logic [4:0] i_rs2,

    input  logic [31:0] i_dst,
    input  logic  [4:0] i_rd,

    output logic [31:0] o_src1,
    output logic [31:0] o_src2
);

logic [31:0][31:0] reg_ff;

always_ff @(posedge clk or negedge rst_n)
    if (!rst_n)
        reg_ff <= '0;
    else
        reg_ff[i_rd] <= i_dst;

assign o_src1 = reg_ff[i_rs1];
assign o_src2 = reg_ff[i_rs2];

endmodule
