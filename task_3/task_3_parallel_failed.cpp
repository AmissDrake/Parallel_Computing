
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <curand.h>
#include <curand_kernel.h>
#include "thrust/device_vector.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define MIN 1
#define MAX 6


int N = 3; //Number of dice
int runs = 1000; //Number of runs
int num = N * runs;

__global__ void estimator(int* gpudiceresults, int num, int N, float* chance_d) {
	//Calculating number of runs
	int runs = N * num;

	//indexing
	int i = blockIdx.x * blockDim.x + threadIdx.x;

	//Setting up cuRAND
	curandState state;
	curand_init((unsigned long long)clock() + i, i, 0, &state);

	//Dice rolls, N dice times number of runs
	if (i < num) {
		gpudiceresults[i] = int(((curand_uniform(&state))*(MAX-MIN+ 0.999999))+MIN);
	}

	//Summing up every N dice rolls to check if they add up to 3N
	thrust::device_vector<int> count;
	for (int j = 0; j < num; j+=N) {
		int temp_sum = 0;
		for (int k = j; k < N; k++) {
			temp_sum += gpudiceresults[k];
		}
		if (temp_sum == 3 * N) {
			count[i]=1;
		}
	}
	int final_count = thrust::reduce(count.begin(), count.end());
	//Calculating the chance of it being 3N
	*chance_d = float(final_count) / float(runs);
	return;
}

int main() {

	//Blocks and threads
	int THREADS = 256;
	int BLOCKS = (N*runs + THREADS - 1) / THREADS;

	//Initializing variables and copying them to the device
	float chance_h = 0; //Chance variable on host
	float* chance_d; //Pointer to chance variable on device
	cudaMalloc(&chance_d, sizeof(chance_h));
	cudaMemcpy(chance_d, &chance_h, sizeof(chance_h), cudaMemcpyHostToDevice);

	int* gpudiceresults = 0;
	cudaMalloc(&gpudiceresults, num * sizeof(int));

	estimator <<<BLOCKS, THREADS >>> (gpudiceresults, num, N, chance_d);

	cudaMemcpy(&chance_h, chance_d, sizeof(chance_h), cudaMemcpyDeviceToHost);

	//cudaMemcpy(count_h, count_d, sizeof(count_d), cudaMemcpyDeviceToHost);
	//count_h = *count_d;
	//cudaFree(&gpudiceresults);
	//float chance = float(*count_h) / float(runs);

	std::cout << "the chance is " << chance_h << std::endl;
	return 0;
}