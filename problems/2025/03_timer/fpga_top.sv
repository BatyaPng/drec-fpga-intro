module fpga_top(
    input  wire CLK,   // CLOCK
    input  wire RSTN,  // BUTTON RST (NEGATIVE)
    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

reg rst_n, RSTN_d;

wire clk_1MHz;

always @(posedge clk_1MHz) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

pll pll(
    .inclk0	 (CLK	   ),
    .c0      (clk_1MHz )
);

wire [2:0][3:0] sec;

timer timer (
    .clk    (CLK),
    .rst_n  (rst_n),
    .o_sec  (sec)
);

wire  [3:0] anodes;
wire  [7:0] segments;

hex_display hex_display(clk_1MHz, rst_n, {4'(0), sec}, anodes, segments);

ctrl_74hc595 ctrl(
    .clk    (clk_1MHz           ),
    .rst_n  (rst_n              ),
    .i_data ({segments, anodes} ),
    .o_stcp (STCP               ),
    .o_shcp (SHCP               ),
    .o_ds   (DS                 ),
    .o_oe   (OE                 )
);

endmodule
