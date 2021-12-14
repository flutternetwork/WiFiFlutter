package dev.flutternetwork.wifi.wifi_scan

import android.content.Context
import android.net.wifi.ScanResult
import android.net.wifi.WifiManager
import android.os.Build
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CanStartScan codes */
private const val CAN_START_SCAN_NOT_SUPPORTED = 0
private const val CAN_START_SCAN_YES = 1
private const val CAN_START_SCAN_NO_LOC_PERM_REQUIRED = 2
private const val CAN_START_SCAN_NO_LOC_PERM_DENIED = 3
private const val CAN_START_SCAN_NO_LOC_DISABLED = 4

/** CanGetScannedResults codes */
private const val CAN_GET_RESULTS_NOT_SUPPORTED = 0
private const val CAN_GET_RESULTS_YES = 1
private const val CAN_GET_RESULTS_NO_LOC_PERM_REQUIRED = 2
private const val CAN_GET_RESULTS_NO_LOC_PERM_DENIED = 3
private const val CAN_GET_RESULTS_NO_LOC_DISABLED = 4

/** WifiScanPlugin */
class WifiScanPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var wifi: WifiManager? = null


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_scan")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        wifi =
            context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        // TODO: handle wifi_scan/scannedNetworksEvent eventChannel
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "canStartScan" -> {
                val askPermission = call.argument<Boolean>("askPermissions") ?: return result.error(
                    "InvalidArg",
                    "askPermissions argument is null",
                    null
                )
                result.success(canStartScan(askPermission))
            }
            "startScan" -> result.success(startScan())
            "canGetScannedNetworks" -> {
                val askPermission = call.argument<Boolean>("askPermissions") ?: return result.error(
                    "InvalidArg",
                    "askPermissions argument is null",
                    null
                )
                result.success(canGetScannedNetworks(askPermission))
            }
            "scannedNetworks" -> result.success(scannedNetworks())
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        wifi = null
    }

    private fun canStartScan(askPermission: Boolean): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) CAN_START_SCAN_NOT_SUPPORTED
        else {
            // TODO check if has location permission
            // TODO check if can request? return noLocPermRequired or noLocPermDenied
            // TODO else ask for permission - return yes (if granter) or noLocPermDenied
            // TODO check if location service is enabled - return yes and noLocDisabled
            CAN_START_SCAN_NOT_SUPPORTED
        }

    private fun startScan(): Boolean = wifi!!.startScan()

    // TODO
    private fun canGetScannedNetworks(askPermission: Boolean): Int =
        CAN_GET_RESULTS_NOT_SUPPORTED

    private fun scannedNetworks(): List<Map<String, Any?>> {
        return wifi!!.scanResults.map { network ->
            mapOf(
                "ssid" to network.SSID,
                "bssid" to network.BSSID,
                "capabilities" to network.capabilities,
                "frequency" to network.frequency,
                "level" to network.level,
                "timestamp" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) network.timestamp else null,
                "standard" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) network.wifiStandard else null,
                "centerFrequency0" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) network.centerFreq0 else null,
                "centerFrequency1" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) network.centerFreq1 else null,
                "channelWidth" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) network.channelWidth else null,
                "isPasspoint" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) network.isPasspointNetwork else null,
                "operatorFriendlyName" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) network.operatorFriendlyName else null,
                "venueName" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) network.venueName else null,
                "is80211mcResponder" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) network.is80211mcResponder else null,
            )
        }
    }
}
