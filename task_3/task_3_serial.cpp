#include <iostream>
#include <chrono>

int main(){

    //Number of dice
    int N = 1;

    //Number of runs
    int runs = 1<<15;

    //Taking start time
	auto start = std::chrono::steady_clock::now();

    int count = 0;
    srand(time(0));

    
    for(int i = 0; i<runs; i++){
        int dicecounter = 0;
        for(int j=0;j<N;j++){
            dicecounter = dicecounter + (std::rand()%6)+1;
        }
        if (dicecounter == 3*N){
            count += 1;
        }
    }

    float odds = float(count)/float(runs);

    //Taking the end time
	auto end = std::chrono::steady_clock::now();
    double time_elapsed_ns = double(std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count());

    std::cout<< "The odds are "<< odds << std::endl;
    std::cout<< "Time taken to run: " <<time_elapsed_ns/1e6 << std::endl;
    return 0;
}