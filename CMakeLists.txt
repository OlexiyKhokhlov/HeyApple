cmake_minimum_required(VERSION 3.21.4 FATAL_ERROR)

project(HeyApple
    VERSION "1.0.0"
    HOMEPAGE_URL "https://www.github.com/OlexiyKhokhlov/HeyApple"
    LANGUAGES CXX C
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)

if(NOT DEFINED CMAKE_CXX_FLAGS_INIT)
    set(CMAKE_CXX_FLAGS_INIT)
endif()

set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -Wall -Wextra -pedantic -Werror")
enable_language(CXX)

if(NOT CMAKE_OSX_DEPLOYMENT_TARGET)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15.0" CACHE STRING "Minimum OS X version to target for deployment (at runtime)." FORCE)
endif()
message(STATUS "Use CMAKE_OSX_DEPLOYMENT_TARGET: " ${CMAKE_OSX_DEPLOYMENT_TARGET})

option(USE_APPLE_DEV_SIGN "Set ON for dev signing" OFF)

# The next variables must be given from your apple developer account!
# Uncomment it and fill with appropriate data from the your own  Apple developer account
#set(GROUP_ID "A123XYZ09F")
#set(MAIN_APP_ID "com.CompanyName.HeyApple")
#set(EXTENSION_ID "com.CompanyName.HeyApple.Extension")
#set(SIGN_PREFIX "com.CompanyName.")
#set(DEV_CERT_NAME "FFFAA23497836BC9B0%A010367BABABCAFE00275")
#set(REL_CERT_NAME "2A0778DFA9A78000C7B1237FC6B8B10A4455FF07")

if(NOT DEFINED GROUP_ID OR )

set(APPLICATION_GUI_NAME "HeyApple")
set(MAIN_BUNDLE_NAME "HeyApple")
set(EXTENSIONS_PATH "${MAIN_BUNDLE_NAME}.app/Contents/Library/SystemExtensions")

add_subdirectory(app)

# Extension subdir must be after app.
# Since it should be installed inside main app bundle
add_subdirectory(extension)

# Prepare entitlement files
if(USE_APPLE_DEV_SIGN)
    set(CERT_NAME "${DEV_CERT_NAME}")
    set(APPLE_PROVIDER_TYPE "content-filter-provider")
else()
    set(CERT_NAME "${REL_CERT_NAME}")
    set(APPLE_PROVIDER_TYPE "content-filter-provider-systemextension")
endif()

configure_file("sign/App.entitlements.in" "${CMAKE_CURRENT_BINARY_DIR}/App.entitlements" @ONLY)
configure_file("sign/Extension.entitlements.in" "${CMAKE_CURRENT_BINARY_DIR}/Extension.entitlements" @ONLY)

# Sign installed bundle. This install command must be last.
# "./mac_codesign <build dir> <install dir> <extension dir> <sign certificate name> <sign prefix>
install(CODE "execute_process(COMMAND \"${CMAKE_CURRENT_SOURCE_DIR}/sign/mac_codesign\" \
    \"${CMAKE_CURRENT_BINARY_DIR}\"  \
    \"${CMAKE_INSTALL_PREFIX}/${MAIN_BUNDLE_NAME}.app\" \
    \"${CMAKE_INSTALL_PREFIX}/${EXTENSIONS_PATH}/${EXTENSION_ID}.systemextension\" \
    \"${CERT_NAME}\" \
    \"${SIGN_PREFIX}\") ")

