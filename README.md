# SaferMatlabSemaphore
A slightly safer wrapper for Win32-API Semaphore for Matlab.
Allows to limit number of processes, that are allowed to enter a specific session of code simultaneously. 

![](https://www.mathworks.com/responsive_image/150/0/0/0/0/cache/matlabcentral/mlc-downloads/downloads/submissions/67848/versions/1/screenshot.png)

## Main features: 
The code is based on https://www.mathworks.com/matlabcentral/fileexchange/45504-semaphore-posix-and-windows by Andrew Smart.

The main changes in this version are: 
* Allows to specify wait timeout 
* Added a Matlab wrapper that automatically creates unique identifiers 
* removed POSIX version

## Quickstart: 
1. Run "[semaphore_build_mex.m](semaphore_build_mex.m)" to build the mex.
The output should look like this:
```Matlab
>> semaphore_build_mex
Building with 'Microsoft Visual C++ 2013 Professional (C)'.
MEX completed successfully.
```
2. Run "[demo_semaphore.m](demo_semaphore.m)" to take a look on how it works.
The output should look like this:
```Matlab
>> demo_semaphore
i=1 	 time=0000.085 	 p1 
i=1 	 time=0005.085 	 p2 - before wait 
i=8 	 time=0000.086 	 p1 
i=8 	 time=0005.087 	 p2 - before wait 
i=2 	 time=0000.078 	 p1 
i=2 	 time=0005.079 	 p2 - before wait 
i=7 	 time=0000.084 	 p1 
i=7 	 time=0005.085 	 p2 - before wait 
i=6 	 time=0000.077 	 p1 
i=6 	 time=0005.078 	 p2 - before wait 
i=3 	 time=0000.085 	 p1 
i=3 	 time=0005.085 	 p2 - before wait 
i=5 	 time=0000.077 	 p1 
i=5 	 time=0005.078 	 p2 - before wait 
i=4 	 time=0000.077 	 p1 
i=4 	 time=0005.078 	 p2 - before wait 
i=2 	 time=0005.093 	 p3 - token granted 
i=2 	 time=0006.181 	 p4 - token released 
i=6 	 time=0005.092 	 p3 - token granted 
i=6 	 time=0006.194 	 p4 - token released 
i=5 	 time=0006.194 	 p3 - token granted 
i=4 	 time=0006.182 	 p3 - token granted 
i=1 	 time=0007.269 	 p3 - token granted 
i=7 	 time=0007.260 	 p3 - token granted 
i=5 	 time=0007.258 	 p4 - token released 
i=4 	 time=0007.268 	 p4 - token released 
i=1 	 time=0008.360 	 p4 - token released 
i=8 	 time=0008.355 	 p3 - token granted 
i=7 	 time=0008.354 	 p4 - token released 
i=3 	 time=0008.361 	 p3 - token granted 
i=8 	 time=0009.448 	 p4 - token released 
i=3 	 time=0009.449 	 p4 - token released 
i=2 	 time=0011.182 	 p5 - finished 
i=6 	 time=0011.195 	 p5 - finished 
i=5 	 time=0012.259 	 p5 - finished 
i=4 	 time=0012.269 	 p5 - finished 
i=1 	 time=0013.361 	 p5 - finished 
i=7 	 time=0013.355 	 p5 - finished 
i=8 	 time=0014.449 	 p5 - finished 
i=3 	 time=0014.450 	 p5 - finished 
```
