module sa_tb;

import sa_pkg::*;

// localparam SIZE = 4;
// localparam I_WIDTH = 16;
// localparam O_WIDTH = I_WIDTH * SIZE - SIZE;

import "DPI-C" function matrix_t matrix_mul(
    input matrix_t a,
    input matrix_t b
);

function automatic bit compare(
    input logic [I_WIDTH-1:0] a [SIZE][SIZE],
    input logic [I_WIDTH-1:0] b [SIZE][SIZE],
    input logic [O_WIDTH-1:0] c [SIZE][SIZE]
);
    bit ok = 1'b1;

    matrix_t a_m, b_m, g_m;
    foreach (a_m.matrix[i, j]) begin
        a_m.matrix[i][j] = a[i][j];
        b_m.matrix[i][j] = b[i][j];
    end

    g_m = matrix_mul(a_m, b_m);

    foreach (g_m.matrix[i, j]) begin
        if (c_dut[i][j] !== g_m.matrix[i][j]) begin
            ok = 1'b0;
            $error("MISMATCH [%0d,%0d]: dut=%0h golden=%0h",
                   i, j, C_dut[i][j], g_m.matrix[i][j]);
        end
    end

    if (ok)
        $display("Matrix multiply matches golden model.");

    return ok;

endfunction

endmodule
