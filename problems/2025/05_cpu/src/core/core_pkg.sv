package core_pkg;

  typedef struct packed {
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
  } payload_r_t;

  typedef struct packed {
    logic [11:0] imm;
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

  typedef struct packed {
    payload_t   payload;
    logic [6:0] opcode;
  } instruction_t;

endpackage : core_pkg
