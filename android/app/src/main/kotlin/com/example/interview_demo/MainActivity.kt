package com.example.interview_demo

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.text.TextUtils
import androidx.annotation.NonNull
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.*


enum class MaskMethod(val value: String) {
    applyMaskToImage("applyMaskToImage"),
}


class MainActivity : FlutterActivity() {
    private var maskChannel: MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        initMaskMethodChannel(flutterEngine)
    }


    private fun initMaskMethodChannel(@NonNull flutterEngine: FlutterEngine) {
        maskChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "interview_demo/mask_channel")
        maskChannel?.setMethodCallHandler(MethodChannel.MethodCallHandler { call, result ->
            val method = call.method
            when (method) {
                MaskMethod.applyMaskToImage.value -> {
                    GlobalScope.launch(Dispatchers.IO) {
                        try {
                            println(method)
                            if (call.arguments !is Map<*, *>) {
                                result.error("InvaliedParams", "Map<*, *> is required", "")
                                return@launch
                            }
                            val params: Map<String, String>? = call.arguments as? Map<String, String>
                            val originalImagePath = params?.get("originalImagePath") as? String
                            println(originalImagePath)
                            val maskImagePath = params?.get("maskImagePath") as? String
                            println(maskImagePath)
                            if (TextUtils.isEmpty(originalImagePath) || TextUtils.isEmpty(maskImagePath)) {
                                result.error("InvaliedParams", "originalImagePath and maskImagePath is required", "")
                                return@launch
                            }
                            val maskedImagePath = applyMaskImgToOriginalImg(originalImagePath!!, maskImagePath!!)
                            println(maskedImagePath)
                            result.success(maskedImagePath)
                        } catch (e: Exception) {
                            result.error("FailedToMaskImage", "Failed to mask image", e.toString());
                        }
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        })
    }

    private suspend fun applyMaskImgToOriginalImg(originalImagePath: String, maskImagePath: String): String {
        val loader = FlutterInjector.instance().flutterLoader()
        val originalImageRealPath = loader.getLookupKeyForAsset(originalImagePath)
        var originalImageStream: InputStream = assets.open(originalImageRealPath)
        var originalImageBitmap = BitmapFactory.decodeStream(originalImageStream)


        val maskImageRealPath = loader.getLookupKeyForAsset(maskImagePath)
        var maskImageStream: InputStream = assets.open(maskImageRealPath)
        var maskImageBitmap = BitmapFactory.decodeStream(maskImageStream)

        val width: Int = originalImageBitmap.getWidth()
        val height: Int = originalImageBitmap.getHeight()
        val originalPixels = IntArray(width * height)
        val maskPixels = IntArray(width * height)
        val resultPixels = IntArray(width * height)

        originalImageBitmap.getPixels(originalPixels, 0, width, 0, 0, width, height);
        maskImageBitmap.getPixels(maskPixels, 0, width, 0, 0, width, height);

        for (i in 0 until width * height) {
            val maskColor = maskPixels[i]
            if (Color.alpha(maskColor) == 255 && Color.red(maskColor) == 255 && Color.green(maskColor) == 255 && Color.blue(maskColor) == 255) {
                resultPixels[i] = originalPixels[i]
            } else {
                resultPixels[i] = Color.TRANSPARENT
            }
        }
        val result = Bitmap.createBitmap(resultPixels, width, height, Bitmap.Config.ARGB_8888)
        val mastedImgPath = writeBitmapToFile(result, filesDir.absolutePath + File.separator + originalImageRealPath.hashCode())

        return mastedImgPath
    }


    private fun writeBitmapToFile(bitmap: Bitmap, fileName: String): String {
        return try {
            println(fileName)
            val imgFile = File(fileName)
            val parentDir = imgFile.parentFile
            if (parentDir != null && !parentDir.exists()) {
                parentDir.mkdirs()
            }
            val fileOutputStream = FileOutputStream(imgFile)
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, fileOutputStream)
            fileOutputStream.flush()
            fileOutputStream.close()
            imgFile.absolutePath
        } catch (e: IOException) {
            e.printStackTrace()
            throw e
        }
    }
}
