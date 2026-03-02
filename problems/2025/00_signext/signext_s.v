module signext_s #(
    parameter N = 12,
    parameter M = 32
) (
    input  wire [N-1:0] i_data,

    output wire [M-1:0] o_data
);

assign o_data[N-1:0] = i_data;

generate
    genvar i;
    for (i = N; i < M; i = i + 1) begin: g_signext
        assign o_data[i] = i_data[N-1];
    end
endgenerate

endmodule
