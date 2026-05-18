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

`ifndef FPGA
    a_no_x_rs1: assert property (@(posedge clk) disable iff (!rst_n) !$isunknown(i_rs1))
        else $fatal(1, "i_rs1 is X or Z!");

    a_no_x_rs2: assert property (@(posedge clk) disable iff (!rst_n) !$isunknown(i_rs2))
        else $fatal(1, "i_rs2 is X or Z!");

    a_no_x_rd: assert property (@(posedge clk) disable iff (!rst_n) !$isunknown(i_rd))
        else $fatal(1, "i_rd is X or Z!");

    a_no_x_dst: assert property (@(posedge clk) disable iff (!rst_n) (i_rd != 0) |-> !$isunknown(i_dst))
        else $fatal(1, "i_dst is X or Z during an active write!");

    a_no_x_src1: assert property (@(posedge clk) disable iff (!rst_n) !$isunknown(o_src1))
        else $fatal(1, "o_src1 is X or Z!");

    a_no_x_src2: assert property (@(posedge clk) disable iff (!rst_n) !$isunknown(o_src2))
        else $fatal(1, "o_src2 is X or Z!");
`endif

endmodule
