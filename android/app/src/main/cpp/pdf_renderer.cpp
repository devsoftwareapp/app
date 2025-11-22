#include <jni.h>
#include <android/bitmap.h>
#include <android/log.h>

extern "C" {
    #include "fitz.h"
    #include "pdf.h"
}

#define LOG_TAG "MuPDF"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C" JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_initContext(JNIEnv *env, jobject thiz) {
    fz_context *ctx = fz_new_context(NULL, NULL, FZ_STORE_UNLIMITED);
    if (!ctx) {
        LOGE("Cannot create MuPDF context");
        return 0;
    }
    fz_register_document_handlers(ctx);
    LOGI("MuPDF context created successfully");
    return (jlong)ctx;
}

extern "C" JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_openDocument(JNIEnv *env, jobject thiz, 
                                                       jlong ctx_ptr, jstring path) {
    fz_context *ctx = (fz_context *)ctx_ptr;
    const char *c_path = env->GetStringUTFChars(path, NULL);
    
    fz_document *doc = NULL;
    fz_try(ctx) {
        doc = fz_open_document(ctx, c_path);
        LOGI("Document opened successfully: %s", c_path);
    }
    fz_catch(ctx) {
        LOGE("Cannot open document: %s", c_path);
        doc = NULL;
    }
    
    env->ReleaseStringUTFChars(path, c_path);
    return (jlong)doc;
}

extern "C" JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_getPageCount(JNIEnv *env, jobject thiz,
                                                       jlong ctx_ptr, jlong doc_ptr) {
    fz_context *ctx = (fz_context *)ctx_ptr;
    fz_document *doc = (fz_document *)doc_ptr;
    
    if (!ctx || !doc) {
        LOGE("Invalid context or document pointer");
        return 0;
    }
    
    int count = 0;
    fz_try(ctx) {
        count = fz_count_pages(ctx, doc);
        LOGI("Page count: %d", count);
    }
    fz_catch(ctx) {
        LOGE("Cannot get page count");
        return 0;
    }
    return count;
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_renderPage(JNIEnv *env, jobject thiz,
                                                     jlong ctx_ptr, jlong doc_ptr,
                                                     jint page_num, jobject bitmap,
                                                     jfloat zoom) {
    fz_context *ctx = (fz_context *)ctx_ptr;
    fz_document *doc = (fz_document *)doc_ptr;
    
    if (!ctx || !doc) {
        LOGE("Invalid context or document for rendering");
        return JNI_FALSE;
    }

    AndroidBitmapInfo info;
    void *pixels;
    
    if (AndroidBitmap_getInfo(env, bitmap, &info) < 0) {
        LOGE("AndroidBitmap_getInfo failed");
        return JNI_FALSE;
    }
    
    if (info.format != ANDROID_BITMAP_FORMAT_RGBA_8888) {
        LOGE("Bitmap format must be RGBA_8888");
        return JNI_FALSE;
    }
    
    if (AndroidBitmap_lockPixels(env, bitmap, &pixels) < 0) {
        LOGE("AndroidBitmap_lockPixels failed");
        return JNI_FALSE;
    }
    
    fz_try(ctx) {
        fz_page *page = fz_load_page(ctx, doc, page_num);
        fz_matrix transform = fz_scale(zoom, zoom);
        fz_rect bounds = fz_bound_page(ctx, page);
        fz_transform_rect(bounds, transform);
        
        fz_irect bbox = fz_round_rect(bounds);
        fz_pixmap *pix = fz_new_pixmap_with_bbox(ctx, fz_device_rgb(ctx), bbox, NULL, 1);
        fz_clear_pixmap_with_value(ctx, pix, 0xFF);
        
        fz_device *dev = fz_new_draw_device(ctx, transform, pix);
        fz_run_page(ctx, page, dev, transform, NULL);
        fz_close_device(ctx, dev);
        fz_drop_device(ctx, dev);
        fz_drop_page(ctx, page);
        
        // Copy to Android bitmap
        unsigned char *src = fz_pixmap_samples(ctx, pix);
        unsigned char *dst = (unsigned char *)pixels;
        int stride = fz_pixmap_stride(ctx, pix);
        int width = fz_pixmap_width(ctx, pix);
        int height = fz_pixmap_height(ctx, pix);
        
        for (int y = 0; y < height; y++) {
            memcpy(dst + y * info.stride, src + y * stride, width * 4);
        }
        
        fz_drop_pixmap(ctx, pix);
        LOGI("Page %d rendered successfully", page_num);
    }
    fz_catch(ctx) {
        LOGE("Failed to render page %d", page_num);
        AndroidBitmap_unlockPixels(env, bitmap);
        return JNI_FALSE;
    }
    
    AndroidBitmap_unlockPixels(env, bitmap);
    return JNI_TRUE;
}

extern "C" JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_closeDocument(JNIEnv *env, jobject thiz,
                                                        jlong ctx_ptr, jlong doc_ptr) {
    fz_context *ctx = (fz_context *)ctx_ptr;
    fz_document *doc = (fz_document *)doc_ptr;
    
    if (ctx && doc) {
        fz_drop_document(ctx, doc);
        LOGI("Document closed");
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_destroyContext(JNIEnv *env, jobject thiz,
                                                         jlong ctx_ptr) {
    fz_context *ctx = (fz_context *)ctx_ptr;
    if (ctx) {
        fz_drop_context(ctx);
        LOGI("MuPDF context destroyed");
    }
}
