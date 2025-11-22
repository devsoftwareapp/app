cmake_minimum_required(VERSION 3.18.1)

# ÖNEMLİ: Project ismi
project("pdf_renderer")

# Derleyici ayarları
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Native library oluştur
add_library(
    pdf_renderer
    SHARED
    pdf_renderer.cpp
)

# Include dizinleri
include_directories(src/main/cpp)

# Log kütüphanesini bağla
find_library(
    log-lib
    log
)

target_link_libraries(
    pdf_renderer
    android
    ${log-lib}
)
