`timescale 1ns/1ps

module clkdiv_tb;

logic clk;
logic rst_n;

logic o_clk_9600;
logic o_clk_38400;
logic o_clk_115200;

clkdiv #(
    .I_FREQ(50_000_000),
    .O_FREQ(9_600)
) dut_9600 (
    .clk(clk),
    .rst_n(rst_n),
    .o_clk_div(o_clk_9600)
);

clkdiv #(
    .I_FREQ(50_000_000),
    .O_FREQ(38_400)
) dut_38400 (
    .clk(clk),
    .rst_n(rst_n),
    .o_clk_div(o_clk_38400)
);

clkdiv #(
    .I_FREQ(50_000_000),
    .O_FREQ(115_200)
) dut_115200 (
    .clk(clk),
    .rst_n(rst_n),
    .o_clk_div(o_clk_115200)
);

always #10 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 0;
    #40;
    rst_n = 1;
    #600000;
    $finish;
end

endmodule
