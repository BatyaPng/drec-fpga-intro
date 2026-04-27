module core_lsu
    import core_pkg::*;
(
    input  logic [31:0] i_addr,
    input  mem_op_t     i_mem_op,
    input  logic [31:0] i_data_core2mem,
    input  logic [31:0] i_data_mem2core,

    output logic [31:0] o_data
);

endmodule
