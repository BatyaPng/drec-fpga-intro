`timescale 1ns/1ps

module signext_tb;

localparam N = 20;
localparam M = 32;

reg  [N-1:0] i_data;
wire [M-1:0] o_data_behavioral;
wire [M-1:0] o_data_structural;

signext_b #(
    .N(N),
    .M(M)
) dut_b (
    .i_data(i_data),
    .o_data(o_data_behavioral)
);

signext_s #(
    .N(N),
    .M(M)
) dut_s (
    .i_data(i_data),
    .o_data(o_data_structural)
);

initial begin
    $dumpvars;

    i_data = 100; #10;

    i_data = -1; #10;

    i_data = -5; #10;

    $finish;
end


endmodule
