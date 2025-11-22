#include <jni.h>
#include <android/bitmap.h>
#include <android/log.h>

#define LOG_TAG "PDFRenderer"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C" JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_initContext(JNIEnv *env, jobject thiz) {
    LOGI("🎯 INIT_CONTEXT called from Flutter");
    LOGI("🎯 PDFRenderer native library is working!");
    return (jlong)123456789;
}

extern "C" JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_openDocument(JNIEnv *env, jobject thiz, 
                                                       jlong ctx_ptr, jstring path) {
    const char *c_path = env->GetStringUTFChars(path, NULL);
    LOGI("📄 OPEN_DOCUMENT called with path: %s", c_path);
    LOGI("📄 Context pointer: %ld", ctx_ptr);
    env->ReleaseStringUTFChars(path, c_path);
    
    // Simulate document opening
    if (ctx_ptr == 123456789) {
        LOGI("📄 Document opened successfully (simulated)");
        return (jlong)987654321;
    } else {
        LOGE("❌ Invalid context pointer");
        return 0;
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_getPageCount(JNIEnv *env, jobject thiz,
                                                       jlong ctx_ptr, jlong doc_ptr) {
    LOGI("📊 GET_PAGE_COUNT called");
    LOGI("📊 Context: %ld, Document: %ld", ctx_ptr, doc_ptr);
    
    // Simulate page count
    if (doc_ptr == 987654321) {
        LOGI("📊 Returning simulated page count: 10");
        return 10;
    } else {
        LOGI("📊 No document open, returning 0");
        return 0;
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_closeDocument(JNIEnv *env, jobject thiz,
                                                        jlong ctx_ptr, jlong doc_ptr) {
    LOGI("📄 CLOSE_DOCUMENT called");
    LOGI("📄 Context: %ld, Document: %ld", ctx_ptr, doc_ptr);
}

extern "C" JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_reader_manager_PDFRenderer_destroyContext(JNIEnv *env, jobject thiz,
                                                         jlong ctx_ptr) {
    LOGI("🎯 DESTROY_CONTEXT called");
    LOGI("🎯 Context: %ld", ctx_ptr);
}
