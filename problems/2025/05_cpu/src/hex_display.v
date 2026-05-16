module hex_display #(
    parameter CNT_WIDTH = 14
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] i_data,
    input  wire        i_we,
    output wire [3:0]  o_anodes,
    output reg  [7:0]  o_segments
);

reg [CNT_WIDTH-1:0] cnt;
wire          [1:0] pos = cnt[CNT_WIDTH-1:CNT_WIDTH-2];

reg [3:0] hex_digit;
always @(*) begin
    case (pos)
        2'b00: hex_digit = i_data[3:0];
        2'b01: hex_digit = i_data[7:4];
        2'b10: hex_digit = i_data[11:8];
        2'b11: hex_digit = i_data[15:12];
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt <= {CNT_WIDTH{1'b0}};
    else
        cnt <= cnt + 1'b1;
end

assign o_anodes = ~(4'b1 << pos);

always @(*) begin
    case (hex_digit)
        4'h0:    o_segments = i_we ? 8'b11111100 : 8'b00000001;
        4'h1:    o_segments = i_we ? 8'b01100000 : 8'b00000001;
        4'h2:    o_segments = i_we ? 8'b11011010 : 8'b00000001;
        4'h3:    o_segments = i_we ? 8'b11110010 : 8'b00000001;
        4'h4:    o_segments = i_we ? 8'b01100110 : 8'b00000001;
        4'h5:    o_segments = i_we ? 8'b10110110 : 8'b00000001;
        4'h6:    o_segments = i_we ? 8'b10111110 : 8'b00000001;
        4'h7:    o_segments = i_we ? 8'b11100000 : 8'b00000001;
        4'h8:    o_segments = i_we ? 8'b11111110 : 8'b00000001;
        4'h9:    o_segments = i_we ? 8'b11110110 : 8'b00000001;
        4'hA:    o_segments = i_we ? 8'b11101110 : 8'b00000001;
        4'hB:    o_segments = i_we ? 8'b00111110 : 8'b00000001;
        4'hC:    o_segments = i_we ? 8'b10011100 : 8'b00000001;
        4'hD:    o_segments = i_we ? 8'b01111010 : 8'b00000001;
        4'hE:    o_segments = i_we ? 8'b10011110 : 8'b00000001;
        4'hF:    o_segments = i_we ? 8'b10001110 : 8'b00000001;
        default: o_segments = i_we ? 8'b00000000 : 8'b00000001;
    endcase
end

endmodule
