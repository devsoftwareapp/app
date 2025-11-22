#include <jni.h>
#include <android/bitmap.h>
#include <android/log.h>

extern "C" {
    #include "fitz.h"
    #include "pdf.h"
}

#define LOG_TAG "MuPDF"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

extern "C" JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdfreader_PDFRenderer_initContext(JNIEnv *env, jobject thiz) {
    fz_context *ctx = fz_new_context(NULL, NULL, FZ_STORE_UNLIMITED);
    fz_register_document_handlers(ctx);
    LOGI("MuPDF context created");
    return (jlong)ctx;
}

extern "C" JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdfreader_PDFRenderer_openDocument(JNIEnv *env, jobject thiz, 
                                                       jlong ctx_ptr, jstring path) {
    fz_context *ctx = (fz_context *)ctx_ptr;
    const char *c_path = env->GetStringUTFChars(path, NULL);
    
    fz_document *doc = fz_open_document(ctx, c_path);
    env->ReleaseStringUTFChars(path, c_path);
    
    LOGI("Document opened");
    return (jlong)doc;
}

extern "C" JNIEXPORT jint JNICALL
Java_com_devsoftware_pdfreader_PDFRenderer_getPageCount(JNIEnv *env, jobject thiz,
                                                       jlong ctx_ptr, jlong doc_ptr) {
    fz_context *ctx = (fz_context *)ctx_ptr;
    fz_document *doc = (fz_document *)doc_ptr;
    return fz_count_pages(ctx, doc);
}

extern "C" JNIEXPORT void JNICALL
Java_com_devsoftware_pdfreader_PDFRenderer_closeDocument(JNIEnv *env, jobject thiz,
                                                        jlong ctx_ptr, jlong doc_ptr) {
    fz_context *ctx = (fz_context *)ctx_ptr;
    fz_document *doc = (fz_document *)doc_ptr;
    fz_drop_document(ctx, doc);
}

extern "C" JNIEXPORT void JNICALL
Java_com_devsoftware_pdfreader_PDFRenderer_destroyContext(JNIEnv *env, jobject thiz,
                                                         jlong ctx_ptr) {
    fz_context *ctx = (fz_context *)ctx_ptr;
    fz_drop_context(ctx);
}
