package core_pkg;

typedef enum logic [3:0] {
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

typedef enum logic [2:0] {
    SB,
    SH,
    SW,
    LB,
    LH,
    LW,
    LBU,
    LHU
} mem_op_t;

typedef enum logic [2:0] {
    BEQ,
    BNE,
    BLT,
    BGE,
    BLTU,
    BGEU
} br_op_t;

typedef struct packed {
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
} payload_r_t;

typedef struct packed {
    union packed {
        logic [11:0] imm_11_0;
        struct packed {
            logic [6:0] funct7;
            logic [4:0] shamt;
        } shift_op;
    } imm_u;
    logic [4:0]  rs1;
    logic [2:0]  funct3;
    logic [4:0]  rd;
} payload_i_t;

typedef struct packed {
    logic [6:0] imm_11_5;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] imm_4_0;
} payload_s_t;

typedef struct packed {
    logic       imm_12;
    logic [5:0] imm_10_5;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [3:0] imm_4_1;
    logic       imm_11;
} payload_b_t;

typedef struct packed {
    logic [19:0] imm_31_12;
    logic [4:0]  rd;
} payload_u_t;

typedef struct packed {
    logic       imm_20;
    logic [9:0] imm_10_1;
    logic       imm_11;
    logic [7:0] imm_19_12;
    logic [4:0] rd;
} payload_j_t;

typedef union packed {
    payload_r_t r;
    payload_i_t i;
    payload_s_t s;
    payload_b_t b;
    payload_u_t u;
    payload_j_t j;
    logic [24:0] raw;
} payload_t;

typedef enum logic [6:0] {
    OP_IMM = 7'b0010011,
    OP     = 7'b0110011,
    STORE  = 7'b0100011,
    BRANCH = 7'b1100011,
    LOAD   = 7'b0000011,
    JALR   = 7'b1100111,
    JAL    = 7'b1101111,
    LUI    = 7'b0110111,
    AUIPC  = 7'b0010111
} opcode_e;

typedef struct packed {
    payload_t payload;
    opcode_e  opcode;
} instruction_t;

endpackage : core_pkg
