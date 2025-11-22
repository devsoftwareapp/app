cmake_minimum_required(VERSION 3.18.1)

project("pdf_renderer")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# TÜM CPP DOSYALARINI EKLE
add_library(
    pdf_renderer
    SHARED
    pdf_renderer.cpp
    pdfium_wrapper.cpp
)

include_directories(src/main/cpp)

find_library(
    log-lib
    log
)

target_link_libraries(
    pdf_renderer
    android
    ${log-lib}
)
