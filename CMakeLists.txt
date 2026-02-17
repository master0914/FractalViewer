cmake_minimum_required(VERSION 4.0)
project(FractalViever LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES "75")
#set(CMAKE_CUDA_COMPILER "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v13.1/bin/nvcc.exe")


include_directories("C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v13.1/include")

add_subdirectory(lib/3DEngine "${CMAKE_BINARY_DIR}3DEngine")

add_executable(FractalViever src/main.cpp
        src/MainGame.h
        src/CUDA/cudaManager.cu
        src/CUDA/cudaManager.cuh
        src/MainGame.cpp)

set_source_files_properties(src/CUDA/cudaManager.cu PROPERTIES LANGUAGE CUDA)

target_link_directories(FractalViever PRIVATE
        "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v13.1/lib/x64"
)
target_include_directories(FractalViever PRIVATE
        ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}
        "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v13.1/include"
)
target_link_libraries(FractalViever 3DEngineLib cudart.lib)

message(STATUS "CUDA Compiler: ${CMAKE_CUDA_COMPILER}")
message(STATUS "CUDA Flags: ${CMAKE_CUDA_FLAGS}")
message(STATUS "CUDA Compiler ID: ${CMAKE_CUDA_COMPILER_ID}")

# Sollte "NVIDIA" ausgeben
if(NOT CMAKE_CUDA_COMPILER_ID STREQUAL "NVIDIA")
    message(WARNING "CUDA Compiler ID ist nicht NVIDIA! Ist: ${CMAKE_CUDA_COMPILER_ID}")
endif()