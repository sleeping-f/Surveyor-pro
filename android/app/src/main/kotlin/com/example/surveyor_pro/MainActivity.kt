package com.example.surveyor_pro

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "surveyor_pro/gallery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "saveImage") {
                    val filePath = call.argument<String>("filePath")
                    val fileName = call.argument<String>("fileName")
                    if (filePath.isNullOrEmpty()) {
                        result.error("invalid_args", "File path is missing.", null)
                        return@setMethodCallHandler
                    }

                    val savedUri = saveImageToGallery(filePath, fileName)
                    if (savedUri != null) {
                        result.success(savedUri.toString())
                    } else {
                        result.error("save_failed", "Gallery save failed.", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun saveImageToGallery(filePath: String, fileName: String?): Uri? {
        val source = File(filePath)
        if (!source.exists()) {
            return null
        }

        val safeName = if (fileName.isNullOrBlank()) source.name else fileName
        val resolver = applicationContext.contentResolver
        val mimeType = "image/jpeg"

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, safeName)
                put(MediaStore.Images.Media.MIME_TYPE, mimeType)
                put(
                    MediaStore.Images.Media.RELATIVE_PATH,
                    Environment.DIRECTORY_PICTURES + File.separator + "SurveyorPro"
                )
                put(MediaStore.Images.Media.IS_PENDING, 1)
                put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis())
            }
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: return null
            resolver.openOutputStream(uri)?.use { output ->
                FileInputStream(source).use { input ->
                    input.copyTo(output)
                }
            } ?: return null

            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            uri
        } else {
            val picturesDir =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
            val targetDir = File(picturesDir, "SurveyorPro")
            if (!targetDir.exists()) {
                targetDir.mkdirs()
            }
            val target = File(targetDir, safeName)
            FileInputStream(source).use { input ->
                FileOutputStream(target).use { output ->
                    input.copyTo(output)
                }
            }
            MediaScannerConnection.scanFile(
                applicationContext,
                arrayOf(target.absolutePath),
                arrayOf(mimeType),
                null
            )
            Uri.fromFile(target)
        }
    }
}
