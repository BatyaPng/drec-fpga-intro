module core_mux4 (
    input logic [1:0] i_sel,

    input logic [3:0][31:0] i_data,

    output logic [31:0] o_data
);

assign o_data = i_data[i_sel];

endmodule
