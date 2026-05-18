module core_sum (
    input  logic [31:0] i_a,
    input  logic [31:0] i_b,

    output logic [31:0] o_c
);

assign o_c = i_a + i_b;

endmodule
