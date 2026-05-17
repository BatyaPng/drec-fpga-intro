module mem_xbar #(
    parameter DATA_START = 30'h0400,
    parameter DATA_LIMIT = 30'h3FFF,
    parameter MMIO_START = 30'h0000,
    parameter MMIO_LIMIT = 30'h03FF
)(
    input  wire [29:0] i_addr,
    input  wire [31:0] i_data,
    input  wire        i_wren,
    input  wire [3:0]  i_mask,
    output wire [31:0] o_data,

    output wire [29:0] o_dmem_addr,
    output wire [31:0] o_dmem_data,
    output wire [3:0]  o_dmem_mask,
    output wire        o_dmem_wren,
    input  wire [31:0] i_dmem_data,

    output wire [29:0] o_mmio_addr,
    output wire [31:0] o_mmio_data,
    output wire        o_mmio_wren,
    output wire [3:0]  o_mmio_mask,
    input  wire [31:0] i_mmio_data
);

    wire is_dmem;
    wire is_mmio;

    assign is_dmem = (i_addr >= DATA_START) && (i_addr <= DATA_LIMIT);
    assign is_mmio = (i_addr >= MMIO_START) && (i_addr <= MMIO_LIMIT);

    assign o_dmem_addr = i_addr;
    assign o_mmio_addr = i_addr;

    assign o_dmem_data = i_data;
    assign o_mmio_data = i_data;

    assign o_dmem_mask = i_mask;
    assign o_mmio_mask = i_mask;

    assign o_dmem_wren = i_wren & is_dmem;
    assign o_mmio_wren = i_wren & is_mmio;

    assign o_data = is_dmem ? i_dmem_data : (is_mmio ? i_mmio_data : 32'b0);

endmodule
