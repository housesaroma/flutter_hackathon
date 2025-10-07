import 'package:flutter/material.dart';

enum EventType {
  meeting('Встреча', Colors.blue),
  session('Заседание', Colors.green),
  reception('Прием', Colors.orange),
  other('Другое', Colors.grey);

  final String displayName;
  final Color color;

  const EventType(this.displayName, this.color);
}

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final EventType type;
  final String deputyId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    required this.deputyId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory CalendarEvent.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    final typeString = map['type'] ?? 'other';
    final eventType = EventType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => EventType.other,
    );

    return CalendarEvent(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      location: map['location'] ?? '',
      type: eventType,
      deputyId: map['deputyId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'location': location,
      'type': type.name,
      'deputyId': deputyId,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      if (notes != null) 'notes': notes,
    };
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    EventType? type,
    String? deputyId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      deputyId: deputyId ?? this.deputyId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}
