module sa #(
    parameter SIZE = 4,
    parameter X_WIDTH = 16,
    parameter Y_WIDTH = X_WIDTH * SIZE - SIZE
) (
    input  logic clk,
    input  logic rst_n,

    // write enable
    input  logic i_we,

    input  logic               i_matrix_vld,
    input  logic [X_WIDTH-1:0] i_matrix [SIZE][SIZE],

    output logic               o_matrix_vld,
    output logic [Y_WIDTH-1:0] o_matrix [SIZE][SIZE]
);

logic [X_WIDTH-1:0] row [SIZE];

generate
    for (genvar i = 0; i < SIZE; i++) begin: gen_row_assign
        assign row[i] = i_matrix[i];
    end
endgenerate

// sr row inst
logic               row_vld_delayed [SIZE];
logic [X_WIDTH-1:0] row_delayed     [SIZE];

generate
    for (genvar i = 0; i < SIZE; i++) begin: gen_sr_row_inst
        sr #(
            .DEPTH     (i             ),
            .DAT_WIDTH (X_WIDTH       )
        ) u_sr (
            .clk       (clk           ),
            .rst_n     (rst_n         ),

            .i_dat_vld (i_matrix_vld  ),
            .i_dat     (row[i]        ),

            .o_dat_vld (row_vld_delayed[i]),
            .o_dat     (row_delayed[i])
        );
    end
endgenerate

// pe inst

logic               pe_x_vld [SIZE+1][SIZE];
logic [X_WIDTH-1:0] pe_x     [SIZE+1][SIZE];

logic               pe_y_vld [SIZE][SIZE+1];
logic [Y_WIDTH-1:0] pe_y     [SIZE][SIZE+1];

logic               pe_we [SIZE][SIZE+1];

generate
    for (genvar y = 0; y < SIZE; y++) begin: gen_column0
        assign pe_x_vld[y][0] = row_vld_delayed[y];
        assign pe_x[y][0]     = row_delayed[y];
    end
endgenerate

generate
    for (genvar x = 0; x < SIZE; x++) begin: gen_row0
        assign pe_y_vld[0][x] = 1;
        assign pe_y[0][x] = Y_WIDTH'(0);

        assign pe_we[0][x] = i_we;
    end
endgenerate

generate
    for (genvar i = 0; i < SIZE ; i++) begin: gen_pe_x
        for (genvar j = 0; j < SIZE ; j++) begin: gen_pe_y
            pe #(
                .X_WIDTH (X_WIDTH ),
                .Y_WIDTH (Y_WIDTH )
            ) u_pe (
                .clk     (clk     ),
                .rst_n   (rst_n   ),

                .i_we    (pe_we[i][j]    ),
                .o_we    (pe_we[i+1][j]),

                .i_c_vld (pe_y_vld[i][j] ),
                .i_c     (pe_y[i][j]     ),
                .o_c_vld (pe_y_vld[i+1][j] ),
                .o_c     (pe_y[i+1][j]     ),

                .i_a_vld (pe_x_vld[i][j]),
                .i_a     (pe_x[i][j]),
                .o_a_vld (pe_x_vld[i][j+1] ),
                .o_a     (pe_x[i][j+1]     )
            );
            end
        end
endgenerate

// sr col inst
logic               col_vld_delayed [SIZE];
logic [Y_WIDTH-1:0] col_delayed     [SIZE];

generate
    for (genvar i = 0; i < SIZE ; i++) begin: gen_sr_col_inst
        sr #(
            .DEPTH (SIZE - 1 - i),
            .DAT_WIDTH (Y_WIDTH)
        ) u_sr (
            .clk (clk),
            .rst_n (rst_n),

            .i_dat_vld (pe_y_vld[0][SIZE]),
            .i_dat (pe_y[0][SIZE]),

            .o_dat_vld (col_vld_delayed[i]),
            .o_dat (col_delayed[i])
        );
    end
endgenerate

// out assign
localparam CNT_WIDTH = $clog2(SIZE);

logic [CNT_WIDTH-1:0] cnt_ff;
logic                 cnt_start;
logic                 cnt_stop;

assign cnt_start = !cnt_stop & col_vld_delayed[SIZE-1];
assign cnt_stop  = cnt_ff == CNT_WIDTH'(SIZE - 1);

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        cnt_ff <= CNT_WIDTH'(0);
    else if (cnt_start)
        cnt_ff <= cnt_ff + 1;
    else if (cnt_stop)
        cnt_ff <= CNT_WIDTH'(0);
end

logic               matrix_en;
logic               matrix_vld;
logic [Y_WIDTH-1:0] matrix_ff [SIZE][SIZE];

assign matrix_en  = cnt_start | cnt_stop;
assign matrix_vld = cnt_stop;

generate
    for (genvar i = 0; i < SIZE; i ++) begin: gen_matrix_x
        for (genvar j = 0; j < SIZE; j++) begin: gen_matrix_y
            always_ff @(posedge clk or negedge rst_n) begin
                if (matrix_en & cnt_ff == CNT_WIDTH'(i))
                    matrix_ff[i][j] <= col_delayed[j];
            end
        end
    end
endgenerate

assign o_matrix_vld = matrix_vld;
assign o_matrix     = matrix_ff;

endmodule
