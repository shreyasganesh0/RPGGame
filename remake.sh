#!/bin/zsh
# remake the debug build directory

echo "Started remake"
rm -rf build-debug

mkdir build-debug

cd build-debug

cmake DCMAKE_BUILD_TYPE=Debug ..

cmake --build . --config Debug

echo "Finished remake"

echo "Running the Game"

open bin/RPGGame.app