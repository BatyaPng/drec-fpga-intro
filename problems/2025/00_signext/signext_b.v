module signext_b #(
    parameter N = 12,
    parameter M = 32
) (
    input  wire [N-1:0] i_data,

    output wire [M-1:0] o_data
);

assign o_data = {{M-N{i_data[N-1]}}, i_data};

endmodule