package dev.flutternetwork.wifi.wifi_basic

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
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
    private var context: Context? = null
    private var wifi: WifiManager? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_basic")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        wifi =
            context!!.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "hasCapability" -> {
                result.success(hasCapability())
            }
            "isEnabled" -> {
                result.success(isEnabled())
            }
            "setEnabled" -> {
                val enabled = call.argument<Boolean>("enabled")
                if (enabled != null) {
                    val shouldOpenSettings = call.argument<Boolean>("shouldOpenSettings")
                    val isSuccess = setEnabled(enabled, shouldOpenSettings ?: false)
                    result.success(isSuccess)
                } else {
                    result.error("InvalidArg", "enabled argument is null", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
        wifi = null
    }

    private fun hasCapability(): Boolean =
        wifi != null && context!!.packageManager.hasSystemFeature(PackageManager.FEATURE_WIFI)

    private fun isEnabled(): Boolean = wifi!!.isWifiEnabled

    private fun setEnabled(enabled: Boolean, shouldOpenSettings: Boolean): Boolean =
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            wifi!!.setWifiEnabled(enabled)
        } else {
            val isSuccess = wifi!!.setWifiEnabled(enabled)
            if (!isSuccess && shouldOpenSettings) {
                val intent = Intent(Settings.ACTION_WIFI_SETTINGS)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context!!.startActivity(intent)
            }
            isSuccess
        }
}
