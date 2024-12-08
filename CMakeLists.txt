cmake_minimum_required(VERSION 3.10)

# Set the project name and version
project(RPGGame
    VERSION 1.0
    DESCRIPTION "A C++ Game built with CMake"
    LANGUAGES CXX
)

# Set the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Define build types if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING
        "Choose the build type (Debug or Release)" FORCE)
endif()

# Enable debug symbols for memory inspection
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g")

# Set output directories for binaries and libraries
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Gather all .cpp source files
file(GLOB_RECURSE SOURCE_FILES ${CMAKE_SOURCE_DIR}/src/*.cpp)

# Create the executable target
add_executable(${PROJECT_NAME} ${SOURCE_FILES})

# Include directories for headers
target_include_directories(${PROJECT_NAME}
    PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

# Add any compiler flags you need (example: warnings, etc.)
if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /W4)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -pedantic)
endif()

# For debugging:
# cmake -DCMAKE_BUILD_TYPE=Debug ..
# For release:
# cmake -DCMAKE_BUILD_TYPE=Release ..

# After configuring with cmake, build:
# make         # On Linux/macOS
# or
# cmake --build . --config Debug  # On multi-config generators like Xcode
