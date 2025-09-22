module sa_tb;

import sa_pkg::*;

logic clk;  initial clk = 0; always #1 clk = ~clk;

logic rst_n = 0;
initial #10 rst_n = ~rst_n;

// dur inst

logic i_we = 0;

logic               i_matrix_vld = 0;
logic [X_WIDTH-1:0] i_matrix [SIZE][SIZE] = 0;

logic               c_matrix_vld = 0;
logic [Y_WIDTH-1:0] c_matrix [SIZE][SIZE] = 0;

sa #(
    .SIZE    (SIZE    ),
    .X_WIDTH (X_WIDTH ),
    .Y_WIDTH (Y_WIDTH )
) u_sa (
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .i_we         (i_we         ),
    .i_matrix_vld (i_matrix_vld ),
    .i_matrix     (i_matrix     ),
    .o_matrix_vld (c_matrix_vld ),
    .o_matrix     (c_matrix     )
);


import "DPI-C" function matrix_t matrix_mul(
    input matrix_t a,
    input matrix_t b
);

function automatic bit compare(
    input logic [Y_WIDTH-1:0] a [SIZE][SIZE],
    input logic [Y_WIDTH-1:0] b [SIZE][SIZE],
    input logic [Y_WIDTH-1:0] c [SIZE][SIZE]
);
    bit ok = 1'b1;

    matrix_t a_m, b_m, c_m, g_m;
    foreach (a_m.matrix[i, j]) begin
        a_m.matrix[i][j] = a[i][j];
        b_m.matrix[i][j] = b[i][j];
        c_m.matrix[i][j] = c[i][j];

    end

    g_m = matrix_mul(a_m, b_m);

    foreach (g_m.matrix[i, j]) begin
        if (c_m.matrix[i][j] !== g_m.matrix[i][j]) begin
            ok = 1'b0;
            $error("MISMATCH [%0d,%0d]: dut=%0h golden=%0h",
                   i, j, c_m.matrix[i][j], g_m.matrix[i][j]);
        end
    end

    if (ok)
        $display("Matrix multiply matches golden model.");

    return ok;

endfunction

endmodule
