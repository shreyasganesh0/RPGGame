# 2D RPG 

## About

This is my attempt at creating a 2D rpg from scratch without external libraries

## Getting Started
To run a debug version of the appliction
```
./remake.sh
```

OR to build it yourself

Create a build directory
```
mkdir build
cd build
```
1. Depending on the build version required run the following command in the "build" directory
```
cmake DCMAKE_BUILD_TYPE=Debug ..

OR

cmake DCMAKE_BUILD_TYPE=Release ..
```
2. Run the following command with config flag set to the build type specified

```
cmake --build . --config Debug

OR

cmake --build . --config Debug
```

3. The binary/executable will be present in the ./build/bin directory of the project. 
```
open bin/RPGGame.app
```

## Currently supports macOS 
>> Tested on macOS 15.1.1 (24B91)