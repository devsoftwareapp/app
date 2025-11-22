#include <jni.h>
#include <android/log.h>
#include <string>

#define LOG_TAG "PDFRenderer"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Struct'ı GLOBAL TANIMLA
struct SimpleDoc {
    int pages;
    const char* name;
};

extern "C" {

JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initContext(JNIEnv* env, jobject thiz) {
    LOGI("PDF Context initializing");
    return (jlong) 0x12345678;
}

JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument(JNIEnv* env, jobject thiz, jlong context, jstring filePath) {
    LOGI("Opening PDF");
    
    jboolean isCopy;
    const char* convertedPath = env->GetStringUTFChars(filePath, &isCopy);
    
    if (convertedPath == nullptr) {
        LOGE("String conversion failed");
        return 0;
    }
    
    std::string pathStr(convertedPath);
    LOGI("Path: %s", pathStr.c_str());
    
    SimpleDoc* doc = new SimpleDoc();
    doc->pages = 15;
    doc->name = "PDF Document";
    
    LOGI("PDF opened - Pages: %d", doc->pages);
    
    env->ReleaseStringUTFChars(filePath, convertedPath);
    return (jlong) doc;
}

JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    if (document == 0) return 0;
    SimpleDoc* doc = (SimpleDoc*) document;
    return doc->pages;
}

JNIEXPORT jstring JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getDocumentTitle(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    if (document == 0) return env->NewStringUTF("Unknown Document");
    SimpleDoc* doc = (SimpleDoc*) document;
    return env->NewStringUTF(doc->name);
}

JNIEXPORT jstring JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getFilePath(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    return env->NewStringUTF("/test/path/document.pdf");
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    if (document != 0) {
        SimpleDoc* doc = (SimpleDoc*) document;
        delete doc;
    }
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_destroyContext(JNIEnv* env, jobject thiz, jlong context) {
    LOGI("Destroying context");
}

}
