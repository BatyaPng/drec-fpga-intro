module core_mux2 # (
    parameter WIDTH = 32
) (
    input logic  i_sel,

    input logic [1:0][WIDTH-1:0] i_data,

    output logic [WIDTH-1:0] o_data
);

assign o_data = i_data[i_sel];

endmodule

