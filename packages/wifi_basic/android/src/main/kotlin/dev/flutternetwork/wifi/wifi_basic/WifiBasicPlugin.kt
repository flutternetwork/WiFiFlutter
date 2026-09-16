package dev.flutternetwork.wifi.wifi_basic

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.wifi.ScanResult
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** WifiBasicPlugin */
class WifiBasicPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var wifi: WifiManager? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_basic")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        wifi =
            context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isSupported" -> result.success(isSupported())
            "getGeneration" -> result.success(getGeneration())
            "isEnabled" -> result.success(isEnabled())
            "setEnabled" -> {
                val enabled = call.argument<Boolean>("enabled")
                    ?: return result.error("InvalidArg", "enabled argument is null", null)
                result.success(setEnabled(enabled))
            }
            "openSettings" -> {
                openSettings()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        wifi = null
    }

    private fun isSupported(): Boolean =
        wifi != null && context.packageManager.hasSystemFeature(PackageManager.FEATURE_WIFI)

    private fun getGeneration(): Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) when {
        wifi!!.isWifiStandardSupported(ScanResult.WIFI_STANDARD_11AX) -> 6
        wifi!!.isWifiStandardSupported(ScanResult.WIFI_STANDARD_11AC) -> 5
        wifi!!.isWifiStandardSupported(ScanResult.WIFI_STANDARD_11N) -> 4
        wifi!!.isWifiStandardSupported(ScanResult.WIFI_STANDARD_LEGACY) -> 3
        else -> -1
    } else {
        // TODO: figure out based on link speed - https://stackoverflow.com/a/20970073/2554745
        -1
    }

    private fun isEnabled(): Boolean = wifi!!.isWifiEnabled

    private fun setEnabled(enabled: Boolean): Boolean =
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) wifi!!.setWifiEnabled(enabled) else false

    private fun openSettings() {
        val intent = Intent(Settings.ACTION_WIFI_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }
}
