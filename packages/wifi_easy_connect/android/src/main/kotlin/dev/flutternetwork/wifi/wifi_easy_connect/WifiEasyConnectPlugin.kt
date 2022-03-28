package dev.flutternetwork.wifi.wifi_easy_connect

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.wifi.WifiManager
import android.os.Build
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

/** WiFiEasyConnectCapability codes */
private const val CAPABILITY_NONE = 0
private const val CAPABILITY_FULL = 1
private const val CAPABILITY_ONLY_CONFIGURATOR = 2
private const val CAPABILITY_ONLY_ENROLLEE = 3


/** WifiEasyConnectPlugin
 *
 * Useful links:
 * - https://developer.android.com/guide/topics/connectivity/wifi-easy
 * - https://source.android.com/devices/tech/connect/wifi-easy-connect
 * - https://developer.android.com/reference/android/net/wifi/WifiManager
 * - https://developer.android.com/reference/android/provider/Settings.html#ACTION_PROCESS_WIFI_EASY_CONNECT_URI
 * */
class WifiEasyConnectPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    ActivityResultListener {
    private val logTag = javaClass.simpleName
    private lateinit var context: Context
    private var activity: Activity? = null
    private var wifi: WifiManager? = null

    // plugin interface
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        wifi = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

        // set Flutter channels
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_easy_connect")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        wifi = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when(call.method){
            "hasCapability" -> result.success(hasCapability())
            else -> result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        TODO("Not yet implemented")
    }

    private fun hasCapability(): Int {
        val isConfiguratorSupported = when {
            Build.VERSION.SDK_INT < Build.VERSION_CODES.Q -> false
            else -> wifi!!.isEasyConnectSupported
        }
        val isEnrolleeSupported = when {
            Build.VERSION.SDK_INT < Build.VERSION_CODES.S -> false
            else -> wifi!!.isEasyConnectEnrolleeResponderModeSupported
        }
        return when {
            isConfiguratorSupported && isEnrolleeSupported -> CAPABILITY_FULL
            isConfiguratorSupported -> CAPABILITY_ONLY_CONFIGURATOR
            isEnrolleeSupported -> CAPABILITY_ONLY_ENROLLEE
            else -> CAPABILITY_NONE
        }
    }
}
