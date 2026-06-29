package com.epicplay.epicblocks

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val vibrationChannelName = "epic_blocks/vibration"
    private val updatesChannelName = "epic_blocks/updates"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            vibrationChannelName,
        ).setMethodCallHandler { call, result ->
            if (call.method != "vibrate") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val duration = call.arguments as? Int ?: 35
            vibrate(duration.toLong())
            result.success(null)
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            updatesChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledVersion" -> result.success(getInstalledVersion())
                "getUpdateCacheDirectory" -> result.success(getUpdateCacheDirectory())
                "canRequestPackageInstalls" -> result.success(canRequestPackageInstalls())
                "openInstallPermissionSettings" -> openInstallPermissionSettings(result)
                "installApk" -> {
                    val apkPath = call.arguments as? String
                    if (apkPath == null) {
                        result.error("missing_apk_path", "APK path is required.", null)
                        return@setMethodCallHandler
                    }
                    installApk(apkPath, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun vibrate(durationMillis: Long) {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            manager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        if (!vibrator.hasVibrator()) {
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(
                VibrationEffect.createOneShot(
                    durationMillis,
                    VibrationEffect.DEFAULT_AMPLITUDE,
                ),
            )
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(durationMillis)
        }
    }

    private fun getInstalledVersion(): Map<String, Any> {
        val packageInfo = packageManager.getPackageInfo(packageName, 0)
        val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            packageInfo.versionCode.toLong()
        }

        return mapOf(
            "versionName" to (packageInfo.versionName ?: "0.0.0"),
            "versionCode" to versionCode,
        )
    }

    private fun canRequestPackageInstalls(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            packageManager.canRequestPackageInstalls()
        } else {
            true
        }
    }

    private fun getUpdateCacheDirectory(): String {
        val updatesDirectory = File(cacheDir, "updates")
        updatesDirectory.mkdirs()
        return updatesDirectory.absolutePath
    }

    private fun openInstallPermissionSettings(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.success(null)
            return
        }

        val intent = Intent(
            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
            Uri.parse("package:$packageName"),
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(intent)
            result.success(null)
        } catch (_: ActivityNotFoundException) {
            result.error(
                "install_permission_settings_unavailable",
                "Could not open install permission settings.",
                null,
            )
        }
    }

    private fun installApk(apkPath: String, result: MethodChannel.Result) {
        val apkFile = File(apkPath)
        if (!apkFile.exists()) {
            result.error("apk_missing", "Downloaded APK was not found.", null)
            return
        }

        val apkUri = try {
            FileProvider.getUriForFile(
                this,
                "$packageName.update_file_provider",
                apkFile,
            )
        } catch (_: IllegalArgumentException) {
            result.error(
                "apk_uri_unavailable",
                "Could not prepare the downloaded update.",
                null,
            )
            return
        }

        val intent = Intent(Intent.ACTION_INSTALL_PACKAGE)
            .setData(apkUri)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .putExtra(Intent.EXTRA_RETURN_RESULT, false)

        try {
            startActivity(intent)
            result.success(null)
        } catch (_: ActivityNotFoundException) {
            result.error("installer_unavailable", "Could not open installer.", null)
        }
    }
}
