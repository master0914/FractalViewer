//
// Created by augus on 17.02.2026.
//
#include <cuda_runtime.h>
#include <cstdio>
#include "cudaManager.cuh"
#include "Logger.h"

__device__ uint32_t HSVtoRGB(float hue, float s, float v) {
    // konvertiert hsv zu rgb              (hue, s, v liegen zw 0...1)
    // rgb wird in 0xffyyyyyy ausgegeben
    // in mandelbrot ist nur h wichtig s und v bleiben 1

    // aus formel von wikipedia

    float h = hue * 6.0f;
    int i = (int)h;
    float f = h - i;
    float p = v * (1.0f - s);
    float q = v * (1.0f - s * f);
    float t = v * (1.0f - s * (1.0f - f));

    float rf = 0;
    float gf = 0;
    float bf = 0;

    switch (i % 6) {
        case 0:
            rf = v;gf = t;bf = p;break;
        case 1:
            rf = q;gf = v;bf = p;break;
        case 2:
            rf = p;gf = v;bf = t;break;
        case 3:
            rf = p;gf = q;bf = v;break;
        case 4:
            rf = t;gf = p;bf = v;break;
        case 5:
            rf = v;gf = p;bf = q;break;
        default:
            break;
    }


    return 0xFF000000 | ((uint8_t)(rf * 255) << 16) | ((uint8_t)(gf * 255) << 8) | (uint8_t)(bf * 255);
}
__global__ void mandelbrotKernel(uint32_t* buffer, int w, int h, double offX, double offY, double zoom) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < w && y < h) {
        double cx = ((double)x / w - 0.5) * (3.0 / zoom) + offX;
        double cy = ((double)y / h - 0.5) * (3.0 / zoom) + offY;
        double zx = 0;
        double zy = 0;
        int i = 0;
        int maxi = 256;
        // bedingung dass z^2 + y^2 < r^2 sein müssen  (kreis kleiner 2), da sie sonst unweigerlich entarten
        while (i < maxi && (zx * zx + zy * zy) < 4.1) {
            double nzx = zx * zx - zy * zy + cx;
            double nzy = 2 * zx * zy + cy;

            zx = nzx;
            zy = nzy;

            i++;
        }

        if (i == maxi) {
            buffer[x + y * w] = 0xFF000000;
        }
        else {
            buffer[x + y * w] = HSVtoRGB((float)i / 256.0f,1.0f,1.0f);
        }

    }
}
__global__ void juliaSetKernel(uint32_t* buffer, int w, int h, double offX, double offY, double zoom, double seedX, double seedY) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < w && y < h) {
        double cx = seedX;
        double cy = seedY;
        double zx = ((double)x / w - 0.5) * (3.0 / zoom) + offX;
        double zy = ((double)y / h - 0.5) * (3.0 / zoom) + offY;;
        int i = 0;
        int maxi = 256;
        // bedingung dass z^2 + y^2 < r^2 sein müssen  (kreis kleiner 2), da sie sonst unweigerlich entarten
        while (i < maxi && (zx * zx + zy * zy) < 4.1) {
            double nzx = zx * zx - zy * zy + cx;
            double nzy = 2 * zx * zy + cy;

            zx = nzx;
            zy = nzy;

            i++;
        }

        if (i == maxi) {
            buffer[x + y * w] = 0xFF000000;
        }
        else {
            buffer[x + y * w] = HSVtoRGB((float)i / 256.0f,1.0f,1.0f);
        }

    }
}



void cudaManager::cudaInit() {
    cudaError_t err = cudaMalloc(&img_buffer, sizeof(uint32_t) * width * height);
    if (err != cudaSuccess) {
        printf("CUDA Malloc Error: %s\n", cudaGetErrorString(err));
    }

}
cudaManager::~cudaManager() {
    cudaFree(img_buffer);
}
void cudaManager::computeMandelBrotBuffer(std::vector<uint32_t>& outBuffer, cameraData& cam) {
    if (outBuffer.size() != width * height) {
        outBuffer.resize(width * height);
        LOG_WARN("OutBuffer has different size than w*h of cManager");
    }

    // kernel configuratio
    dim3 block(16,16);                          // ein block mit 256 threds                 800x800 = 640000
    dim3 grid((width+15)/16, (height+15)/16);    // grid ist w+15 damit man nie zu wenig grids hat(rundung)

    // kernel aufrufen (schreib die daten in img_buffer)
    mandelbrotKernel<<<grid,block>>>(img_buffer, width, height, cam.offX, cam.offY, cam.zoom);

    cudaDeviceSynchronize();

    cudaMemcpy(outBuffer.data(), img_buffer, sizeof(uint32_t) * width * height,cudaMemcpyDeviceToHost);   // daten auf den CPU copy
}
void cudaManager::computeJuliaSetBuffer(std::vector<uint32_t>& outBuffer, cameraData& cam, JuliaSetSeedPos jSSP) {
    if (outBuffer.size() != width * height) {
        outBuffer.resize(width * height);
        LOG_WARN("OutBuffer has different size than w*h of cManager");
    }

    // kernel configuratio
    dim3 block(16,16);                          // ein block mit 256 threds                 800x800 = 640000
    dim3 grid((width+15)/16, (height+15)/16);    // grid ist w+15 damit man nie zu wenig grids hat(rundung)

    // kernel aufrufen (schreib die daten in img_buffer)
    juliaSetKernel<<<grid,block>>>(img_buffer, width, height, cam.offX, cam.offY, cam.zoom, jSSP.x, jSSP.y);

    cudaDeviceSynchronize();

    cudaMemcpy(outBuffer.data(), img_buffer, sizeof(uint32_t) * width * height,cudaMemcpyDeviceToHost);   // daten auf den CPU copy
}

