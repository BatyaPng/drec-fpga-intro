module clkdiv2 (
    input  wire clk,
    input  wire rst_n,

    input  wire i_en,

    output wire o_div
);

reg div_ff;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        div_ff <= 1'b0;
    else if (i_en)
        div_ff <= !div_ff;
end

assign o_div = div_ff;

endmodule
