//
// Created by augus on 17.02.2026.
//

#ifndef FRACTALVIEVER_MAINGAME_H
#define FRACTALVIEVER_MAINGAME_H
#pragma once
#include "IGame.h"
#include "Logger.h"
#include "CUDA/cudaManager.cuh"

#endif //FRACTALVIEVER_MAINGAME_H



class MainGame: public Engine::IGame{
public:
    explicit MainGame(Engine::EngineContext& context, Engine::GameContainer& container) : Engine::IGame(
            context, container), cManager(context.window->getm_Width(), context.window->getm_Height()) {
        w_Height = context.window->getm_Height();
        w_Width = context.window->getm_Width();
        frameBuffer.resize(w_Width * w_Height);
        resetCamera(activeCam);
        resetCamera(juliaCam);
        resetCamera(mandelbrotCam);

    }

    void update(float dt) override;
    void render() override;
    void onInit() override;
    void onExit() override;
    void handleInput(float dt);


private:
    int w_Width, w_Height;
    cudaManager cManager;
    std::vector<uint32_t> frameBuffer;



    cameraData activeCam;
    cameraData juliaCam;
    cameraData mandelbrotCam;

    enum class setMode {
        JULIA,
        MANDELBROT
    };
    setMode mode = setMode::MANDELBROT;

    JuliaSetSeedPos juliaSetStartPos;

    void resetCamera(cameraData& camera) {
        camera.offX = 0;
        camera.offY = 0;
        camera.zoom = 1;
    }
    void switchMode() {
        if (mode == setMode::JULIA) {
            mode = setMode::MANDELBROT;
            activeCam = mandelbrotCam;
        }else {
            mode = setMode::JULIA;
            resetCamera(juliaCam);
            mandelbrotCam = activeCam;
            activeCam = juliaCam;
        }
    }
    void debugCamOutput(cameraData cam) {
        LOG_INFO("X: " << cam.offX << " Y: " << cam.offY << " zoom: " << cam.zoom);
    }
};