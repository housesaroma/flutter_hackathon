import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/event_service.dart';
import '../services/attendance_service.dart'; // Добавлен импорт
import '../services/file_service.dart';
import '../models/event_model.dart';
import '../models/event_attendance.dart';
import '../models/user_model.dart';
import 'attendance_confirmation_screen.dart';
import 'file_preview_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  final AttendanceService _attendanceService =
      AttendanceService(); // Добавлено объявление
  final FileService _fileService = FileService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isDeputy => currentUser != null && _userData?.isDeputy == true;
  bool get isAdmin => currentUser != null && _userData?.isAdmin == true;

  AppUser? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser != null) {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userData = AppUser.fromMap(userDoc.data()!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Все мероприятия'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<CalendarEvent>>(
        stream: _eventService.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Мероприятий пока нет',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventItem(event);
            },
          );
        },
      ),
    );
  }

  Widget _buildEventItem(CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: event.type.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      event.type.displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: event.type.color,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(event.startTime)} ${_formatTime(event.startTime)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              if (event.location.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      event.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],

              if (event.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // Статус явки показываем только депутату
              if (isDeputy)
                StreamBuilder<Attendance?>(
                  stream: _attendanceService.getAttendanceForEvent(
                    event.id,
                    currentUser!.uid,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final attendance = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Chip(
                          label: Text(
                            attendance.status.displayName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: attendance.status.color,
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(CalendarEvent event) {
    if (isDeputy) {
      // Для депутата - открываем экран подтверждения явки
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AttendanceConfirmationScreen(event: event),
        ),
      );
    } else {
      // Для других пользователей - показываем диалог с информацией
      _showEventDetailsDialog(event);
    }
  }

  void _showEventDetailsDialog(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Тип', event.type.displayName),
              _buildDetailRow('Дата', _formatDate(event.startTime)),
              _buildDetailRow(
                'Время',
                '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
              ),
              if (event.location.isNotEmpty)
                _buildDetailRow('Место', event.location),
              if (event.description.isNotEmpty)
                _buildDetailRow('Описание', event.description),
              if (event.attachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Прикрепленные файлы:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...event.attachments
                    .map(
                      (attachment) => ListTile(
                        leading: Text(attachment.fileIcon),
                        title: Text(attachment.name),
                        subtitle: Text(
                          _fileService.getFileSizeString(attachment.size),
                        ),
                        trailing: const Icon(Icons.visibility),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FilePreviewScreen(
                                attachment: attachment,
                                fileService: _fileService,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
