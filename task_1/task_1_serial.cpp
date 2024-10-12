#include <stdio.h>
#include <cstdlib>
#include <chrono>

void ArrayAdd (int* A, int* B, int* C, int N){
    int i = 0;
    while(i<N){
        C[i] = A[i] + B[i];
        i++;
    }
}

void arrayinit(int* A, int N) {
	for (int i = 0; i < N; i++) {
		A[i] = rand() % 100;
	}
}

void printarray(int* A, int* B, int* C, int N){
    for (int i = 0; i < N; i++) {
		printf("%d + %d == %d\n", A[i],B[i],C[i]);
	}
}

int main(){

    //Taking start time
	auto start = std::chrono::steady_clock::now();

    const int N = 1 << 15; //Edit the array size here

	//Initializing arrays
	int A[N] = {};
	int B[N] = {};
	int C[N] = {};
	arrayinit(A, N);
	arrayinit(B, N);

    //Calling the function
    ArrayAdd(A,B,C,N);
    //printarray(A,B,C,N);

    //Taking the end time
	auto end = std::chrono::steady_clock::now();
	//Measuring time difference
	double time_elapsed_ns = double(std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count());
	printf("%lf", time_elapsed_ns/1e6);

    return 0;
}