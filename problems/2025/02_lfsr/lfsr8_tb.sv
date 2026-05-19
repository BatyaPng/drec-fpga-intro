`timescale 1ns/1ps

module lfsr8_tb;

logic clk;
logic rst_n;
logic i_en;
logic [7:0] i_seed;
logic [7:0] o_num;

lfsr8 #(.WIDTH(8)) uut (
    .clk(clk),
    .rst_n(rst_n),
    .i_en(i_en),
    .i_seed(i_seed),
    .o_num(o_num)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 0;
    i_en = 0;
    i_seed = 8'h01;
    #20;
    rst_n = 1;
    #10;
    i_en = 1;

    repeat (300) begin
        @(posedge clk);
        if (o_num == 8'h00) begin
            $fatal;
        end
    end

    $finish;
end

endmodule
