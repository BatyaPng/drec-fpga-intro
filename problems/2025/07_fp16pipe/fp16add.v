module fp16add #(
    parameter ROUND_TIES_TO_EVEN = 1'b1
) (
    input  wire        clk,
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,

    output wire [15:0] o_res
);

// Exponent Difference {{{

wire sign_a = i_a[15];
wire [4:0] exp_a = i_a[14:10];
wire [9:0] frac_a = i_a[9:0];

wire sign_b = i_b[15];
wire [4:0] exp_b = i_b[14:10];
wire [9:0] frac_b = i_b[9:0];

wire a_is_zero = (exp_a == 5'd0);
wire b_is_zero = (exp_b == 5'd0);

wire a_is_inf  = (exp_a == 5'h1F) && (frac_a == 10'd0);
wire b_is_inf  = (exp_b == 5'h1F) && (frac_b == 10'd0);

wire a_is_nan  = (exp_a == 5'h1F) && (frac_a != 10'd0);
wire b_is_nan  = (exp_b == 5'h1F) && (frac_b != 10'd0);

wire a_lt_b = ({exp_a, frac_a} < {exp_b, frac_b});
wire [4:0] exp_L = a_lt_b ? exp_b : exp_a;
wire [4:0] exp_S = a_lt_b ? exp_a : exp_b;
wire [4:0] exp_diff = exp_L - exp_S;

// }}}

// Swap {{{

wire sign_L = a_lt_b ? sign_b : sign_a;
wire [9:0] frac_L = a_lt_b ? frac_b : frac_a;
wire L_is_zero = a_lt_b ? b_is_zero : a_is_zero;

wire sign_S = a_lt_b ? sign_a : sign_b;
wire [9:0] frac_S = a_lt_b ? frac_a : frac_b;
wire S_is_zero = a_lt_b ? a_is_zero : b_is_zero;

wire is_sub = sign_a ^ sign_b;

// }}}

// >> {{{

wire [4:0] shift_amt = (exp_diff > 5'd15) ? 5'd15 : exp_diff;

wire [10:0] mant_L_raw = L_is_zero ? 11'd0 : {1'b1, frac_L};
wire [10:0] mant_S_raw = S_is_zero ? 11'd0 : {1'b1, frac_S};

wire [26:0] mant_S_shifted_full = {mant_S_raw, 16'd0} >> shift_amt;

wire [10:0] mant_S_aligned = mant_S_shifted_full[26:16];
wire G_align = mant_S_shifted_full[15];
wire R_align = mant_S_shifted_full[14];
wire S_align = |mant_S_shifted_full[13:0];

wire [13:0] op_L = {mant_L_raw, 3'b000};
wire [13:0] op_S = {mant_S_aligned, G_align, R_align, S_align};

// }}}

// Sign-Magnitude Adder {{{

wire [14:0] adder_res;
assign adder_res = is_sub ? (op_L - op_S) : (op_L + op_S);

wire s1_res_is_nan = a_is_nan | b_is_nan | (a_is_inf & b_is_inf & is_sub);
wire s1_res_is_inf = (a_is_inf | b_is_inf) & !s1_res_is_nan;

// }}}

reg [14:0] adder_res_q;
reg [4:0]  exp_L_q;
reg        sign_L_q;
reg        res_is_nan_q;
reg        res_is_inf_q;

always @(posedge clk) begin
    adder_res_q  <= adder_res;
    exp_L_q      <= exp_L;
    sign_L_q     <= sign_L;
    res_is_nan_q <= s1_res_is_nan;
    res_is_inf_q <= s1_res_is_inf;
end


wire res_is_exact_zero = (adder_res_q == 15'd0);
wire add_ovf = adder_res_q[14];

// Leading One Detector {{{

wire [3:0] lzc;
assign lzc =
    adder_res_q[13] ? 4'd0 :
    adder_res_q[12] ? 4'd1 :
    adder_res_q[11] ? 4'd2 :
    adder_res_q[10] ? 4'd3 :
    adder_res_q[9]  ? 4'd4 :
    adder_res_q[8]  ? 4'd5 :
    adder_res_q[7]  ? 4'd6 :
    adder_res_q[6]  ? 4'd7 :
    adder_res_q[5]  ? 4'd8 :
    adder_res_q[4]  ? 4'd9 :
    adder_res_q[3]  ? 4'd10 :
    adder_res_q[2]  ? 4'd11 :
    adder_res_q[1]  ? 4'd12 :
    adder_res_q[0]  ? 4'd13 : 4'd14;

// }}}

// << {{{

wire [13:0] norm_val = add_ovf ? adder_res_q[14:1] : (adder_res_q[13:0] << lzc);

wire [9:0] frac_norm = norm_val[12:3];
wire L = norm_val[3];
wire G = norm_val[2];
wire R = norm_val[1];
wire S = norm_val[0] | (add_ovf & adder_res_q[0]);

// }}}

// Exponent Update {{{

// Use registered exp_L_q here
wire [6:0] exp_L_signed = {2'b00, exp_L_q};
wire [6:0] exp_norm_raw = add_ovf ? (exp_L_signed + 7'sd1) : (exp_L_signed - {3'd0, lzc});

// }}}

// Round {{{

wire round_up;
generate
    if (ROUND_TIES_TO_EVEN) begin : gen_round_rte
        assign round_up = G & (R | S | L);
    end else begin : gen_round_rtz
        assign round_up = 1'b0;
    end
endgenerate

wire [10:0] frac_rounded = {1'b0, frac_norm} + {10'd0, round_up};
wire round_overflow = frac_rounded[10];

wire [9:0] frac_final = round_overflow ? 10'd0 : frac_rounded[9:0];

// }}}

// Final Exponent Update & Outputs {{{

wire [6:0] exp_final  = exp_norm_raw + {6'd0, round_overflow};

// Use registered signs and flags
wire sign_final = res_is_exact_zero ? 1'b0 : sign_L_q;

wire is_underflow = (exp_final <= 7'd0) & !res_is_exact_zero;
wire is_overflow  = (exp_final >= 7'd31);

wire [4:0] out_exp;
wire [9:0] out_frac;

assign out_exp = res_is_nan_q      ? 5'h1F :
                 res_is_inf_q      ? 5'h1F :
                 res_is_exact_zero ? 5'h00 :
                 is_overflow       ? 5'h1F :
                 is_underflow      ? 5'h00 :
                 exp_final[4:0];

assign out_frac = res_is_nan_q      ? {1'b1, 9'd0} :
                  res_is_inf_q      ? 10'd0 :
                  res_is_exact_zero ? 10'd0 :
                  is_overflow       ? 10'd0 :
                  is_underflow      ? 10'd0 :
                  frac_final;

assign o_res = {sign_final, out_exp, out_frac};

// }}}

endmodule
