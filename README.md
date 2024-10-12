# Parallel computing using Nvidia CUDA
## Assignment submission for WEC systems recruitment by T Ranjit
--- 
Index:-
1. Setup
2. Task_1  
    2.1 Task in serial <br>
    2.2 Task in parallel <br>
    2.3 Performance comparisons <br>
4. Task_2
    3.1 Task in serial <br>
    3.2 Task in parallel <br>
5. Task_3
    4.1 Task in serial <br>
    4.2 Task in parallel <br>
    4.3 Performance comparisons <br>
---
### 1. Setup
Note: The code has been tested in windows 11 only. I am not sure if it'll run without any issues on linux.

You can follow this installation guide by Nvidia to get your CUDA toolkit is setup.

https://developer.nvidia.com/cuda-downloads?target_os=Windows&target_arch=x86_64&target_version=11&target_type=exe_local

Follow section 2.2 from the following document:
https://docs.nvidia.com/cuda/cuda-quick-start-guide/index.html


Once your CUDA toolkit is installed, start a new project in visual studio, and select CUDA template. you'll be presented with a file with kernel.cu file with boilerplate code. Ctrl+A, delete it all, and paste the code from the kernel.cu files on GitHub to run that particular task. for example, if you want to run Task_1, go to the GitHub folder for Task_1 and copy paste the code from Task_1/Kernel.cu into your local kernel.cu that's open in vs. 
once that's done, you can just hit run to compile the program.

### 2. Task_1
Write a parallel program to find the sum of all the elements in a given array.
#### 2.1. Serial implementation:-
This task in serial is pretty simple. just take 2 arrays of the same size and initialize them to some value less than hundred, and add them.
#### 2.2. Parallel implementation:-
For the parallel version of this task, I initialized 3 arrays on the GPU, one empty and the other two having values equal to their index. Then i assigned each thread to adding the values at its index. The program runs fine, but due to the way I've defined the arrays, any array size over 2^15 gives a stack overflow error. I didnt know CPP when i wrote this task, and if i had to do it agian, id fix it, but i didnt have the time to go back and fix it. 
#### 2.3. Performance comparision:-
For the values of array size like 2^15, the serial program is faster than the parallel one, because CUDA programs require copying the data to the gpu, and due to the relatively simple nature of the task, memory bandwidth, not computational speed, is the bottleneck here. Hence, for this task, i have included the values of time taken for the whole parallel program, and the time taken minus the memory allocation part.

| Array size | Serial time (ms) | Parallel net time (ms) | Parallel time without bandwidth bottleneck (ms) |
|---|---|---|---|
|2^1|0.004300|1609.94|0.5857|
|2^3|0.002200|1029.4|0.5421|
|2^7|0.007600|155.454|0.5416|
|2^11|0.160900|1621.57|0.6242|
|2^15|1.627700|1709.51|0.659|

You can see how the parallel compute starts being faster at 2^15. Unfortunately my program crashes for values more than that, but for huge values like 2^25 or so, even the parallel net time would be shorter than the serial time.

### 3. Task_2
Given a graph, write a parallel program to find the number of connected components in the graph, and find which component a given vertex belongs to.
This task is incomplete
#### 3.1. Serial implementation:-
DFS on the unvisited nodes of the graph would give you the number of components. The number of times DFS is called at the first recursive level is the number of components, and the nodes found in each DFS traversal are the elements of the component.
#### 3.2. Parallel implementation:-
For the parallel case, implementation would require feeding in each row of the adjacency matrix to one thread. Now each thread will perform the serial algorithm on the part of the graph it can see. Then we need to use union find/join to combine the components found by individual threads. However, me being new to DSA (I learnt C and CPP for this assignment, never used them before), wasnt able to understand how to implement union find in the kernel. This is why i could not finish the parallel implementation of this task. 

### 4. Task_3
Write a parallel program to run a monte carlo simulation to find the probability of getting the total 3n when n 6-sided dice are rolled simultaneously. Make sure that your PRNG is working as expected in the parallel algorithm.
#### 4.1 Serial implementation-
For this case, i just rolled a random number 1-6 an arbritrarily large number of times, and then counted up the number of times you get 3*N. Once I have that, I divided it by the total number of runs to get the chance of getting that sum.
#### 4.2 Parallel implementation-
After assigning a cache array to each block, each thread rolls a random number 3 times and saves its sum total to its index in the cache. Then I perform reduction on the cache to convert it into an array of size 1, and then finally I add the value of cache[0] across all the blocks using atomicAdd.
The values I'm  getting from the simulation are a bit off from the actual probabilities. I do think my PRNG is working fine, as I used a different seed for the PRNG and I still got similar results. There might be some logical error in the code, but you can see from the next section that running it in parallel is much faster than running it in serial.
While performance testing, I did encounter an error when the sample size is 2^30, however, I didnt have the time to fix it.
#### 4.3 Performance comparision:-
Number of dice = 1

| Sample size | Serial time (ms) | Parallel simulation time (ms) |
|---|---|---|
|2^10|0.0618|6.0239|
|2^15|1.8051|6.4478|
|2^20|22.1784|6.7859|
|2^25|726.391|51.1241|
|2^30|21592|-|

Number of dice = 3

| Sample size | Serial time (ms) | Parallel simulation time (ms) |
|---|---|---|
|2^10|0.2017|6.0266|
|2^15|1.9766|6.384|
|2^20|51.4456|5.9969|
|2^25|1897.94|50.9596|
|2^30|Forever(t>1 minute)|-|
