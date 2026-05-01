module core_or (
    input  logic i_a,
    input  logic i_b,

    output logic o_c
);

assign o_c = i_a | i_b;

endmodule
