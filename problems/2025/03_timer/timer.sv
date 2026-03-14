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

reg  [DIG_CNT-1:0][DIG_WIDTH-1:0] sec_ff;
wire [DIG_CNT-1:0][DIG_WIDTH-1:0] sec_next;
wire [DIG_CNT-1:0]                sec_dec;

assign sec_dec[0] = cnt_ff == 0;
assign sec_dec[DIG_CNT-1] = sec_ff[DIG_CNT-2] == 0 && sec_dec[DIG_CNT-2];

assign cnt_next = sec_dec[0] ? PERIOD : cnt_ff - 1;
assign sec_next[0] = sec_dec[0+1] ? sec_ff[DIG_CNT-1:1] != 1 ? 9 : 0
                                  : sec_ff[0] - sec_dec[0];
assign sec_next[DIG_CNT-1] = sec_ff[DIG_CNT-1] == 0 && sec_dec[DIG_CNT-1] ? 6 : sec_ff[DIG_CNT-1] - sec_dec[DIG_CNT-1];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt_ff <= PERIOD;
    else
        cnt_ff <= cnt_next;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        sec_ff[0] <= 9;
    else
        sec_ff[0] <= sec_next[0];
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        sec_ff[DIG_CNT-1] <= DIG_WIDTH'(6);
    else
        sec_ff[DIG_CNT-1] <= sec_next[DIG_CNT-1];
end

generate
genvar i;
    for (i = 1; i < DIG_CNT-1; i = i + 1) begin: g_sec
        assign sec_dec[i] = sec_ff[i-1] == 0 && sec_dec[i-1];

        assign sec_next[i] = sec_dec[i+1] ? sec_ff[DIG_CNT-1:1] == 1 ? 0
                                                                     : sec_ff[i+1] != 0 ? 9
                                                                                        : 0
                                          : sec_ff[i] - sec_dec[i];

        always @(posedge clk or negedge rst_n) begin
            if (!rst_n)
                sec_ff[i] <= DIG_WIDTH'(1'b0);
            else
                sec_ff[i] <= sec_next[i];
        end
    end
endgenerate

assign o_sec = sec_ff;

endmodule
