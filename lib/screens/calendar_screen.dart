import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event_attendance.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/admin_attendance_screen.dart';
import 'package:flutter_application_1/screens/file_preview_screen.dart';
import 'package:flutter_application_1/services/attendance_service.dart';
import 'package:flutter_application_1/services/file_service.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/event_model.dart';
import '../services/event_service.dart';
import 'create_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final EventService _eventService = EventService();
  final AttendanceService _attendanceService = AttendanceService();
  final FileService _fileService = FileService();
  User? get currentUser => FirebaseAuth.instance.currentUser;

  bool get isDeputy => currentUser != null && _userData?.isDeputy == true;
  bool get isAdmin => currentUser != null && _userData?.isAdmin == true;

  AppUser? _userData;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
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
        title: const Text('Календарь мероприятий'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Мероприятия на ${_formatDate(_selectedDay!)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildEventList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewEvent(),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Неделя',
          CalendarFormat.twoWeeks: 'Месяц',
          CalendarFormat.week: '2 недели',
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Color(0xFF2E7D32),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    if (_selectedDay == null) return const SizedBox();

    return StreamBuilder<List<CalendarEvent>>(
      stream: _eventService.getEventsForDate(_selectedDay!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'На этот день мероприятий нет',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final events = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventItem(event);
          },
        );
      },
    );
  }

  Widget _buildEventItem(CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: event.type.color, // Убрана проверка на isCancelled
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
            ),
            if (event.location.isNotEmpty)
              Text(event.location, style: const TextStyle(fontSize: 12)),
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
                    return Chip(
                      label: Text(
                        attendance.status.displayName,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: attendance.status.color,
                      visualDensity: VisualDensity.compact,
                    );
                  }
                  return const SizedBox();
                },
              ),
          ],
        ),
        onTap: () => _showEventDetails(event), // Убрана проверка на isCancelled
      ),
    );
  }

  // Добавьте этот отсутствующий метод
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
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  void _addNewEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(selectedDate: _selectedDay!),
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
      // Для других пользователей - показываем старый диалог
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
}
