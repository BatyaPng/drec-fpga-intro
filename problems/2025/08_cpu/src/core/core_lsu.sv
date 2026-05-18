module core_lsu
    import core_pkg::*;
(
    input  logic [29:0] i_addr,
    input  logic [31:0] i_offset,
    input  mem_op_t     i_mem_op,
    input  logic [31:0] i_data_core2mem,
    input  logic [31:0] i_data_mem2core,

    output logic [29:0] o_core2mem_addr,
    output logic [31:0] o_core2mem_data,
    output logic        o_core2mem_we,
    output logic [3:0]  o_core2mem_mask,

    output logic [31:0] o_mem2core_data
);

    assign o_core2mem_addr = 30'(({i_addr, 2'b0} + i_offset) >> 2);

    always_comb begin
        o_core2mem_we   = 1'b0;
        o_core2mem_mask = 4'b0000;
        o_core2mem_data = i_data_core2mem;

        case (i_mem_op)
            SB: begin
                o_core2mem_we   = 1'b1;
                o_core2mem_mask = 4'b0001;
                o_core2mem_data = {4{i_data_core2mem[7:0]}};
            end
            SH: begin
                o_core2mem_we   = 1'b1;
                o_core2mem_mask = 4'b0011;
                o_core2mem_data = {2{i_data_core2mem[15:0]}};
            end
            SW: begin
                o_core2mem_we   = 1'b1;
                o_core2mem_mask = 4'b1111;
            end
        endcase
    end

    always_comb begin
        o_mem2core_data = i_data_mem2core;

        case (i_mem_op)
            LB:  o_mem2core_data = {{24{i_data_mem2core[7]}},  i_data_mem2core[7:0]};
            LH:  o_mem2core_data = {{16{i_data_mem2core[15]}}, i_data_mem2core[15:0]};
            LBU: o_mem2core_data = {24'b0, i_data_mem2core[7:0]};
            LHU: o_mem2core_data = {16'b0, i_data_mem2core[15:0]};
            LW:  o_mem2core_data = i_data_mem2core;
        endcase
    end

endmodule
