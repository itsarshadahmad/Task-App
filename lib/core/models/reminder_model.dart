import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'reminder_model.freezed.dart';
part 'reminder_model.g.dart';

@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required DateTime dateTime,
    required String type,
    String? title,
    String? taskId,
    @Default(false) bool isDismissed,
    @Default(0) int repeatInterval,
    String? repeatUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool notifyBefore,
    @Default(15) int notifyMinutesBefore,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);

  static Reminder create({
    required DateTime dateTime,
    required String type,
    String? title,
    String? taskId,
    bool notifyBefore = true,
    int notifyMinutesBefore = 15,
  }) {
    return Reminder(
      id: const Uuid().v4(),
      dateTime: dateTime,
      type: type,
      title: title,
      taskId: taskId,
      notifyBefore: notifyBefore,
      notifyMinutesBefore: notifyMinutesBefore,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  DateTime? get notificationTime {
    if (!notifyBefore) return null;
    return dateTime.subtract(Duration(minutes: notifyMinutesBefore));
  }

  bool get isRecurring => repeatInterval > 0 && repeatUnit != null;
}
