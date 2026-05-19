module fpga_top(
    input  wire CLK,
    input  wire RSTN,

    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output reg  [15:0] o_res
);

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n  <= RSTN_d;
    RSTN_d <= RSTN;
end

reg  [15:0] a, b;
wire [15:0] res;

always @(posedge CLK) begin
   o_res <= res;
   a     <= i_a;
   b     <= i_b;
end

fp16add u_fp16add (
   .i_a      (a),
   .i_b      (b),
   .o_res    (res)
);

endmodule
