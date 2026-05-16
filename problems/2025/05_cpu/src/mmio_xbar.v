module mmio_xbar (
    input  wire [29:0] i_mmio_addr,
    input  wire [31:0] i_mmio_data,
    input  wire [ 3:0] i_mmio_mask,
    input  wire        i_mmio_wren,
    output wire [31:0] o_mmio_data,

    output wire [15:0] o_hexd_data,
    output wire        o_hexd_wren
);

assign is_hexd_addr = (i_mmio_addr == (32'h20) >> 2);

assign o_hexd_wren = is_hexd_addr && i_mmio_wren;
assign o_hexd_data = i_mmio_data[15:0];
assign o_mmio_data = 32'b0;

endmodule
