module core_reg (
    input  logic clk,
    input  logic rst_n,

    input  logic [4:0] i_rs1,
    input  logic [4:0] i_rs2,

    input  logic [31:0] i_dst,
    input  logic  [4:0] i_rd,

    output logic [31:0] o_src1,
    output logic [31:0] o_src2
);

logic              reg_en;
logic [31:0][31:0] reg_ff;

logic bypass_1;
logic bypass_2;

assign reg_en = i_rd != 0;

always_ff @(posedge clk or negedge rst_n)
    if (!rst_n)
        reg_ff <= '0;
    else if (reg_en)
        reg_ff[i_rd] <= i_dst;

assign bypass_1 = (i_rs1 == i_rd) && reg_en;
assign bypass_2 = (i_rs2 == i_rd) && reg_en;

assign o_src1 = bypass_1 ? i_dst : reg_ff[i_rs1];
assign o_src2 = bypass_2 ? i_dst : reg_ff[i_rs2];

endmodule
