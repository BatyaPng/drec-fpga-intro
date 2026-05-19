module lfsr8 #(
    parameter WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,

    input  logic             i_en,
    input  logic [WIDTH-1:0] i_seed,

    output logic [WIDTH-1:0] o_num
);

logic [WIDTH-1:0] lfsr;

logic             lfsr_bit;
logic [WIDTH-1:0] lfsr_next;

assign lfsr_bit = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];
assign lfsr_next = {lfsr[WIDTH-2:0], lfsr_bit};

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        lfsr <= i_seed;
    else if (i_en)
        lfsr <= lfsr_next;
end

assign o_num = lfsr;

endmodule
