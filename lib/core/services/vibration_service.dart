import 'package:flutter/services.dart';

/// Native vibration bridge used for short gameplay feedback.
class VibrationService {
  /// Creates the service.
  const VibrationService();

  static const MethodChannel _channel = MethodChannel('epic_blocks/vibration');

  /// Triggers a short vibration when available.
  Future<void> vibrate([int durationMillis = 35]) async {
    await _channel.invokeMethod<void>('vibrate', durationMillis);
  }
}
