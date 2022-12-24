project(extension)

set(EXTENSION_SOURCES
    main.mm
    filterdataprovider.mm
)

add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${EXTENSION_SOURCES})

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    "-framework Foundation"
    "-framework NetworkExtension"
    "-lbsm"
)

configure_file("Info.plist.in.in" "${CMAKE_CURRENT_BINARY_DIR}/Info.plist.in" @ONLY)

set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "${EXTENSION_ID}"
    BUNDLE_EXTENSION "systemextension"
    MACOSX_BUNDLE_BUNDLE_NAME "${EXTENSION_ID}"
    MACOSX_BUNDLE_GUI_IDENTIFIER "${EXTENSION_ID}"
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/Info.plist.in"
)

install(TARGETS ${PROJECT_NAME} BUNDLE DESTINATION "${EXTENSIONS_PATH}")

if(USE_APPLE_DEV_SIGN)
    install(FILES ${CMAKE_CURRENT_LIST_DIR}/Extension-dev.provisionprofile
        DESTINATION "${EXTENSIONS_PATH}/${EXTENSION_ID}.systemextension/Contents"
        RENAME embedded.provisionprofile
    )
else()
    install(FILES ${CMAKE_CURRENT_LIST_DIR}/Extension.provisionprofile
        DESTINATION "${EXTENSIONS_PATH}/${EXTENSION_ID}.systemextension/Contents"
        RENAME embedded.provisionprofile
    )
endif()
