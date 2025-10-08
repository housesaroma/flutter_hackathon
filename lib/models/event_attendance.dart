import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event_model.dart';

enum AttendanceStatus {
  pending('Ожидает ответа', Colors.grey),
  present('Явка', Colors.green),
  absent('Неявка', Colors.red);

  final String displayName;
  final Color color;

  const AttendanceStatus(this.displayName, this.color);
}

class Attendance {
  final String id;
  final String eventId;
  final String deputyId;
  final AttendanceStatus status;
  final String? reason;
  final List<EventAttachment> supportingDocuments;
  final DateTime respondedAt;
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.eventId,
    required this.deputyId,
    required this.status,
    this.reason,
    this.supportingDocuments = const [],
    required this.respondedAt,
    required this.createdAt,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    final statusString = map['status'] ?? 'pending';
    final attendanceStatus = AttendanceStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => AttendanceStatus.pending,
    );

    final documentsList = map['supportingDocuments'] != null
        ? (map['supportingDocuments'] as List)
              .map(
                (item) =>
                    EventAttachment.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <EventAttachment>[];

    return Attendance(
      id: map['id'] ?? '',
      eventId: map['eventId'] ?? '',
      deputyId: map['deputyId'] ?? '',
      status: attendanceStatus,
      reason: map['reason'],
      supportingDocuments: documentsList,
      respondedAt: DateTime.fromMillisecondsSinceEpoch(map['respondedAt']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'deputyId': deputyId,
      'status': status.name,
      if (reason != null) 'reason': reason,
      'supportingDocuments': supportingDocuments
          .map((doc) => doc.toMap())
          .toList(),
      'respondedAt': respondedAt.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
