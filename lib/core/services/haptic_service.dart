import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HapticService {
  Future<bool> get canVibrate async => await Vibration.hasVibrator() ?? false;

  Future<void> lightImpact() async {
    if (await canVibrate) {
      await Vibration.vibrate(
        duration: 20,
        amplitude: 10,
      );
    }
  }

  Future<void> mediumImpact() async {
    if (await canVibrate) {
      await Vibration.vibrate(
        duration: 40,
        amplitude: 50,
      );
    }
  }

  Future<void> heavyImpact() async {
    if (await canVibrate) {
      await Vibration.vibrate(
        duration: 60,
        amplitude: 100,
      );
    }
  }

  Future<void> selectionChanged() async {
    if (await canVibrate) {
      await Vibration.vibrate(
        duration: 10,
        amplitude: 5,
      );
    }
  }

  Future<void> taskCompleted() async {
    if (await canVibrate) {
      await Vibration.vibrate(
        pattern: [0, 30, 50, 30],
        amplitude: 100,
      );
    }
  }

  Future<void> taskCreated() async {
    if (await canVibrate) {
      await Vibration.vibrate(
        pattern: [0, 20, 30, 20],
        amplitude: 80,
      );
    }
  }

  Future<void> errorOccurred() async {
    if (await canVibrate) {
      await Vibration.vibrate(
        pattern: [0, 50, 30, 50],
        amplitude: 100,
      );
    }
  }
}

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});
