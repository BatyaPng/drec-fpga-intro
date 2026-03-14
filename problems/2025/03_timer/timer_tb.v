`timescale 1ns/1ns

module timer_tb;

localparam FCLK = 1e6;
localparam WIDTH_M = $clog2(61);
localparam WIDTH_F = $clog2(10);

reg clk = 0;
reg rst_n = 0;

always
    #1 clk = !clk;

initial begin
    repeat (6)
        @(posedge clk)

    rst_n <= 1'b1;
end

wire [WIDTH_M-1:0] o_sec;
wire [WIDTH_F-1:0] o_d_sec;

timer_1 timer_dut (
    .clk    (clk),
    .rst_n  (rst_n),
    .o_sec  (o_sec),
    .o_d_sec(o_d_sec)
);

initial begin
    $dumpvars;

    repeat (70_000_000)
        @(posedge clk);

    $finish;
end

endmodule
