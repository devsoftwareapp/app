#include <jni.h>
#include <android/log.h>
#include <string>

#define LOG_TAG "PDFRenderer"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

struct PDFDocument {
    int pageCount;
    std::string title;
    std::string filePath;
};

extern "C" {

JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initContext(JNIEnv* env, jobject thiz) {
    LOGI("🎯 PDF Context initializing...");
    return (jlong) 0x12345678;
}

JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument(JNIEnv* env, jobject thiz, jlong context, jstring filePath) {
    LOGI("📄 Opening PDF...");
    
    if (filePath == nullptr) {
        LOGE("❌ File path is NULL");
        return 0;
    }
    
    const char* path = env->GetStringUTFChars(filePath, nullptr);
    if (path == nullptr) {
        LOGE("❌ Failed to get string chars");
        return 0;
    }
    
    LOGI("📄 Path: %s", path);
    
    // Basit PDF document oluştur
    PDFDocument* doc = new PDFDocument();
    doc->pageCount = 12; // Test değeri
    doc->title = "Imported PDF";
    doc->filePath = std::string(path);
    
    LOGI("✅ PDF opened - Pages: %d", doc->pageCount);
    
    env->ReleaseStringUTFChars(filePath, path);
    return (jlong) doc;
}

JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    if (document == 0) return 0;
    PDFDocument* doc = (PDFDocument*) document;
    return doc->pageCount;
}

JNIEXPORT jstring JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getDocumentTitle(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    if (document == 0) return env->NewStringUTF("Unknown Document");
    PDFDocument* doc = (PDFDocument*) document;
    return env->NewStringUTF(doc->title.c_str());
}

JNIEXPORT jstring JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getFilePath(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    if (document == 0) return env->NewStringUTF("");
    PDFDocument* doc = (PDFDocument*) document;
    return env->NewStringUTF(doc->filePath.c_str());
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    if (document != 0) {
        PDFDocument* doc = (PDFDocument*) document;
        LOGI("🧹 Closing document");
        delete doc;
    }
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_destroyContext(JNIEnv* env, jobject thiz, jlong context) {
    LOGI("🧹 Destroying context");
}

}
