import 'dart:async';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

enum ThermalState { normal, warning, critical }

/// Intervenes when the phone overheats from running concurrent 4K AI models.
/// Automatically alters application state to save the battery and prevent hardware shutdown.
@lazySingleton
class ThermalManagementService {
  static const MethodChannel _thermalChannel = MethodChannel('com.example.xingcam/thermal');
  
  ThermalState _currentState = ThermalState.normal;
  ThermalState get currentState => _currentState;

  /// When critical, frame rates must drop from 120Hz to 60Hz.
  int get safeFpsLimit => _currentState == ThermalState.critical ? 60 : 120;
  
  /// When critical, ML Matrix operations must be executed at FP16 or INT8 instead of FP32.
  bool get requiresPrecisionDowngrade => _currentState != ThermalState.normal;

  void startHardwareMonitoring() {
    // In production, iOS ProcessInfo.thermalState or Android PowerManager is queried.
    Timer.periodic(const Duration(seconds: 15), (timer) async {
      try {
        // Querying custom MethodChannel (Implementation required in Native MainActivity)
        final int temperatureCelsius = await _thermalChannel.invokeMethod('getDeviceTemperature');
        
        if (temperatureCelsius >= 45) {
          _currentState = ThermalState.critical;
        } else if (temperatureCelsius >= 38) {
          _currentState = ThermalState.warning;
        } else {
          _currentState = ThermalState.normal;
        }
      } catch (e) {
        // Graceful fallback if sensors are unavailable
        _currentState = ThermalState.normal;
      }
    });
  }
}
