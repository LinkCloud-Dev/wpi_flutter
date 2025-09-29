package com.linkpos.wpi_flutter

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** WpiFlutterPlugin */
class WpiFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null
  private var activityBinding: ActivityPluginBinding? = null

  // Pending results per channel (avoid mixing WPI & WMI)
  private var pendingWpiResult: Result? = null
  private var pendingWmiResult: Result? = null

  // Separate request codes for clarity
  private val REQ_WPI = 0x9F21
  private val REQ_WMI = 0x9F22

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wpi_flutter")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "processTransaction" -> {
        val serviceType = call.argument<String>("serviceType")
        val requestJson = call.argument<String>("requestJson")
        val sessionId = call.argument<String>("sessionId")
        val wpiVersion = call.argument<String>("wpiVersion")

        println("=== WPI Request Debug ===")
        println("Intent Action: com.worldline.payment.action.PROCESS_TRANSACTION")
        println("Service Type: $serviceType")
        println("Request JSON: $requestJson")
        println("Session ID: $sessionId")
        println("WPI Version: $wpiVersion")
        println("Activity: $activity")
        println("=========================")

        val intent = Intent("com.worldline.payment.action.PROCESS_TRANSACTION").apply {
          putExtra("WPI_SERVICE_TYPE", serviceType)
          putExtra("WPI_REQUEST", requestJson)
          putExtra("WPI_VERSION", wpiVersion)
          putExtra("WPI_SESSION_ID", sessionId)
        }

        if (pendingWpiResult != null) {
          result.error("ALREADY_IN_PROGRESS", "Another WPI operation is in progress.", null)
          return
        }
        pendingWpiResult = result
        try {
          if (activity == null) {
            // clean pending if we set it
            pendingWpiResult = null
            result.error("NO_ACTIVITY", "No foreground Activity to start Tap on Mobile.", null)
            return
          }
          activity?.startActivityForResult(intent, REQ_WPI)
          println("Intent started successfully")
        } catch (e: Exception) {
          println("Intent start failed: ${e.message}")
          result.error("INTENT_ERROR", e.message, null)
        }
      }
      "processOperation" -> {
        val serviceType = call.argument<String>("serviceType")
        val requestJson = call.argument<String>("requestJson")
        val showOverlay = call.argument<Boolean>("showOverlay") 

        println("=== WMI Request Debug ===")
        println("Intent Action: com.worldline.management.action.PROCESS_OPERATION")
        println("Service Type: $serviceType")
        println("Request JSON: $requestJson")
        println("Show Overlay: $showOverlay")
        println("Activity: $activity")
        println("=========================")

        val intent = Intent("com.worldline.management.action.PROCESS_OPERATION").apply {
          flags += Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
          putExtra("WMI_SERVICE_TYPE", serviceType)
          putExtra("WMI_REQUEST", requestJson)
          putExtra("SHOW_OVERLAY", showOverlay)
        }

        if (pendingWmiResult != null) {
          result.error("ALREADY_IN_PROGRESS", "Another WMI operation is in progress.", null)
          return
        }
        pendingWmiResult = result
        try {
          if (activity == null) {
            // clean pending if we set it
            pendingWmiResult = null
            result.error("NO_ACTIVITY", "No foreground Activity to start Tap on Mobile.", null)
            return
          }
          activity?.startActivityForResult(intent, REQ_WMI)
          println("Intent started successfully")
        } catch (e: Exception) {
          println("Intent start failed: ${e.message}")
          result.error("INTENT_ERROR", e.message, null)
        }
      }
      else -> result.notImplemented()
    }
  }


  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // ActivityAware
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    activityBinding = binding
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activityBinding?.removeActivityResultListener(this)
    activity = null
    activityBinding = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    activityBinding = binding
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
    activityBinding?.removeActivityResultListener(this)
    activity = null
    activityBinding = null
  }

  // ActivityResultListener
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    println("=== onActivityResult Debug ===")
    println("Request Code: $requestCode (WPI=$REQ_WPI, WMI=$REQ_WMI)")
    println("Result Code: $resultCode")
    println("Data: $data")
    println("pendingWpiResult: $pendingWpiResult, pendingWmiResult: $pendingWmiResult")
    println("=============================")


    when (requestCode) {
      REQ_WPI -> {
        val r = pendingWpiResult
        pendingWpiResult = null

        if (r == null) {
          println("No pending WPI result; ignoring.")
          return true
        }

        val responseMap = mutableMapOf<String, Any?>()
        responseMap["channel"] = "WPI"
        responseMap["androidResultCode"] = resultCode
        
        data?.let { intent ->
          responseMap["WPI_RESPONSE"] = intent.getStringExtra("WPI_RESPONSE")
          responseMap["WPI_SERVICE_TYPE"] = intent.getStringExtra("WPI_SERVICE_TYPE")
          responseMap["WPI_VERSION"] = intent.getStringExtra("WPI_VERSION")
          responseMap["WPI_SESSION_ID"] = intent.getStringExtra("WPI_SESSION_ID")
        }
        
        r.success(responseMap)
        return true
      }
      REQ_WMI -> {
        val r = pendingWmiResult
        pendingWmiResult = null

        if (r == null) {
          println("No pending WMI result; ignoring.")
          return true
        }

        // 简单返回所有 WMI 响应数据
        val responseMap = mutableMapOf<String, Any?>()
        responseMap["channel"] = "WMI"
        responseMap["androidResultCode"] = resultCode
        
        data?.let { intent ->
          responseMap["WMI_RESPONSE"] = intent.getStringExtra("WMI_RESPONSE")
          responseMap["WMI_SERVICE_TYPE"] = intent.getStringExtra("WMI_SERVICE_TYPE")
        }
        
        r.success(responseMap)
        return true
      }
      else -> {
        println("Request code mismatch, ignoring")
        return false
      }
    }
  }
}
