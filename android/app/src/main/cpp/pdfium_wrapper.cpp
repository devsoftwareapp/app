#include <jni.h>
#include <string>
#include <android/log.h>

#define LOG_TAG "PDFiumWrapper"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// PDFium header'ları gelecek - şimdilik mock fonksiyonlar
extern "C" {

JNIEXPORT jboolean JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initPDFium(
    JNIEnv *env, 
    jobject thiz) {
    
    LOGI("🎯 PDFium başlatılıyor... (MOCK)");
    LOGI("✅ PDFium başarıyla başlatıldı! (SIMULATION)");
    return JNI_TRUE;
}

JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument(
    JNIEnv *env, 
    jobject thiz, 
    jstring file_path) {
    
    const char *native_path = env->GetStringUTFChars(file_path, nullptr);
    LOGI("🎯 PDF belgesi açılıyor: %s (MOCK)", native_path);
    env->ReleaseStringUTFChars(file_path, native_path);
    
    // Mock document pointer
    return (jlong) 0x12345678;
}

JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount(
    JNIEnv *env, 
    jobject thiz, 
    jlong document_ptr) {
    
    LOGI("🎯 Sayfa sayısı alınıyor... (MOCK)");
    // Mock page count
    return 10;
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument(
    JNIEnv *env, 
    jobject thiz, 
    jlong document_ptr) {
    
    LOGI("🎯 PDF belgesi kapatılıyor... (MOCK)");
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_destroyPDFium(
    JNIEnv *env, 
    jobject thiz) {
    
    LOGI("🎯 PDFium kapatılıyor... (MOCK)");
}

}
