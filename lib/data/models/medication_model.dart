import '../../domain/entities/reminder.dart';

class MedicationModel {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String? instructions;
  final List<MedicationAlarmModel> alarms;
  final List<MedicationLogModel> logs;
  final DateTime createdAt;

  const MedicationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    this.instructions,
    this.alarms = const [],
    this.logs = const [],
    required this.createdAt,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      instructions: json['instructions'],
      alarms: json['alarms'] != null
          ? (json['alarms'] as List)
                .map((a) => MedicationAlarmModel.fromJson(a))
                .toList()
          : [],
      logs: json['logs'] != null
          ? (json['logs'] as List)
                .map((l) => MedicationLogModel.fromJson(l))
                .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      if (instructions != null) 'instructions': instructions,
    };
  }

  /// Convert to a Reminder entity for each alarm.
  List<Reminder> toReminders() {
    return alarms.map((alarm) {
      final timeParts = alarm.alarmTime.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;

      return Reminder(
        id: alarm.id,
        userId: userId,
        title: name,
        description: '$dosage - ${instructions ?? ''}',
        hour: hour,
        minute: minute,
        daysOfWeek: _parseDaysOfWeek(alarm.daysOfWeek),
        isEnabled: alarm.active,
        type: 'medication',
      );
    }).toList();
  }

  static List<int> _parseDaysOfWeek(String daysStr) {
    final dayMap = {
      'lun': 1,
      'mar': 2,
      'mie': 3,
      'jue': 4,
      'vie': 5,
      'sab': 6,
      'dom': 7,
    };
    return daysStr
        .split(',')
        .map((d) => dayMap[d.trim()] ?? 0)
        .where((d) => d > 0)
        .toList();
  }
}

class MedicationAlarmModel {
  final String id;
  final String medicationId;
  final String alarmTime;
  final String daysOfWeek;
  final bool active;

  const MedicationAlarmModel({
    required this.id,
    required this.medicationId,
    required this.alarmTime,
    required this.daysOfWeek,
    required this.active,
  });

  factory MedicationAlarmModel.fromJson(Map<String, dynamic> json) {
    return MedicationAlarmModel(
      id: json['id'].toString(),
      medicationId: json['medication_id'].toString(),
      alarmTime: json['alarm_time'] ?? '08:00',
      daysOfWeek: json['days_of_week'] ?? '',
      active: json['active'] == true || json['active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alarm_time': alarmTime,
      'days_of_week': daysOfWeek,
      'active': active,
    };
  }
}

class MedicationLogModel {
  final String id;
  final String medicationId;
  final DateTime takenAt;
  final String status; // tomado / omitido

  const MedicationLogModel({
    required this.id,
    required this.medicationId,
    required this.takenAt,
    required this.status,
  });

  factory MedicationLogModel.fromJson(Map<String, dynamic> json) {
    return MedicationLogModel(
      id: json['id'].toString(),
      medicationId: json['medication_id'].toString(),
      takenAt: json['taken_at'] != null
          ? DateTime.parse(json['taken_at'])
          : DateTime.now(),
      status: json['status'] ?? 'omitido',
    );
  }

  Map<String, dynamic> toJson() {
    return {'taken_at': takenAt.toIso8601String(), 'status': status};
  }
}
