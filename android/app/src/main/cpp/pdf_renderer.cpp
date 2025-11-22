#include <jni.h>
#include <string>
#include <android/log.h>

#define LOG_TAG "PDFRenderer"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C" {

// EN BASİT TEST FONKSİYONU
JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_simpleAdd(JNIEnv *env, jobject thiz, jint a, jint b) {
    LOGI("🎯 C++: simpleAdd çağrıldı: %d + %d", a, b);
    jint result = a + b;
    LOGI("🎯 C++: Sonuç: %d", result);
    return result;
}

// Basit versiyon fonksiyonu
JNIEXPORT jstring JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getVersion(JNIEnv *env, jobject thiz) {
    LOGI("🎯 C++: getVersion çağrıldı");
    return env->NewStringUTF("PDFium v1.0 - TEST SUCCESS!");
}

}
