#include <iostream>

#include "GameContainer.h"
#include "MainGame.h"

int main() {
    Engine::GameContainer gc{800,800,"FractalViewer"};
    gc.createGame<MainGame>();
    gc.run();
    return 0;
}