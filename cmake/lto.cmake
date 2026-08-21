string(TOUPPER "${CMAKE_BUILD_TYPE}" _lnav_build_type)
set(_lnav_lto_default ON)
if(_lnav_build_type STREQUAL "DEBUG"
   OR NOT CMAKE_C_COMPILER_ID MATCHES "^(Apple)?Clang$"
   OR NOT CMAKE_CXX_COMPILER_ID MATCHES "^(Apple)?Clang$")
  set(_lnav_lto_default OFF)
endif()
option(lnav_ENABLE_LTO "Enable ThinLTO" ${_lnav_lto_default})
unset(_lnav_build_type)
unset(_lnav_lto_default)

if(lnav_ENABLE_LTO)
  if(NOT CMAKE_C_COMPILER_ID MATCHES "^(Apple)?Clang$"
     OR NOT CMAKE_CXX_COMPILER_ID MATCHES "^(Apple)?Clang$")
    message(FATAL_ERROR "ThinLTO requires Clang or AppleClang")
  endif()

  include(CheckIPOSupported)
  check_ipo_supported(RESULT lnav_lto_supported
                      OUTPUT lnav_lto_error
                      LANGUAGES C CXX)
  if(NOT lnav_lto_supported)
    message(FATAL_ERROR "ThinLTO is not supported: ${lnav_lto_error}")
  endif()

  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
  message(STATUS "Link-time optimization enabled: thin")
endif()
