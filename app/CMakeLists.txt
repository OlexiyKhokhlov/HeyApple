
set(MAIN_SOURCES
    main.cpp
    extensionmanager.h
    extensionmanager.mm
)

add_executable(main MACOSX_BUNDLE ${MAIN_SOURCES})
target_link_libraries(main
    PRIVATE
    "-framework Foundation"
    "-framework SystemExtensions"
    "-framework NetworkExtension"
)

configure_file("Info.plist.in.in" "${CMAKE_CURRENT_BINARY_DIR}/Info.plist.in" @ONLY)

target_compile_definitions(main PRIVATE -D "EXTENSION_ID=\"${EXTENSION_ID}\"")

set_target_properties(main PROPERTIES
    OUTPUT_NAME ${MAIN_BUNDLE_NAME}
    MACOSX_BUNDLE_BUNDLE_NAME ${MAIN_BUNDLE_NAME}
    MACOSX_BUNDLE_GUI_IDENTIFIER "${MAIN_ID}"
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/Info.plist.in"
)

install(TARGETS "main" BUNDLE DESTINATION  ".")
if (USE_APPLE_DEV_SIGN)
    install(FILES ${CMAKE_CURRENT_LIST_DIR}/MainApp-dev.provisionprofile
        DESTINATION "${MAIN_BUNDLE_NAME}.app/Contents"
        RENAME embedded.provisionprofile
    )
else()
    install(FILES ${CMAKE_CURRENT_LIST_DIR}/MainApp.provisionprofile
        DESTINATION "${MAIN_BUNDLE_NAME}.app/Contents"
        RENAME embedded.provisionprofile
    )
endif()
