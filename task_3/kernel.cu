#include <iostream>
#include <stdio.h>
#include <time.h>
#include <random>
#include <curand.h>
#include <curand_kernel.h>
#include <math.h>
#include "device_launch_parameters.h"
#include <chrono>

#define MAX 6 //maximum of your dice
#define MIN 1 //minimum of your dice
#define Blocks 4 * 32 * 32 * 32 //Number of blocks, for changing the sample size easily

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
	unsigned int n = Blocks * 256; //Number of runs, If you change this, change the first number and change BLOCKS accordingly
	unsigned int m = 3; //Number of dice
	int* h_count;
	int* d_count;
	curandState* d_state;
	float chance;


	// allocate memory
	h_count = (int*)malloc(n * sizeof(int));
	cudaMalloc((void**)&d_count, n * sizeof(int));
	cudaMalloc((void**)&d_state, n * sizeof(curandState));
	cudaMemset(d_count, 0, sizeof(int));

	//Taking start time
	auto start = std::chrono::steady_clock::now();

	// set kernel
	dim3 BLOCKS = Blocks;
	dim3 THREADS = 256;
	setup_kernel << < BLOCKS, THREADS >> > (d_state);


	// monte carlo kernel
	monte_carlo_kernel << <BLOCKS, THREADS >> > (d_state, d_count, m);

	//Taking the end time
	auto end = std::chrono::steady_clock::now();
	double time_elapsed_ns = double(std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count());

	// copy results back to the host
	cudaMemcpy(h_count, d_count, sizeof(int), cudaMemcpyDeviceToHost);

	// display results for gpu
	std::cout << *h_count << std::endl;
	chance = float(*h_count) / float(n);
	std::cout << "Chance is " << chance << std::endl;
	std::cout << "Time taken to run: " << time_elapsed_ns / 1e6 << std::endl;


	// delete memory
	free(h_count);
	cudaFree(d_count);
	cudaFree(d_state);
}