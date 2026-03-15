module timer #(
    parameter FCLK = 1e6,
    parameter DIG_CNT = 3,
    parameter DIG_WIDTH = $clog2(10)
) (
    input  wire clk,
    input  wire rst_n,

    output wire [DIG_CNT-1:0][DIG_WIDTH-1:0] o_sec
);

localparam PERIOD = 6000000;
localparam CNT_WIDTH = $clog2(PERIOD);

reg  [CNT_WIDTH-1:0] cnt_ff;
wire [CNT_WIDTH-1:0] cnt_next;

wire cycle;
wire [DIG_CNT-1:0] underflow;

reg  [DIG_CNT:0] is_zero_ff;
wire [DIG_CNT:0] is_zero_next;

reg  [DIG_CNT-1:0][DIG_WIDTH-1:0] sec_ff;
wire [DIG_CNT-1:0][DIG_WIDTH-1:0] sec_next;
wire [DIG_CNT-1:0]                sec_dec;

assign cycle = sec_ff[DIG_CNT-1:0] == {DIG_WIDTH'(0), {(DIG_CNT-3){DIG_WIDTH'(0)}}, DIG_WIDTH'(1), DIG_WIDTH'(0)};

generate
    genvar i, k;
    for (i = 0; i < DIG_CNT; i = i + 1) begin: g_underflow
        assign underflow[i] = sec_ff[i] == 0 && sec_dec[i];
    end

    assign is_zero_next[DIG_CNT] = 1;
    for (k = DIG_CNT - 1; k > 0; k = k - 1) begin: g_isZero
        assign is_zero_next[k] = is_zero_ff[k+1] && underflow[k];
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        is_zero_ff <= 1 << DIG_CNT;
    else
        is_zero_ff <= is_zero_next;
end

assign sec_dec [0] = cnt_ff == 0;

assign sec_next[0] = underflow[0] ? 9 : sec_ff[0] - sec_dec[0];

generate
    genvar j;
    for (j = 1; j < DIG_CNT; j = j + 1) begin: g_dig
        assign sec_dec[j] = underflow[j-1];

        assign sec_next[j] = underflow[j] ? 9 & {DIG_WIDTH{!is_zero_next[j]}}
                                          : sec_ff[j] - sec_dec[j];
    end
endgenerate

assign cnt_next = sec_dec[0] ? PERIOD : cnt_ff - 1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt_ff <= PERIOD;
    else if (cycle)
        cnt_ff <= PERIOD;
    else
        cnt_ff <= cnt_next;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        sec_ff <= {DIG_WIDTH'(1), {(DIG_CNT-2){DIG_WIDTH'(0)}}, DIG_WIDTH'(9)};
    else if (cycle)
        sec_ff <= {DIG_WIDTH'(6), {(DIG_CNT-2){DIG_WIDTH'(0)}}, DIG_WIDTH'(9)};
    else
        sec_ff <= sec_next;
end

assign o_sec = sec_ff;

endmodule
