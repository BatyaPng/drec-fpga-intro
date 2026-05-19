`timescale 1ns/1ps

module rf_2r1w_tb;

logic        clk;
logic        rst_n;
logic [4:0]  i_rs1;
logic [4:0]  i_rs2;
logic [31:0] i_dst;
logic [4:0]  i_rd;
logic [31:0] o_src1;
logic [31:0] o_src2;

rf_2r1w dut (
    .clk    (clk),
    .rst_n  (rst_n),
    .i_rs1  (i_rs1),
    .i_rs2  (i_rs2),
    .i_dst  (i_dst),
    .i_rd   (i_rd),
    .o_src1 (o_src1),
    .o_src2 (o_src2)
);

always #5 clk = ~clk;

initial begin
    clk   = 0;
    rst_n = 0;
    i_rs1 = 0;
    i_rs2 = 0;
    i_dst = 0;
    i_rd  = 0;

    #20;
    rst_n = 1;
    #10;

    @(posedge clk);
    i_rd  = 5'd1;
    i_dst = 32'hDEADBEEF;

    @(posedge clk);
    i_rd  = 5'd2;
    i_dst = 32'hCAFEBABE;

    @(posedge clk);
    i_rd  = 5'd0;
    i_dst = 32'h0;

    #5;
    i_rs1 = 5'd1;
    i_rs2 = 5'd2;

    #20;

    $display("Read Reg 1 (Expected DEADBEEF): %h", o_src1);
    $display("Read Reg 2 (Expected CAFEBABE): %h", o_src2);

    $finish;
end

endmodule
