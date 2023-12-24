package dev.flutternetwork.wifi.wifi_easy_connect

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.net.wifi.EasyConnectStatusCallback.*
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings.*
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import kotlin.random.Random

/** Error Codes */
private const val ERROR_INVALID_ARGS = "InvalidArgs"
private const val ERROR_NULL_ACTIVITY = "NullActivity"

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
    private val activityResultCookies =
        mutableMapOf<Int, (resultCode: Int, data: Intent?) -> Boolean>()

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
                    dppUri = Uri.parse(
                        call.argument<String>("dppUri") ?: return result.error(
                            ERROR_INVALID_ARGS,
                            "askPermissions argument is null",
                            null
                        )
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
        Log.d(logTag, "onActivityResult: arguments ($requestCode, $resultCode, $data)")
        return activityResultCookies[requestCode]?.invoke(resultCode, data) ?: false
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
        dppUri: Uri,
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
            return callback.invoke(OnboardingResult(OnboardError.NotSupported))
        }

        // startActivity with ACTION_PROCESS_WIFI_EASY_CONNECT_URI" - add result-handler in activityResultCookies
        val requestCode = 6007800 + Random.Default.nextInt(100)
        activityResultCookies[requestCode] = { resultCode, data ->
            // invoke callback with proper args
            Log.d(logTag, "activityResultCallback: args($resultCode, $data)")
            callback.invoke(OnboardingResult(requestCode, data))
            true
        }

        val intent = Intent(ACTION_PROCESS_WIFI_EASY_CONNECT_URI, dppUri).apply {
            if (bands?.isNotEmpty() == true && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                putExtra(EXTRA_EASY_CONNECT_BAND_LIST, bands.toIntArray())
            }
        }
        activity!!.startActivityForResult(intent, requestCode)
    }

    private enum class OnboardError {
        NotSupported,
        UnknownFailure,
        Cancel,
        InvalidUri,
        InitFailure,
        NotCompatible,
        MalformedMessage,
        Busy,
        Timeout,
        ProtocolFailure,
        InvalidNetwork,
        CannotFindNetwork,
        AuthenticationFailure,
        EnrolleeRejected,
    }

    private class OnboardingResult {
        // exception
        private var exceptionCode: String? = null
        private var exceptionMessage: String? = null
        private var exceptionDetails: String? = null

        // error
        private var error: OnboardError? = null
        private var errorInfo: Map<String, Any?>? = null

        constructor(exceptionCode: String, exceptionMessage: String?, exceptionDetails: String?) {
            this.exceptionCode = exceptionCode
            this.exceptionMessage = exceptionMessage
            this.exceptionDetails = exceptionDetails
        }

        constructor(error: OnboardError) {
            this.error = error
        }

        constructor(resultCode: Int, data: Intent?) {
            when (resultCode) {
                Activity.RESULT_OK -> {}
                Activity.RESULT_CANCELED -> error = OnboardError.Cancel
                else -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                        error = OnboardError.UnknownFailure
                    } else {
                        // set error properly based on "ERROR_CODE"
                        when (val errorCode =
                            data!!.getIntExtra(EXTRA_EASY_CONNECT_ERROR_CODE, -99)) {
                            EASY_CONNECT_EVENT_FAILURE_INVALID_URI ->
                                error = OnboardError.InvalidUri
                            EASY_CONNECT_EVENT_FAILURE_AUTHENTICATION ->
                                error = OnboardError.InitFailure
                            EASY_CONNECT_EVENT_FAILURE_NOT_COMPATIBLE ->
                                error = OnboardError.NotCompatible
                            EASY_CONNECT_EVENT_FAILURE_CONFIGURATION ->
                                error = OnboardError.MalformedMessage
                            EASY_CONNECT_EVENT_FAILURE_BUSY -> error = OnboardError.Busy
                            EASY_CONNECT_EVENT_FAILURE_TIMEOUT -> error = OnboardError.Timeout
                            EASY_CONNECT_EVENT_FAILURE_GENERIC ->
                                error = OnboardError.ProtocolFailure
                            EASY_CONNECT_EVENT_FAILURE_NOT_SUPPORTED -> {
                                error = OnboardError.NotSupported
                                errorInfo = mapOf("origin" to "from ActivityResult")
                            }
                            EASY_CONNECT_EVENT_FAILURE_INVALID_NETWORK ->
                                error = OnboardError.InvalidNetwork
                            EASY_CONNECT_EVENT_FAILURE_CANNOT_FIND_NETWORK ->
                                error = OnboardError.CannotFindNetwork
                            EASY_CONNECT_EVENT_FAILURE_ENROLLEE_AUTHENTICATION ->
                                error = OnboardError.AuthenticationFailure
                            EASY_CONNECT_EVENT_FAILURE_ENROLLEE_REJECTED_CONFIGURATION ->
                                error = OnboardError.EnrolleeRejected
                            else -> {
                                error = OnboardError.UnknownFailure
                                errorInfo = mapOf("error_code" to errorCode)
                            }
                        }
                        // set errorInfo - R2 enrollee provides additional failure info
                        if (errorInfo == null) errorInfo = mapOf()
                        // - attempted ssid
                        if (data.hasExtra(EXTRA_EASY_CONNECT_ATTEMPTED_SSID)) errorInfo.apply {
                            "ssid" to data.getStringExtra(EXTRA_EASY_CONNECT_ATTEMPTED_SSID)
                        }
                        // - channel list
                        if (data.hasExtra(EXTRA_EASY_CONNECT_CHANNEL_LIST)) errorInfo.apply {
                            "channels" to data.getStringExtra(EXTRA_EASY_CONNECT_CHANNEL_LIST)
                        }
                        // - band list
                        if (data.hasExtra(EXTRA_EASY_CONNECT_BAND_LIST)) errorInfo.apply {
                            "bands" to listOf(data.getIntArrayExtra(EXTRA_EASY_CONNECT_BAND_LIST))
                        }
                    }
                }
            }
        }

        fun send(result: Result) =
            when {
                exceptionCode != null -> result.error(
                    exceptionCode,
                    exceptionMessage,
                    exceptionDetails
                )
                error != null -> result.success(
                    mapOf(
                        "error" to OnboardError.Busy.ordinal,
                        "data" to errorInfo
                    )
                )
                else -> result.success(emptyMap<String, Any?>())
            }
    }
}
