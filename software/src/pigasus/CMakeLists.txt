
set (PIGASUS_INCLUDES
    pigasus.h
)

add_library ( pigasus OBJECT
    ${PIGASUS_INCLUDES}
    pigasus.cc
)

install(FILES ${PIGASUS_INCLUDES}
    DESTINATION "${INCLUDE_INSTALL_PATH}/pigasus"
)

add_subdirectory ( pcie )
