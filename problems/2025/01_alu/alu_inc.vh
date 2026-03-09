`ifndef ALU_OP_T
`define ALU_OP_T

typedef enum reg [3:0] {
    ADD,
    SUB,
    SLL,
    SLT,
    SLTU,
    XOR,
    SRL,
    SRA,
    OR,
    AND
} alu_op_t;

`endif // ALU_OP_T
