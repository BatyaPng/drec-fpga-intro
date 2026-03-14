module lsfr16 #(
    parameter WIDTH = 16
) (
    input  wire clk,
    input  wire rst_n,

    input  wire i_en,
    input  wire [WIDTH-1:0] i_seed,

    output wire [WIDTH-1:0] o_num
);

reg  [WIDTH-1:0] lsfr;
wire             lsfr_bit = lsfr[15] ^ lsfr[14] ^ lsfr[13] ^ lsfr[11];
wire [WIDTH-1:0] lsfr_next = {lsfr[WIDTH-2:0], lsfr_bit};

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        lsfr <= i_seed;
    else if (i_en)
        lsfr <= lsfr_next;
end

assign o_num = lsfr;

endmodule
