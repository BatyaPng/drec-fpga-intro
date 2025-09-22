#include <cstdint>

#define SIZE 4

typedef struct {
    uint64_t data[SIZE][SIZE];
} matrix_t;

extern "C" matrix_t matrix_mul(const matrix_t a, const matrix_t b) {
    matrix_t c{};

    for (int i = 0; i < SIZE; ++i) {
        for (int j = 0; j < SIZE; ++j) {
            uint64_t sum = 0;
            for (int k = 0; k < SIZE; ++k) {
                uint64_t mul = a.data[i][k] * b.data[k][j];
                sum += mul;
            }
            c.data[i][j] = sum;
        }
    }
    return c;
}
