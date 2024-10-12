# Parallel computing using Nvidia CUDA
## Assignment submission for WEC systems recruitment by T Ranjit
--- 
Index:-
1. Setup
2. Task_1
..2.1 Task in serial
..2.2 Task in parallel
..2.3 Performance comparisons
3. Task_2
..3.1 Task in serial
..3.2 Task in parallel
4. Task_3
..4.1 Task in serial
..4.2 Task in parallel
..4.3 Performance comparisons
---
### 1. Setup
Note: The code has been tested in windows 11 only. I am not sure if it'll run without any issues on linux.

You can follow this installation guide by Nvidia to get your CUDA toolkit is setup.

https://developer.nvidia.com/cuda-downloads?target_os=Windows&target_arch=x86_64&target_version=11&target_type=exe_local
Follow section 2.2 from the following document:
https://docs.nvidia.com/cuda/cuda-quick-start-guide/index.html


Once your CUDA toolkit is installed, start a new project in visual studio, and select CUDA template. you'll be presented with a file with kernel.cu file with boilerplate code. Ctrl+A, delete it all, and paste the code from the kernel.cu files on GitHub to run that particular task. for example, if you want to run Task_1, go to the GitHub folder for Task_1 and copy paste the code from Task_1/Kernel.cu into your local kernel.cu that's open in vs. once that's done, you can just hit run to compile the program.

### 2. Task_1
Write a parallel program to find the sum of all the elements in a given array.
#### 2.1. Serial implementation:-
This task in serial is pretty simple. just take 2 arrays of the same size