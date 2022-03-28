package dev.flutternetwork.wifi.wifi_scan

import android.Manifest
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.location.LocationManager
import android.net.wifi.WifiManager
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.location.LocationManagerCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlin.random.Random

/** Error Codes */
private const val ERROR_INVALID_ARGS = "InvalidArgs"
private const val ERROR_NULL_ACTIVITY = "NullActivity"

/** StartScanError codes */
private const val ERROR_START_SCAN_NOT_SUPPORTED = 0
private const val ERROR_START_SCAN_NO_LOC_PERM_REQUIRED = 1
private const val ERROR_START_SCAN_NO_LOC_PERM_DENIED = 2
private const val ERROR_START_SCAN_NO_LOC_PERM_UPGRADE_ACCURACY = 3
private const val ERROR_START_SCAN_NO_LOC_DISABLED = 4
private const val ERROR_START_SCAN_FAILED = 5

/** GetScannedResultsError codes */
private const val ERROR_GET_RESULTS_NOT_SUPPORTED = 0
private const val ERROR_GET_RESULTS_NO_LOC_PERM_REQUIRED = 1
private const val ERROR_GET_RESULTS_NO_LOC_PERM_DENIED = 2
private const val ERROR_GET_RESULTS_NO_LOC_PERM_UPGRADE_ACCURACY = 3
private const val ERROR_GET_RESULTS_NO_LOC_DISABLED = 4

/** Magic codes */
private const val ASK_FOR_LOC_PERM = -1

/** WifiScanPlugin
 *
 * Useful links:
 * - https://developer.android.com/guide/topics/connectivity/wifi-scan
 * - https://developer.android.com/reference/android/net/wifi/WifiManager
 * - https://developer.android.com/reference/android/net/wifi/ScanResult
 * - https://developer.android.com/training/location/permissions
 * */
class WifiScanPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.RequestPermissionsResultListener, EventChannel.StreamHandler {
    private val logTag = javaClass.simpleName
    private lateinit var context: Context
    private var activity: Activity? = null
    private var wifi: WifiManager? = null
    private var wifiScanReceiver: BroadcastReceiver? = null
    private val requestPermissionCookie = mutableMapOf<Int, (grantResults: IntArray) -> Boolean>()
    private val locationPermissionCoarse = arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION)
    private val locationPermissionFine = arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)
    private val locationPermissionBoth = locationPermissionCoarse + locationPermissionFine

    // plugin interfaces
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel

    // single sink - to send
    private var eventSink: EventSink? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        wifi = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        // set broadcast receiver - listening for new scannedResults
        wifiScanReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.getBooleanExtra(WifiManager.EXTRA_RESULTS_UPDATED, false)) {
                    onScannedResultsAvailable()
                }
            }
        }
        val intentFilter = IntentFilter()
        intentFilter.addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
        context.registerReceiver(wifiScanReceiver, intentFilter)

        // set Flutter channels - 1 for method, 1 for event
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_scan")
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "wifi_scan/onScannedResultsAvailable"
        )
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink?.endOfStream()
        eventSink = null
        wifi = null
        context.unregisterReceiver(wifiScanReceiver)
        wifiScanReceiver = null
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
        // put the current available results - to start with
        onScannedResultsAvailable()
    }

    override fun onCancel(arguments: Any?) {
        eventSink?.endOfStream()
        eventSink = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "startScan" -> {
                val askPermission = call.argument<Boolean>("askPermissions") ?: return result.error(
                    ERROR_INVALID_ARGS,
                    "askPermissions argument is null",
                    null
                )
                val errorCode = startScan(askPermission)
                // if not ASK_FOR_LOC_PERM, send result
                // else ask for permission - wait for user action - return result based on it
                if (errorCode != ASK_FOR_LOC_PERM) {
                    result.success(errorCode)
                } else {
                    askForLocationPermission { askResult ->
                        when (askResult) {
                            AskLocPermResult.GRANTED -> {
                                result.success(startScan(askPermission = false))
                            }
                            AskLocPermResult.UPGRADE_TO_FINE -> {
                                result.success(ERROR_START_SCAN_NO_LOC_PERM_UPGRADE_ACCURACY)
                            }
                            AskLocPermResult.DENIED -> {
                                result.success(ERROR_START_SCAN_NO_LOC_PERM_DENIED)
                            }
                            AskLocPermResult.ERROR_NO_ACTIVITY -> {
                                result.error(
                                    ERROR_NULL_ACTIVITY,
                                    "Cannot ask for location permission.",
                                    "Looks like called from non-Activity."
                                )
                            }
                        }
                    }
                }
            }
            "getScannedResults" -> {
                val askPermission = call.argument<Boolean>("askPermissions") ?: return result.error(
                    ERROR_INVALID_ARGS,
                    "askPermissions argument is null",
                    null
                )
                val mResult = getScannedResults(askPermission)
                // if error != ASK_FOR_LOC_PERM, send result
                // else ask for permission - wait for user action - return result based on it
                if (mResult["error"] != ASK_FOR_LOC_PERM) {
                    result.success(mResult)
                } else {
                    askForLocationPermission { askResult ->
                        when (askResult) {
                            AskLocPermResult.GRANTED -> {
                                result.success(getScannedResults(askPermission = false))
                            }
                            AskLocPermResult.UPGRADE_TO_FINE -> {
                                result.success(errorResult(ERROR_GET_RESULTS_NO_LOC_PERM_UPGRADE_ACCURACY))
                            }
                            AskLocPermResult.DENIED -> {
                                result.success(errorResult(ERROR_GET_RESULTS_NO_LOC_PERM_DENIED))
                            }
                            AskLocPermResult.ERROR_NO_ACTIVITY -> {
                                result.error(
                                    ERROR_NULL_ACTIVITY,
                                    "Cannot ask for location permission.",
                                    "Looks like called from non-Activity."
                                )
                            }
                        }
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?
    ): Boolean {
        Log.d(
            logTag,
            "onRequestPermissionsResult: arguments ($requestCode, $permissions, $grantResults)"
        )
        if (grantResults != null) {
            Log.d(logTag, "requestPermissionCookie: $requestPermissionCookie")
            return requestPermissionCookie[requestCode]?.invoke(grantResults) ?: false
        }
        return false
    }

    private fun startScan(askPermission: Boolean): Int? {
        val hasLocPerm = hasLocationPermission()
        val isLocEnabled = isLocationEnabled()
        // check all prerequisite conditions for startScan
        val errorCode = when {
            // for SDK < P[28] : Not in guide, should not require any additional permissions
            Build.VERSION.SDK_INT < Build.VERSION_CODES.P -> null
            // for SDK >= Q[29]: CHANGE_WIFI_STATE & ACCESS_x_LOCATION & "Location enabled"
            hasLocPerm && isLocEnabled -> null
            hasLocPerm -> ERROR_START_SCAN_NO_LOC_DISABLED
            askPermission -> ASK_FOR_LOC_PERM
            else -> ERROR_START_SCAN_NO_LOC_PERM_REQUIRED
        }
        // if any errorCode then return it
        if (errorCode != null) return errorCode

        // call startScan API - if failed then return ERROR_START_SCAN_FAILED
        return if (wifi!!.startScan()) null else ERROR_START_SCAN_FAILED
    }

    private fun getScannedResults(askPermission: Boolean): Map<String, Any?> {
        // check all prerequisite conditions
        // ACCESS_WIFI_STATE & ACCESS_x_LOCATION & "Location enabled"
        val hasLocPerm = hasLocationPermission()
        val isLocEnabled = isLocationEnabled()
        val errorCode = when {
            hasLocPerm && isLocEnabled -> null
            hasLocPerm -> ERROR_GET_RESULTS_NO_LOC_DISABLED
            askPermission -> ASK_FOR_LOC_PERM
            else -> ERROR_GET_RESULTS_NO_LOC_PERM_REQUIRED
        }

        // if any errorCode then return it
        if (errorCode != null) return errorResult(errorCode)

        // return scannedResults
        return mapOf("value" to wifi!!.scanResults.map { ap ->
            mapOf(
                "ssid" to ap.SSID,
                "bssid" to ap.BSSID,
                "capabilities" to ap.capabilities,
                "frequency" to ap.frequency,
                "level" to ap.level,
                "timestamp" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) ap.timestamp else null,
                "standard" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) ap.wifiStandard else null,
                "centerFrequency0" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) ap.centerFreq0 else null,
                "centerFrequency1" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) ap.centerFreq1 else null,
                "channelWidth" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) ap.channelWidth else null,
                "isPasspoint" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) ap.isPasspointNetwork else null,
                "operatorFriendlyName" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) ap.operatorFriendlyName else null,
                "venueName" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) ap.venueName else null,
                "is80211mcResponder" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) ap.is80211mcResponder else null
            )
        })
    }

    private fun onScannedResultsAvailable() {
        eventSink?.success(getScannedResults(askPermission = false))
    }

    /**
     * ACCESS_FINE_LOCATION required for: SDK >= Q[29] and tSDK >= Q[29]
     */
    private fun requiresFineLocation(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && context.applicationInfo.targetSdkVersion >= Build.VERSION_CODES.Q

    private fun hasLocationPermission(): Boolean {
        val permissions = when {
            requiresFineLocation() -> locationPermissionFine
            else -> locationPermissionBoth
        }
        return permissions.any { permission ->
            ContextCompat.checkSelfPermission(
                context,
                permission
            ) == PackageManager.PERMISSION_GRANTED
        }
    }

    private enum class AskLocPermResult {
        GRANTED, UPGRADE_TO_FINE, DENIED, ERROR_NO_ACTIVITY
    }

    private fun askForLocationPermission(callback: (AskLocPermResult) -> Unit) {
        // check if has activity - return error if null
        if (activity == null) return callback.invoke(AskLocPermResult.ERROR_NO_ACTIVITY)
        // make permissions
        val requiresFine = requiresFineLocation()
        // - for SDK > R[30] - cannot only ask for FINE
        val requiresFineButAskBoth = requiresFine && Build.VERSION.SDK_INT > Build.VERSION_CODES.R
        val permissions = when {
            requiresFineButAskBoth -> locationPermissionBoth
            requiresFine -> locationPermissionFine
            else -> locationPermissionCoarse
        }
        // request permission - add result-handler in requestPermissionCookie
        val permissionCode = 6567800 + Random.Default.nextInt(100)
        requestPermissionCookie[permissionCode] = { grantArray ->
            // invoke callback with proper askResult
            Log.d(logTag, "permissionResultCallback: args($grantArray)")
            callback.invoke(
                when {
                    // GRANTED: if all granted
                    grantArray.all { it == PackageManager.PERMISSION_GRANTED } -> {
                        AskLocPermResult.GRANTED
                    }
                    // UPGRADE_TO_FINE: if requiresFineButAskBoth and COARSE granted
                    requiresFineButAskBoth && grantArray.first() == PackageManager.PERMISSION_GRANTED -> {
                        AskLocPermResult.UPGRADE_TO_FINE
                    }
                    else -> AskLocPermResult.DENIED
                }
            )
            true
        }
        ActivityCompat.requestPermissions(activity!!, permissions, permissionCode)
    }

    private fun isLocationEnabled(): Boolean =
        LocationManagerCompat.isLocationEnabled(
            context.applicationContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        )

   private fun errorResult(code: Int): Map<String, Int> = mapOf("error" to code)
}
