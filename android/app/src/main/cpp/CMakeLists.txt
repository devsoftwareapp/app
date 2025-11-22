cmake_minimum_required(VERSION 3.18.1)
project("pdf_renderer")

# Native library oluştur
add_library(
    pdf_renderer
    SHARED
    pdf_renderer.cpp
)

# Log kütüphanesini bağla
find_library(
    log-lib
    log
)

target_link_libraries(
    pdf_renderer
    ${log-lib}
)
