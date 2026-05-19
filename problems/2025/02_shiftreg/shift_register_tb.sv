module shift_register_tb;

logic       clk;
logic       rst_n;
logic       i_en;
logic       i_load;
logic [7:0] i_d;
logic       o_d;

shift_register dut (
    .clk    (clk),
    .rst_n  (rst_n),
    .i_en   (i_en),
    .i_load (i_load),
    .i_d    (i_d),
    .o_d    (o_d)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 0;
    i_en = 0;
    i_load = 0;
    i_d = 8'b0;

    #15;
    rst_n = 1;

    #10;
    i_d = 8'b10100111;
    i_load = 1;
    #10;
    i_load = 0;

    #10;
    i_en = 1;
    #80;
    i_en = 0;

    #20;
    $finish;
end

endmodule
