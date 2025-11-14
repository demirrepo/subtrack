import 'package:uuid/uuid.dart';

class Settings {
  final String userId;
  final int reminderDaysBefore;

  Settings({String? userId, required this.reminderDaysBefore})
    : userId = userId ?? const Uuid().v4();

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      userId: map['userId'],
      reminderDaysBefore: map['reminderDaysBefore'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'reminderDaysBefore': reminderDaysBefore};
  }
}
