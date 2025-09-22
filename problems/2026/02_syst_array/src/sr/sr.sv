module sr #(
    parameter DEPTH = 1,
    parameter DAT_WIDTH = 16
) (
    input  logic clk,
    input  logic rst_n,

    input  logic i_dat_vld,
    input  logic [DAT_WIDTH-1:0] i_dat,

    output logic o_dat_vld,
    output logic [DAT_WIDTH-1:0] o_dat
);

generate
    if (DEPTH > 0) begin: gen_nonzero_depth
        logic                 shift_dat_vld_ff [DEPTH];
        logic [DAT_WIDTH-1:0] shift_dat_ff     [DEPTH];

        always_ff @(posedge clk or negedge rst_n)
            if (~rst_n)
                shift_dat_vld_ff[0] <= 0;
            else
                shift_dat_vld_ff[0] <= i_dat_vld;

        always_ff @(posedge clk or negedge rst_n)
            shift_dat_ff[0] <= i_dat;

        for (genvar i = 1; i < DEPTH; i++) begin: gen_shift
            always_ff @(posedge clk or negedge rst_n)
                if (~rst_n)
                    shift_dat_vld_ff[i] <= 0;
                else
                    shift_dat_vld_ff[i] <= shift_dat_vld_ff[i-1];

            always_ff @(posedge clk or negedge rst_n)
                shift_dat_ff[i] <= shift_dat_ff[i-1];
        end

        assign o_dat_vld = shift_dat_vld_ff[DEPTH-1];
        assign o_dat     = shift_dat_ff[DEPTH-1];

    end
    else begin: gen_zero_depth
        assign o_dat_vld = i_dat_vld;
        assign o_dat     = i_dat;
    end
endgenerate

endmodule
