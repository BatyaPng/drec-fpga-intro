module shift_register (
    input  logic       clk,
    input  logic       rst_n,

    input  logic       i_en,
    input  logic       i_load,

    input  logic [7:0] i_d,

    output logic       o_d
);

logic [7:0] shift_reg;

always_ff @(posedge clk or negedge rst_n)  begin
    if (!rst_n)
        shift_reg <= 8'b0;
    else if (i_load)
        shift_reg <= i_d;
    else if (i_en)
        shift_reg <= {shift_reg[6:0], 1'b0};
end

assign o_d = shift_reg[7];

endmodule
