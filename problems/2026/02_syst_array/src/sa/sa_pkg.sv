package sa_pkg;

localparam SIZE = 4;
localparam X_WIDTH = 16;
localparam MATRIX_WIDTH = X_WIDTH * SIZE - SIZE;
localparam Y_WIDTH = X_WIDTH * SIZE - SIZE;

typedef struct {
    logic [MATRIX_WIDTH-1:0] matrix [SIZE][SIZE];
} matrix_t;

endpackage
