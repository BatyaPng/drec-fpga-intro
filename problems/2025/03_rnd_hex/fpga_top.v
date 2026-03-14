module fpga_top(
    input  wire CLK,   // CLOCK
    input  wire RSTN,  // BUTTON RST (NEGATIVE)
    input  wire KEY1,
    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

reg key1, KEY1_d;

always @(posedge CLK) begin
    key1 <= KEY1_d;
    KEY1_d <= KEY1;
end

wire en = !KEY1_d & key1;

wire [15:0] rnd_num;

lsfr16 lsfr16 (
    .clk   (CLK),
    .rst_n (rst_n),

    .i_en  (en),
    .i_seed(16'h43),
    .o_num (rnd_num)
);

wire  [3:0] anodes;
wire  [7:0] segments;

hex_display hex_display(CLK, rst_n, rnd_num, anodes, segments);

ctrl_74hc595 ctrl(
    .clk    (CLK                ),
    .rst_n  (rst_n              ),
    .i_data ({segments, anodes} ),
    .o_stcp (STCP               ),
    .o_shcp (SHCP               ),
    .o_ds   (DS                 ),
    .o_oe   (OE                 )
);

endmodule
