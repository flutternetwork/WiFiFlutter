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

/** Error Codes */
private const val ERROR_INVALID_ARGS = "InvalidArgs"
private const val ERROR_NULL_ACTIVITY = "NullActivity"

/** WiFiEasyConnectCapability codes */
private const val CAPABILITY_NONE = 0
private const val CAPABILITY_FULL = 1
private const val CAPABILITY_ONLY_CONFIGURATOR = 2
private const val CAPABILITY_ONLY_ENROLLEE = 3

/** OnboardErrors codes */
private const val ONBOARD_ERROR_NOT_SUPPORTED = 0

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
        when (call.method) {
            "hasCapability" -> result.success(hasCapability())
            "onboard" -> {
                onboard(
                    dppUri = call.argument<String>("dppUri") ?: return result.error(
                        ERROR_INVALID_ARGS,
                        "askPermissions argument is null",
                        null
                    ),
                    bands = call.argument<List<Int>>("bands")
                ) {
                    it.send(result)
                }

            }
            else -> result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        TODO("Not yet implemented")
    }

    private fun hasConfiguratorCapability(): Boolean = when {
        Build.VERSION.SDK_INT < Build.VERSION_CODES.Q -> false
        else -> wifi!!.isEasyConnectSupported
    }

    private fun hasEnrolleeCapability(): Boolean = when {
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S -> false
        else -> wifi!!.isEasyConnectEnrolleeResponderModeSupported
    }

    private fun hasCapability(): Int {
        val isConfiguratorSupported = hasConfiguratorCapability()
        val isEnrolleeSupported = hasEnrolleeCapability()
        return when {
            isConfiguratorSupported && isEnrolleeSupported -> CAPABILITY_FULL
            isConfiguratorSupported -> CAPABILITY_ONLY_CONFIGURATOR
            isEnrolleeSupported -> CAPABILITY_ONLY_ENROLLEE
            else -> CAPABILITY_NONE
        }
    }

    private fun onboard(
        dppUri: String,
        bands: List<Int>?,
        callback: (result: OnboardingResult) -> Unit
    ) {
        // check if has activity - return error if null
        if (activity == null) return callback.invoke(
            OnboardingResult(
                ERROR_NULL_ACTIVITY,
                "Cannot ask for location permission.",
                "Looks like called from non-Activity."
            )
        )

        // check if hasConfiguratorCapability - return error if doesn't
        if (!hasConfiguratorCapability()) {
            return callback.invoke(OnboardingResult(ONBOARD_ERROR_NOT_SUPPORTED))
        }

        TODO("make intent to startActivity with ACTION_PROCESS_WIFI_EASY_CONNECT_URI")

        TODO("wait for result, invoke callback when received")
    }

    private class OnboardingResult {
        // error to fail
        private var errorCodeStr: String? = null
        private var errorMessage: String? = null
        private var errorDetails: String? = null

        // error - but not fail
        private var errorCodeInt: Int? = null

        constructor(errorCode: String, errorMessage: String?, errorDetails: String?) {
            this.errorCodeStr = errorCode
            this.errorMessage = errorMessage
            this.errorDetails = errorDetails
        }

        constructor(errorCode: Int) {
            errorCodeInt = errorCode
        }

        fun send(result: Result) =
            when {
                errorCodeStr != null -> result.error(errorCodeStr, errorMessage, errorDetails)
                errorCodeInt != null -> result.success(mapOf("error" to errorCodeInt))
                // TODO proper value to be sent
                else -> result.success(mapOf<String, Map<String, Any?>>("value" to emptyMap()))
            }
    }
}
