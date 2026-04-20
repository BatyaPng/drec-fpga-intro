module core
    import core_pkg::*;
(
    input  logic clk,
    input  logic rst_n,

    input  instruction_t i_instr_data,
    output logic [29:0]  o_instr_addr,

    output logic [29:0] o_mem_addr,
    output logic [31:0] o_mem_data,
    output logic        o_mem_we,
    output logic [3:0]  o_mem_mask,
    input  logic [31:0] i_mem_data
);

endmodule
