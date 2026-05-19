module clkdiv #(
    parameter I_FREQ = 50_000_000,
    parameter O_FREQ = 9_600
) (
    input  logic clk,
    input  logic rst_n,

    output logic o_clk_div
);

localparam int RATIO = I_FREQ / O_FREQ;
localparam int CNT_WIDTH = $clog2(RATIO);

logic [CNT_WIDTH-1:0] cnt_ff;

always_ff @(posedge clk or negedge rst_n)
    if (!rst_n)
        cnt_ff <= '0;
    else if (o_clk_div)
        cnt_ff <= '0;
    else
        cnt_ff <= cnt_ff + 1'b1;

assign o_clk_div = cnt_ff == RATIO;

endmodule
