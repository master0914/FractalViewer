//
// Created by augus on 17.02.2026.
//

#include "MainGame.h"

#include "Logger.h"

void MainGame::update(float dt) {
    handleInput(dt);
    switch (mode) {
        case setMode::MANDELBROT:
            cManager.computeMandelBrotBuffer(frameBuffer, activeCam);
            break;
        case setMode::JULIA:
            cManager.computeJuliaSetBuffer(frameBuffer, activeCam, juliaSetStartPos);
            break;
        default:
            LOG_ERROR("Setmode not known");
    }
}
void MainGame::render() {
    m_context.window->swapBuffers(frameBuffer);
    m_context.window->Present();
}
void MainGame::onInit() {
    cManager.cudaInit();
}
void MainGame::onExit() {
}
void MainGame::handleInput(float dt) {
    double scroll = m_context.input->getMouseScroll();
    if (scroll != 0) {
        // LOG_INFO("scrolled " << scroll);
        if (m_context.input->isKeyPressed(Engine::KeyCode::KEY_SHIFT)) {
            activeCam.zoom *= (scroll > 0)? 1.9:0.5;
        }else {
            activeCam.zoom *= (scroll > 0)? 1.1:0.9;
        }
    }

    double movespeed = 0.1 / activeCam.zoom;

    if (m_context.input->isKeyPressed(Engine::KeyCode::KEY_W)) {
        // LOG_INFO("moved W");
        activeCam.offY -= movespeed;
    }
    if (m_context.input->isKeyPressed(Engine::KeyCode::KEY_S)) {
        // LOG_INFO("moved S");
        activeCam.offY += movespeed;
    }
    if (m_context.input->isKeyPressed(Engine::KeyCode::KEY_D)) {
        // LOG_INFO("moved D");
        activeCam.offX += movespeed;
    }
    if (m_context.input->isKeyPressed(Engine::KeyCode::KEY_A)) {
        // LOG_INFO("moved A");
        activeCam.offX -= movespeed;
    }

    if (m_context.input->isMouseButtonJustPressed(Engine::KeyCode::MOUSE_LEFT)) {
        if (mode == setMode::MANDELBROT) {
            Engine::vec2 pos = m_context.input->getMousePosition();
            LOG_INFO("CLICKPOS     X:" << pos.x << ", Y:" << pos.y);
            juliaSetStartPos.x = (static_cast<double>(pos.x) / w_Width - 0.5) * (3.0 / activeCam.zoom) + activeCam.offX;
            juliaSetStartPos.y = (static_cast<double>(pos.y) / w_Height - 0.5) * (3.0 / activeCam.zoom) + activeCam.offY;
            LOG_INFO("JULIASEED:   X: " << juliaSetStartPos.x << "   Y: " << juliaSetStartPos.y);
        }
        switchMode();
    }
}