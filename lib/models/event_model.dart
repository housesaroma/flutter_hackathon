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

class EventAttachment {
  final String id;
  final String name;
  final int size;
  final String mimeType;
  final DateTime uploadedAt;
  final String fileData; // Base64 данные файла
  final String fileExtension;

  EventAttachment({
    required this.id,
    required this.name,
    required this.size,
    required this.mimeType,
    required this.uploadedAt,
    required this.fileData,
    required this.fileExtension,
  });

  factory EventAttachment.fromMap(Map<String, dynamic> map) {
    return EventAttachment(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      size: map['size'] ?? 0,
      mimeType: map['mimeType'] ?? '',
      uploadedAt: DateTime.fromMillisecondsSinceEpoch(map['uploadedAt']),
      fileData: map['fileData'] ?? '',
      fileExtension: map['fileExtension'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt.millisecondsSinceEpoch,
      'fileData': fileData,
      'fileExtension': fileExtension,
    };
  }

  bool get isImage => mimeType.startsWith('image/');
  bool get isPdf => mimeType == 'application/pdf';
  bool get isText => mimeType.contains('text');

  String get fileIcon {
    if (isImage) return '🖼️';
    if (isPdf) return '📄';
    if (isText) return '📝';
    return '📎';
  }
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
  final List<EventAttachment> attachments;

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
    this.attachments = const [],
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

    final attachmentsList = map['attachments'] != null
        ? (map['attachments'] as List)
              .map(
                (item) =>
                    EventAttachment.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <EventAttachment>[];

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
      attachments: attachmentsList,
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
      'attachments': attachments
          .map((attachment) => attachment.toMap())
          .toList(),
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
    List<EventAttachment>? attachments,
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
      attachments: attachments ?? this.attachments,
    );
  }
}
