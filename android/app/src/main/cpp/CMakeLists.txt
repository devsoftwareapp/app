cmake_minimum_required(VERSION 3.18.1)

project("pdf_renderer")

# MuPDF source files
set(MUPDF_SRC
    mupdf/source/fitz/archive.c
    mupdf/source/fitz/buffer.c
    mupdf/source/fitz/color.c
    mupdf/source/fitz/context.c
    mupdf/source/fitz/crypt.c
    mupdf/source/fitz/document.c
    mupdf/source/fitz/geometry.c
    mupdf/source/fitz/glyph.c
    mupdf/source/fitz/hash.c
    mupdf/source/fitz/image.c
    mupdf/source/fitz/output.c
    mupdf/source/fitz/pixmap.c
    mupdf/source/fitz/stream.c
    mupdf/source/fitz/string.c
    mupdf/source/fitz/stext.c
    mupdf/source/fitz/store.c
    mupdf/source/fitz/tree.c
    mupdf/source/fitz/util.c
    mupdf/source/pdf/pdf-annot.c
    mupdf/source/pdf/pdf-cmap.c
    mupdf/source/pdf/pdf-crypt.c
    mupdf/source/pdf/pdf-device.c
    mupdf/source/pdf/pdf-document.c
    mupdf/source/pdf/pdf-font.c
    mupdf/source/pdf/pdf-form.c
    mupdf/source/pdf/pdf-image.c
    mupdf/source/pdf/pdf-object.c
    mupdf/source/pdf/pdf-page.c
    mupdf/source/pdf/pdf-parse.c
    mupdf/source/pdf/pdf-pattern.c
    mupdf/source/pdf/pdf-resource.c
    mupdf/source/pdf/pdf-shade.c
    mupdf/source/pdf/pdf-stream.c
    mupdf/source/pdf/pdf-type3.c
    mupdf/source/pdf/pdf-xref.c
)

add_library(
    mupdf
    STATIC
    ${MUPDF_SRC}
)

target_include_directories(mupdf PRIVATE
    mupdf/include
    mupdf/source/fitz
    mupdf/source/pdf
)

# Main native library - BU .so'yu oluşturacak
add_library(
    pdf_renderer
    SHARED
    pdf_renderer.cpp
)

target_include_directories(pdf_renderer PRIVATE
    mupdf/include
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
