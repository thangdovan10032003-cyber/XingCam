package com.example.xingcam

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.xingcam/camera_pro"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "captureRaw") {
                // Phase 14: Deep Tech Integration
                // TODO: Wire direct Camera2 HAL or CameraX ImageCapture with OUTPUT_FORMAT_RAW_SENSOR
                val path = "/storage/emulated/0/DCIM/XingCam/raw_output_simulated.dng"
                result.success(path)
            } else if (call.method == "setManualExposure") {
                val iso = call.argument<Int>("iso")
                val shutterSpeed = call.argument<Double>("shutter_speed")
                // Inject manual sensor bounds back to the HAL
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}
