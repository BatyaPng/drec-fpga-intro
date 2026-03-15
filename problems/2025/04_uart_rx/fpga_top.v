module fpga_top(
    input  wire CLK,
    input  wire RSTN,

    input  wire RX,

    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

localparam RATE = 2_000_000;


// RSTN synchronizer
reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

reg rx, RX_d;

always @(posedge CLK) begin
    rx <= RX_d;
    RX_d <= RX;
end

reg [15:0] data;

wire [7:0] uart_data;
wire uart_data_vld;

uart_rx_4 #(
    .RATE(RATE)
 ) uart_rx_4 (
    .clk   (CLK),
    .rst_n (rst_n),
    .i_rx  (rx),
    .o_data(uart_data),
    .o_vld (uart_data_vld)
);

always @(posedge CLK or negedge rst_n) begin
    if (!rst_n)
        data <= 16'h0;
    else if (uart_data_vld)
        data <= {8'h0, uart_data};
end

wire  [3:0] anodes;
wire  [7:0] segments;

hex_display_4 hex_display (
    .clk       (CLK     ),
    .rst_n     (rst_n   ),
    .i_data    (data    ),
    .o_anodes  (anodes  ),
    .o_segments(segments)
);

ctrl_74hc595_4 ctrl(
    .clk    (CLK               ),
    .rst_n  (rst_n             ),
    .i_data ({segments, anodes}),
    .o_stcp (STCP              ),
    .o_shcp (SHCP              ),
    .o_ds   (DS                ),
    .o_oe   (OE                )
);

endmodule

