cmake_minimum_required(VERSION 3.18.1)

project("pdf_renderer")

# GEÇİCİ: Sadece temel PDF renderer, MuPDF sonra eklenecek
add_library(
    pdf_renderer
    SHARED
    pdf_renderer.cpp
)

target_include_directories(pdf_renderer PRIVATE
    # MuPDF includes kaldırıldı
)

target_link_libraries(
    pdf_renderer
    android
    log
    jnigraphics
)

find_library(
    log-lib
    log
)
