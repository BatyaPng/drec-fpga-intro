module timer_1 #(
    parameter FCLK = 1e6,
    parameter WIDTH_M = $clog2(61),
    parameter WIDTH_F = $clog2(10)
) (
    input  wire clk,
    input  wire rst_n,

    output wire [WIDTH_M-1:0] o_sec,
    output wire [WIDTH_F-1:0] o_d_sec
);

// localparam PERIOD = int unsigned'(1e-1 / (1 / FCLK));
localparam PERIOD = 100000;
localparam CNT_WIDTH = $clog2(PERIOD);

reg  [CNT_WIDTH-1:0] cnt_ff;
wire [CNT_WIDTH-1:0] cnt_next;

reg  [WIDTH_F-1:0] d_sec_ff;
wire [WIDTH_F-1:0] d_sec_next;
wire               d_sec_dec;

reg  [WIDTH_M-1:0] sec_ff;
wire [WIDTH_M-1:0] sec_next;
wire               sec_dec;

assign d_sec_dec = cnt_ff == 0;
assign sec_dec = d_sec_ff == 0 && d_sec_dec;

assign cnt_next = d_sec_dec ? CNT_WIDTH'(PERIOD) : cnt_ff - 1;
assign d_sec_next = sec_dec ? 9 : d_sec_ff - d_sec_dec;
assign sec_next = sec_ff == 0 && sec_dec ? 60 : sec_ff - sec_dec;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt_ff <= CNT_WIDTH'(PERIOD);
    else
        cnt_ff <= cnt_next;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        d_sec_ff <= WIDTH_F'(1'b0);
    else
        d_sec_ff <= d_sec_next;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        sec_ff <= WIDTH_M'(1'b0);
    else
        sec_ff <= sec_next;
end

assign o_sec = sec_ff;
assign o_d_sec = d_sec_ff;

endmodule
