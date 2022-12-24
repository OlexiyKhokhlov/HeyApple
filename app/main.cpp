#include <iostream>
#include <memory>

#include "extensionmanager.h"

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Need args: [install | uninstall | start | stop]" << std::endl;
        return 1;
    }

    // EXTENSION_ID is defined inside CmakeLists.txt
    // and will be given via compiler commandline key
    const auto* command = argv[1];
    const auto* extension_id = EXTENSION_ID;
    try {
        if (strcmp(command, "install") == 0) {
            auto extman = std::make_unique<ExtensionManager>(extension_id);
            extman->install();
        } else if (strcmp(command, "uninstall") == 0) {
            auto extman = std::make_unique<ExtensionManager>(extension_id);
            extman->uninstall();
        } else if (strcmp(command, "start") == 0) {
            auto extman = std::make_unique<ExtensionManager>(extension_id);
            extman->start();
        } else if (strcmp(command, "stop") == 0) {
            auto extman = std::make_unique<ExtensionManager>(extension_id);
            extman->stop();
        } else {
            std::cerr << "Unknown command" << std::endl;
            return 1;
        }
    } catch(const std::exception& ex) {
        std::cerr << ex.what() << std::endl;
    }

    return 0;
}
