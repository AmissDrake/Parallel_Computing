#include <iostream>

int main(){

    //Number of dice
    int N = 1;

    //Number of runs
    int runs = 1024 * 1024;

    
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

    std::cout<< "The odds are "<< odds << std::endl;
    return 0;
}