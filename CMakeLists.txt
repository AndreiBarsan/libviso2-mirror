# project
cmake_minimum_required (VERSION 2.6)
project (libviso2)

# directories
set (Viso2_INCLUDE_DIRS src)

# include directory
include_directories("${Viso2_INCLUDE_DIRS}")

# use sse3 instruction set
set(CMAKE_CXX_FLAGS "-msse3")

# sources
set(LIBVISO2_SRC_FILES
    src/filter.cpp
    src/filter.cpp
    src/matcher.cpp
    src/matrix.cpp
    src/reconstruction.cpp
    src/triangle.cpp
    src/viso.cpp
    src/viso_mono.cpp
    src/viso_stereo.cpp
)

add_library(viso2 ${LIBVISO2_SRC_FILES})
set(Viso2_LIBS viso2)

# demo program (unused; requires png++)
#add_executable(viso2 ${LIBVISO2_SRC_FILES})
#target_link_libraries (viso2 png)

