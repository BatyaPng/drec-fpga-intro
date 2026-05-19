module fp16mul #(
    parameter ROUND_TIES_TO_EVEN = 1'b1
) (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,

    output wire [15:0] o_res
);

// Initial field extraction and DAZ {{{

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

// }}}

// Exp ops {{{

wire sign_res = sign_a ^ sign_b;

wire [6:0] exp_a_signed = {2'b00, exp_a};
wire [6:0] exp_b_signed = {2'b00, exp_b};
wire [6:0] exp_raw = exp_a_signed + exp_b_signed - 7'd15;

// }}}

// Mantissa ops {{{

wire [10:0] mant_a = {1'b1, frac_a};
wire [10:0] mant_b = {1'b1, frac_b};
wire [21:0] mult_res = mant_a * mant_b;

// }}}

// Normalization {{{

wire norm_shift = mult_res[21];

wire [6:0] exp_norm = exp_raw + {6'd0, norm_shift};

wire [9:0] frac_norm;
wire L;
wire G;
wire R;
wire S;

assign frac_norm = norm_shift ? mult_res[20:11] : mult_res[19:10];
assign L = norm_shift ? mult_res[11] : mult_res[10];
assign G = norm_shift ? mult_res[10] : mult_res[9];
assign R = norm_shift ? mult_res[9]  : mult_res[8];
assign S = norm_shift ? (|mult_res[8:0]) : (|mult_res[7:0]);

// }}}

// Rounding {{{

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
wire [6:0] exp_final = exp_norm + {6'd0, round_overflow};

// }}}

// Exceptions {{{

wire res_is_nan = a_is_nan | b_is_nan | (a_is_inf & b_is_zero) | (a_is_zero & b_is_inf);
wire res_is_inf = (a_is_inf | b_is_inf) & !res_is_nan;
wire res_is_zero= (a_is_zero | b_is_zero) & !res_is_nan;

wire is_underflow = (exp_final <= 7'd0);
wire is_overflow  = (exp_final >= 7'd31);

wire [4:0] out_exp;
wire [9:0] out_frac;

assign out_exp = res_is_nan   ? 5'h1F :
                 res_is_inf   ? 5'h1F :
                 res_is_zero  ? 5'h00 :
                 is_overflow  ? 5'h1F :
                 is_underflow ? 5'h00 :
                 exp_final[4:0];

assign out_frac = res_is_nan   ? {1'b1, 9'd0} :
                  res_is_inf   ? 10'd0 :
                  res_is_zero  ? 10'd0 :
                  is_overflow  ? 10'd0 :
                  is_underflow ? 10'd0 :
                  frac_final;

assign o_res = {sign_res, out_exp, out_frac};

// }}}

endmodule
