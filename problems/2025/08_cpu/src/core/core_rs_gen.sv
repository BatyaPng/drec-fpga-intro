module core_rs_gen #(
    WIDTH = 16
) (
    input  logic clk,
    input  logic rst_n,

    input  logic [WIDTH-1:0] i_data,

    output logic [WIDTH-1:0] o_data
);

logic [WIDTH-1:0] data_ff;

always_ff @(posedge clk or negedge rst_n)
    if (!rst_n)
        data_ff <= '0;
    else
        data_ff <= i_data;

assign o_data = data_ff;

endmodule
