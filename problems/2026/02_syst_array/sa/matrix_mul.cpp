// matrix_mul.cpp
#include <cstdint>

// Параметры должны совпадать с теми, что в TB/DUT
static constexpr int SIZE    = 4;
static constexpr int I_WIDTH = 16;
static constexpr int O_WIDTH = I_WIDTH * SIZE - SIZE;

// Эквивалент SystemVerilog typedef struct packed { logic [O_WIDTH-1:0] matrix[SIZE][SIZE]; }
typedef struct {
    uint64_t matrix[SIZE][SIZE];
} matrix_t;

extern "C" matrix_t matrix_mul(const matrix_t a, const matrix_t b) {
    matrix_t c{}; // zero-init

    for (int i = 0; i < SIZE; ++i) {
        for (int j = 0; j < SIZE; ++j) {
            uint64_t sum = 0;
            for (int k = 0; k < SIZE; ++k) {
                uint64_t mul = a.matrix[i][k] * b.matrix[k][j]; // без контроля переполнений
                sum += mul;                                      // без масок/обрезки
            }
            c.matrix[i][j] = sum;
        }
    }
    return c;
}
