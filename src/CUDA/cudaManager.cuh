//
// Created by augus on 17.02.2026.
//

#ifndef FRACTALVIEVER_CUDAMANAGER_CUH
#define FRACTALVIEVER_CUDAMANAGER_CUH
#include <vector>
#pragma once


#endif //FRACTALVIEVER_CUDAMANAGER_CUH
struct cameraData {
    double offX;
    double offY;
    double zoom;
};
struct JuliaSetSeedPos {
    double x;
    double y;
};

class cudaManager {
    public:
    cudaManager(int width, int height): width(width), height(height) {};
    ~cudaManager();
    void cudaInit();
    void computeMandelBrotBuffer(std::vector<uint32_t>& outBuffer, cameraData& cam);
    void computeJuliaSetBuffer(std::vector<uint32_t>& outBuffer, cameraData& cam, JuliaSetSeedPos jSSP);
    private:
    uint32_t* img_buffer;
    int width;
    int height;
};