package sa_pkg;

localparam SIZE = 4;
localparam I_WIDTH = 16;
localparam MATRIX_WIDTH = I_WIDTH * SIZE - SIZE;


typedef struct packed {
    logic [MATRIX_WIDTH-1:0] matrix [SIZE][SIZE];
} matrix_t;

endpackage
