module pe #(
    parameter X_WIDTH = 16,
    parameter Y_WIDTH = X_WIDTH + X_WIDTH - 1
) (
    input  logic clk,
    input  logic rst_n,

    // write enable
    input  logic i_we,

    output logic o_we,

    // column
    input  logic               i_c_vld,
    input  logic [Y_WIDTH-1:0] i_c,

    output logic               o_c_vld,
    output logic [Y_WIDTH-1:0] o_c,

    // row
    input  logic               i_a_vld,
    input  logic [X_WIDTH-1:0] i_a,

    output logic               o_a_vld,
    output logic [X_WIDTH-1:0] o_a
);

// a ingress ff's
logic               a_vld_ff;
logic [X_WIDTH-1:0] a_ff;

always_ff @(posedge clk or negedge rst_n) begin
    a_vld_ff <= i_a_vld;
    a_ff     <= i_a;
end

assign o_a_vld = a_vld_ff;
assign o_a     = a_ff;

// write
logic               b_en;
logic [X_WIDTH-1:0] b_ff;

assign b_en = i_we & i_a_vld;

always_ff @(posedge clk or negedge rst_n)
    if (b_en)
        b_ff <= i_a;


logic we_ff;

always_ff @(posedge clk or negedge rst_n)
    we_ff <= i_we;

assign o_we = we_ff;

// compute valid
logic c_vld_ff;
logic c_vld_next;

assign c_vld_next = i_a_vld & i_c_vld;

always_ff @(posedge clk or negedge rst_n)
    c_vld_ff <= c_vld_next;

assign o_c_vld = c_vld_ff;

// compute
logic [Y_WIDTH-1:0] c_ff;
logic [Y_WIDTH-1:0] c_next;

assign c_next = Y_WIDTH'(i_a) * Y_WIDTH'(b_ff) + Y_WIDTH'(i_c);

always_ff @(posedge clk or negedge rst_n)
    c_ff <= c_next;

assign o_c = c_ff;

endmodule
