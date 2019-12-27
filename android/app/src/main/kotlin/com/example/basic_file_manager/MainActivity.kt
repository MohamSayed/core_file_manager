package com.example.basic_file_manager

import android.os.Build
import android.os.Environment
import android.os.StatFs
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.basic_file_manager/storage"
    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->
                    result?.success(getStorageFreeSpace())
                }
    }

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    fun getStorageFreeSpace(): Int{
        var stat = StatFs(Environment.getExternalStorageDirectory().absolutePath)
        var bytesAvailable = stat.blockCountLong * stat.availableBlocksLong
        var megAvailable = bytesAvailable / (1024 * 1024)
        return megAvailable.toInt()
    }
}
