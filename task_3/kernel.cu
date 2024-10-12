#include <iostream>
#include <stdio.h>
#include <time.h>
#include <random>
#include <curand.h>
#include <curand_kernel.h>
#include <math.h>
#include "device_launch_parameters.h"

#define MAX 6 //maximum of your dice
#define MIN 1 //minimum of your dice


__global__ void setup_kernel(curandState* state) {
	int index = threadIdx.x + blockDim.x * blockIdx.x;
	curand_init(1234, index, 0, &state[index]);
}

__global__ void monte_carlo_kernel(curandState* state, int* count, int m) {
	unsigned int index = threadIdx.x + blockDim.x * blockIdx.x;

	__shared__ int cache[256];
	cache[threadIdx.x] = 0;
	__syncthreads();

	unsigned int temp = 0;
	int sumroll = 0;
	while (temp < m) {
		sumroll += int(((curand_uniform(&state[index])) * (MAX - MIN + 0.999999)) + MIN);
		temp++;
	} if (sumroll == 3 * m) {
		cache[threadIdx.x] = 1;
	}

	// reduction
	int i = blockDim.x / 2;
	while (i != 0) {
		if (threadIdx.x < i) {
			cache[threadIdx.x] += cache[threadIdx.x + i];
		}

		i /= 2;
		__syncthreads();
	}


	// update to our global variable count
	if (threadIdx.x == 0) {
		atomicAdd(count, cache[0]);
	}

}

int main()
{
	unsigned int n = 1024 * 4 * 256; //Number of runs,If you change this, you must also change THREADS
	unsigned int m = 2; //Number of dice
	int* h_count;
	int* d_count;
	curandState* d_state;
	float chance;


	// allocate memory
	h_count = (int*)malloc(n * sizeof(int));
	cudaMalloc((void**)&d_count, n * sizeof(int));
	cudaMalloc((void**)&d_state, n * sizeof(curandState));
	cudaMemset(d_count, 0, sizeof(int));

	// set kernel
	dim3 BLOCKS = 1024*4;
	dim3 THREADS = 256;
	setup_kernel << < BLOCKS, THREADS >> > (d_state);


	// monte carlo kernel
	monte_carlo_kernel << <BLOCKS, THREADS >> > (d_state, d_count, m);


	// copy results back to the host
	cudaMemcpy(h_count, d_count, sizeof(int), cudaMemcpyDeviceToHost);


	// display results for gpu
	std::cout << *h_count << std::endl;
	chance = float(*h_count) / float(n);
	std::cout << "Chance is " << chance << std::endl;


	// delete memory
	free(h_count);
	cudaFree(d_count);
	cudaFree(d_state);
}
