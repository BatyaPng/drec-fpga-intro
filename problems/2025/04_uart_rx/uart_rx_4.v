module uart_rx_4 #(
    parameter FREQ = 50_000_000,
    parameter RATE =  2_000_000
) (
    input  wire clk,
    input  wire rst_n,

    input  wire i_rx,

    output wire [7:0] o_data,
    output wire       o_vld
);

reg rx_ff;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rx_ff <= 1'b1;
    else
        rx_ff <= i_rx;
end

wire rx_fall = !i_rx & rx_ff;

wire load;
wire en;
reg  shift_en;

reg [7:0] data_ff;

reg [3:0] state, next_state;

localparam [3:0] IDLE  = {1'b0, 3'd0},
                 START = {1'b0, 3'd1},
                 STOP  = {1'b0, 3'd2},
                 BIT0  = {1'b1, 3'd0},
                 BIT1  = {1'b1, 3'd1},
                 BIT2  = {1'b1, 3'd2},
                 BIT3  = {1'b1, 3'd3},
                 BIT4  = {1'b1, 3'd4},
                 BIT5  = {1'b1, 3'd5},
                 BIT6  = {1'b1, 3'd6},
                 BIT7  = {1'b1, 3'd7};

assign load = state == IDLE && rx_fall;

counter_4 #(
    .CNT_WIDTH  ($clog2(FREQ/RATE)),
    .CNT_LOAD   (FREQ/RATE/2      ),
    .CNT_MAX    (FREQ/RATE-1      )
) cnt (
    .clk        (clk  ),
    .rst_n      (rst_n),
    .i_load     (load ),
    .o_en       (en   )
);

always @(*) begin
    case (state)
        IDLE, START, STOP : shift_en = 0;
        default           : shift_en = en;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_ff <= 8'b0;
    else if (shift_en)
        data_ff <= {i_rx, data_ff[7:1]};
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    case (state)
        IDLE:    next_state = rx_fall ? START : state;

        START:   next_state = en      ?
                                        !i_rx ? BIT0 : IDLE
                                      : state;

        BIT0:    next_state = en      ? BIT1  : state;
        BIT1:    next_state = en      ? BIT2  : state;
        BIT2:    next_state = en      ? BIT3  : state;
        BIT3:    next_state = en      ? BIT4  : state;
        BIT4:    next_state = en      ? BIT5  : state;
        BIT5:    next_state = en      ? BIT6  : state;
        BIT6:    next_state = en      ? BIT7  : state;
        BIT7:    next_state = en      ? STOP  : state;
        STOP:    next_state = en      ? IDLE  : state;
        default: next_state = state;
    endcase
end

assign o_data = data_ff;
assign o_vld = en && state == STOP && i_rx;

endmodule
