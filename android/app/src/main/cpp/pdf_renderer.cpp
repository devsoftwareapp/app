#include <jni.h>
#include <android/bitmap.h>
#include <android/log.h>

#define LOG_TAG "PDFRenderer"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

extern "C" JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_initContext(JNIEnv *env, jobject thiz) {
    LOGI("PDFRenderer initContext called");
    return 123456789; // Geçici değer
}

extern "C" JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_openDocument(JNIEnv *env, jobject thiz, 
                                                       jlong ctx_ptr, jstring path) {
    LOGI("PDFRenderer openDocument called");
    return 987654321; // Geçici değer
}

extern "C" JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_getPageCount(JNIEnv *env, jobject thiz,
                                                       jlong ctx_ptr, jlong doc_ptr) {
    LOGI("PDFRenderer getPageCount called");
    return 10; // Geçici değer
}

extern "C" JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_closeDocument(JNIEnv *env, jobject thiz,
                                                        jlong ctx_ptr, jlong doc_ptr) {
    LOGI("PDFRenderer closeDocument called");
}

extern "C" JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_destroyContext(JNIEnv *env, jobject thiz,
                                                         jlong ctx_ptr) {
    LOGI("PDFRenderer destroyContext called");
}
