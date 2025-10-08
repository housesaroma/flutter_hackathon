// attendance_confirmation_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/attendance_service.dart';
import '../services/file_service.dart';
import '../models/event_model.dart';
import '../models/event_attendance.dart';

class AttendanceConfirmationScreen extends StatefulWidget {
  final CalendarEvent event;

  const AttendanceConfirmationScreen({super.key, required this.event});

  @override
  State<AttendanceConfirmationScreen> createState() =>
      _AttendanceConfirmationScreenState();
}

class _AttendanceConfirmationScreenState
    extends State<AttendanceConfirmationScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final FileService _fileService = FileService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AttendanceStatus _selectedStatus = AttendanceStatus.pending;
  String _reason = '';
  final List<EventAttachment> _supportingDocuments = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подтверждение явки'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventInfo(),
            const SizedBox(height: 24),
            _buildStatusSelector(),
            const SizedBox(height: 16),
            if (_selectedStatus == AttendanceStatus.absent) ...[
              _buildReasonField(),
              const SizedBox(height: 16),
              _buildDocumentsSection(),
            ],
            const Spacer(),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Дата: ${_formatDate(widget.event.startTime)}'),
            Text('Время: ${_formatTime(widget.event.startTime)}'),
            if (widget.event.location.isNotEmpty)
              Text('Место: ${widget.event.location}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Подтвердите ваше участие:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: AttendanceStatus.values.map((status) {
            if (status == AttendanceStatus.pending) return const SizedBox();

            return ChoiceChip(
              label: Text(status.displayName),
              selected: _selectedStatus == status,
              selectedColor: status.color,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedStatus = status;
                    if (status != AttendanceStatus.absent) {
                      _reason = '';
                      _supportingDocuments.clear();
                    }
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Причина неявки',
        hintText: 'Укажите уважительную причину...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) => _reason = value,
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Подтверждающие документы:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addDocuments,
          icon: const Icon(Icons.attach_file),
          label: const Text('Прикрепить документы'),
        ),
        if (_supportingDocuments.isNotEmpty) ...[
          const SizedBox(height: 8),
          ..._supportingDocuments.asMap().entries.map((entry) {
            final index = entry.key;
            final doc = entry.value;
            return ListTile(
              leading: Text(doc.fileIcon),
              title: Text(doc.name),
              subtitle: Text(_fileService.getFileSizeString(doc.size)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeDocument(index),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitAttendance,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Подтвердить участие'),
      ),
    );
  }

  Future<void> _addDocuments() async {
    try {
      final files = await _fileService.pickFiles();
      if (files != null) {
        for (final file in files) {
          final attachment = await _fileService.createAttachment(file);
          setState(() {
            _supportingDocuments.add(attachment);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления документов: $e')),
      );
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _supportingDocuments.removeAt(index);
    });
  }

  Future<void> _submitAttendance() async {
    if (_selectedStatus == AttendanceStatus.absent && _reason.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Укажите причину неявки')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Получаем текущую явку или создаем новую
      final currentAttendance = await _getCurrentAttendance();

      if (currentAttendance != null) {
        await _attendanceService.updateAttendance(
          attendanceId: currentAttendance.id,
          status: _selectedStatus,
          reason: _reason,
          supportingDocuments: _supportingDocuments,
        );
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Статус явки обновлен')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Attendance?> _getCurrentAttendance() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Требуется авторизация');

    final snapshot = await _firestore
        .collection('attendances')
        .where('eventId', isEqualTo: widget.event.id)
        .where('deputyId', isEqualTo: user.uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Attendance.fromMap(snapshot.docs.first.data());
    } else {
      // Создаем новую запись
      final attendance = Attendance(
        id: _firestore.collection('attendances').doc().id,
        eventId: widget.event.id,
        deputyId: user.uid,
        status: _selectedStatus,
        reason: _reason,
        supportingDocuments: _supportingDocuments,
        respondedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('attendances')
          .doc(attendance.id)
          .set(attendance.toMap());
      return attendance;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
