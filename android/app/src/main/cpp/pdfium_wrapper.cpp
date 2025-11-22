#include <jni.h>
#include <string>
#include <android/log.h>
#include <fpdfview.h>  // GERÇEK PDFium HEADER

#define LOG_TAG "PDFiumWrapper"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C" {

JNIEXPORT jboolean JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initPDFium(
    JNIEnv *env, 
    jobject thiz) {
    
    LOGI("🎯 PDFium başlatılıyor...");
    
    try {
        FPDF_InitLibrary();
        LOGI("✅ PDFium başarıyla başlatıldı!");
        return JNI_TRUE;
    } catch (const std::exception& e) {
        LOGE("❌ PDFium başlatma hatası: %s", e.what());
        return JNI_FALSE;
    }
}

JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument(
    JNIEnv *env, 
    jobject thiz, 
    jstring file_path) {
    
    const char *native_path = env->GetStringUTFChars(file_path, nullptr);
    if (native_path == nullptr) {
        LOGE("❌ String conversion failed");
        return 0;
    }
    
    LOGI("🎯 PDF belgesi açılıyor: %s", native_path);
    
    FPDF_DOCUMENT document = FPDF_LoadDocument(native_path, nullptr);
    env->ReleaseStringUTFChars(file_path, native_path);
    
    if (document == nullptr) {
        LOGE("❌ PDF açılamadı: %s", native_path);
        return 0;
    }
    
    LOGI("✅ PDF başarıyla açıldı: %p", document);
    return reinterpret_cast<jlong>(document);
}

JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount(
    JNIEnv *env, 
    jobject thiz, 
    jlong document_ptr) {
    
    FPDF_DOCUMENT document = reinterpret_cast<FPDF_DOCUMENT>(document_ptr);
    if (document == nullptr) {
        LOGE("❌ Geçersiz document pointer");
        return 0;
    }
    
    int page_count = FPDF_GetPageCount(document);
    LOGI("🎯 Sayfa sayısı alındı: %d", page_count);
    return page_count;
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument(
    JNIEnv *env, 
    jobject thiz, 
    jlong document_ptr) {
    
    FPDF_DOCUMENT document = reinterpret_cast<FPDF_DOCUMENT>(document_ptr);
    if (document != nullptr) {
        FPDF_CloseDocument(document);
        LOGI("✅ PDF belgesi kapatıldı");
    }
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_destroyPDFium(
    JNIEnv *env, 
    jobject thiz) {
    
    FPDF_DestroyLibrary();
    LOGI("✅ PDFium kapatıldı");
}

// Sayfa genişlik ve yüksekliğini al
JNIEXPORT jintArray JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageSize(
    JNIEnv *env, 
    jobject thiz, 
    jlong document_ptr, 
    jint page_index) {
    
    FPDF_DOCUMENT document = reinterpret_cast<FPDF_DOCUMENT>(document_ptr);
    if (document == nullptr) {
        LOGE("❌ Geçersiz document pointer");
        return nullptr;
    }
    
    double width, height;
    FPDF_GetPageSizeByIndex(document, page_index, &width, &height);
    
    jintArray result = env->NewIntArray(2);
    jint dimensions[2] = {static_cast<jint>(width), static_cast<jint>(height)};
    env->SetIntArrayRegion(result, 0, 2, dimensions);
    
    LOGI("📐 Sayfa %d boyutu: %.2fx%.2f", page_index, width, height);
    return result;
}

}
