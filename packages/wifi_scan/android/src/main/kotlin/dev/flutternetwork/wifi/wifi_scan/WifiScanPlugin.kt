package dev.flutternetwork.wifi.wifi_scan

import android.content.Context
import android.net.wifi.WifiManager
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CanStartScan codes */
private const val CAN_START_SCAN_NOT_SUPPORTED = 0
private const val CAN_START_SCAN_YES = 1
private const val CAN_START_SCAN_NO_LOCATION_PERMISSION_REQUIRED = 2
private const val CAN_START_SCAN_NO_LOCATION_PERMISSION_DENIED = 3
private const val CAN_START_SCAN_NO_LOCATION_SERVICE_DISABLED = 4

/** CanGetScannedResults codes */
private const val CAN_GET_SCANNED_RESULTS_NOT_SUPPORTED = 0
private const val CAN_GET_SCANNED_RESULTS_YES = 1
private const val CAN_GET_SCANNED_RESULTS_NO_LOCATION_PERMISSION_REQUIRED = 2
private const val CAN_GET_SCANNED_RESULTS_LOCATION_PERMISSION_DENIED = 3
private const val CAN_GET_SCANNED_RESULTS_LOCATION_SERVICE_DISABLED = 4

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

    // TODO
    private fun canStartScan(askPermission: Boolean): Int = CAN_START_SCAN_NOT_SUPPORTED

    // TODO
    private fun startScan(): Boolean = false

    // TODO
    private fun canGetScannedNetworks(askPermission: Boolean): Int =
        CAN_GET_SCANNED_RESULTS_NOT_SUPPORTED

    // TODO
    private fun scannedNetworks(): List<Map<String, Any>> = emptyList()
}
