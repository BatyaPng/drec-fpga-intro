`ifndef BR_OP_T
`define BR_OP_T

typedef enum reg [2:0] {
    BEQ,
    BNE,
    BLT,
    BGE,
    BLTU,
    BGEU
} br_op_t;

`endif // BR_OP_T
