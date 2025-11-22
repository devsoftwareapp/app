cmake_minimum_required(VERSION 3.18.1)

project("pdf_renderer")

# MuPDF source files
set(MUPDF_SRC
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/archive.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/buffer.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/color.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/context.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/crypt.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/document.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/geometry.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/glyph.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/hash.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/image.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/output.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/pixmap.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/stream.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/string.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/stext.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/store.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/tree.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz/util.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-annot.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-cmap.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-crypt.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-device.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-document.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-font.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-form.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-image.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-object.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-page.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-parse.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-pattern.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-resource.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-shade.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-stream.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-type3.c
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf/pdf-xref.c
)

add_library(
    mupdf
    STATIC
    ${MUPDF_SRC}
)

target_include_directories(mupdf PRIVATE
    ${CMAKE_SOURCE_DIR}/mupdf/include
    ${CMAKE_SOURCE_DIR}/mupdf/source/fitz
    ${CMAKE_SOURCE_DIR}/mupdf/source/pdf
)

# Main native library - BU .so'yu oluşturacak
add_library(
    pdf_renderer
    SHARED
    pdf_renderer.cpp
)

target_include_directories(pdf_renderer PRIVATE
    ${CMAKE_SOURCE_DIR}/mupdf/include
)

target_link_libraries(
    pdf_renderer
    android
    log
    mupdf
    jnigraphics
)

find_library(
    log-lib
    log
)
