#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <cstdlib> //For randomizing input array
#include <chrono> //For measuring runtime
#include <cmath>
 
__global__ void ArrayAdd(int* A, int* B, int* C, int N) {
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	if (i < N) {
		C[i] = A[i] + B[i];
	}
	return;
}

void arrayinit(int* A, const int N) {
	for (int i = 0; i < N; i++) {
		A[i] = i;
	}
}

int main() {
	//Taking start time	
	auto start = std::chrono::steady_clock::now();

	const int N = 2 << 15; //Edit the array size here

	//Initializing arrays
	int A[N];
	int B[N];
	int C[N];
	arrayinit(A, N);
	arrayinit(B, N);

	//Use this codeblock if you want to set custom array values
	//int A[N] = { 1,2,3,4,5 };
	//int B[N] = { 1,2,3,4,5 };
	//int C[N] = {};

	//Creating GPU pointers
	int* gpuA = 0;
	int* gpuB = 0;
	int* gpuC = 0;

	//Allocating memory in the GPU
	cudaMalloc(&gpuA, sizeof(A));
	cudaMalloc(&gpuB, sizeof(B));	
	cudaMalloc(&gpuC, sizeof(C));

	//Copying the arrays into the GPU memory
	cudaMemcpy(gpuA, A, sizeof(A), cudaMemcpyHostToDevice);	
	cudaMemcpy(gpuB, B, sizeof(B), cudaMemcpyHostToDevice);

	auto startactual = std::chrono::steady_clock::now();
	//Blocks and threads
	int THREADS = 1024;
	int BLOCKS = (N + THREADS - 1)/THREADS;
	//Calling the function
	ArrayAdd <<<BLOCKS,THREADS >>> (gpuA, gpuB, gpuC, N);
	//cudaDeviceSynchronize();
	auto endactual = std::chrono::steady_clock::now();

	//Copying the sum back to main memory
	cudaMemcpy(C, gpuC, sizeof(C), cudaMemcpyDeviceToHost);

	//Taking the end time
	auto end = std::chrono::steady_clock::now();
	//Measuring time difference
	double time_elapsed_ns = double(std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count());
	double actual_time_elapsed_ns = double(std::chrono::duration_cast<std::chrono::nanoseconds>(endactual - startactual).count());
	std::cout<<"total time elapsed: " << time_elapsed_ns / 1e6 << std::endl;
	std::cout <<"actual time elapsed: " << actual_time_elapsed_ns / 1e6 << std::endl;

	return 0;
}