#include <iostream>
#include <random>
#include <cstdint>

#define SIZE 4

typedef struct {
    uint64_t data[SIZE][SIZE];
} matrix_t;

extern "C" matrix_t generate_matrix() {
    matrix_t m{};

    std::random_device rd;
    std::mt19937_64 gen(rd());
    std::uniform_int_distribution<uint64_t> dist(0, UINT64_MAX);

    for (size_t i = 0; i < SIZE; ++i) {
        for (size_t j = 0; j < SIZE; ++j) {
            m.data[i][j] = dist(gen);
        }
    }

    return m;
}