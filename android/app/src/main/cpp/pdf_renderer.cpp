#include <jni.h>
#include <string>
#include <android/log.h>

#define LOG_TAG "PDFRenderer"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Basit test fonksiyonları
extern "C" {

JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_simpleAdd(JNIEnv *env, jobject thiz, jint a, jint b) {
    LOGI("🔢 C++: simpleAdd çağrıldı: %d + %d", a, b);
    jint result = a + b;
    LOGI("🔢 C++: Sonuç: %d", result);
    return result;
}

JNIEXPORT jstring JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getVersion(JNIEnv *env, jobject thiz) {
    LOGI("🔢 C++: getVersion çağrıldı");
    std::string version = "PDF Renderer v1.0 - C++ Backend Aktif!";
    return env->NewStringUTF(version.c_str());
}

JNIEXPORT jstring JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_calculate(JNIEnv *env, jobject thiz, jstring operation) {
    const char *op = env->GetStringUTFChars(operation, 0);
    LOGI("🔢 C++: calculate çağrıldı: %s", op);
    
    std::string result;
    
    // Basit matematik işlemleri
    if (strstr(op, "2+2")) {
        result = "2 + 2 = 4 (C++ Hesapladı!)";
    } else if (strstr(op, "5*3")) {
        result = "5 × 3 = 15 (C++ Hesapladı!)";
    } else if (strstr(op, "10/2")) {
        result = "10 ÷ 2 = 5 (C++ Hesapladı!)";
    } else {
        result = "İşlem anlaşılamadı: " + std::string(op);
    }
    
    env->ReleaseStringUTFChars(operation, op);
    LOGI("🔢 C++: Hesaplama sonucu: %s", result.c_str());
    return env->NewStringUTF(result.c_str());
}

// Mevcut PDF fonksiyonları (basitleştirilmiş)
JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initContext(JNIEnv *env, jobject thiz) {
    LOGI("🎯 C++: initContext çağrıldı");
    // Basit bir pointer değeri döndür (test için)
    return (jlong) 0x12345678;
}

JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument(JNIEnv *env, jobject thiz, jlong context, jstring path) {
    const char *file_path = env->GetStringUTFChars(path, 0);
    LOGI("📄 C++: openDocument çağrıldı - Context: %ld, Path: %s", context, file_path);
    env->ReleaseStringUTFChars(path, file_path);
    // Basit bir pointer değeri döndür (test için)
    return (jlong) 0x87654321;
}

JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount(JNIEnv *env, jobject thiz, jlong context, jlong document) {
    LOGI("📊 C++: getPageCount çağrıldı - Context: %ld, Document: %ld", context, document);
    // Test için sabit sayfa sayısı
    return 42;
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument(JNIEnv *env, jobject thiz, jlong context, jlong document) {
    LOGI("🧹 C++: closeDocument çağrıldı - Context: %ld, Document: %ld", context, document);
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_destroyContext(JNIEnv *env, jobject thiz, jlong context) {
    LOGI("🧹 C++: destroyContext çağrıldı - Context: %ld", context);
}

}
