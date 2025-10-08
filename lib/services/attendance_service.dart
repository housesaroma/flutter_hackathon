import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/event_attendance.dart';
import '../models/event_model.dart';

class AttendanceService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Создать запись о явке
  Future<void> createAttendance({
    required String eventId,
    required String deputyId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Требуется авторизация');

    // Проверяем, что депутат создает явку только для себя
    if (user.uid != deputyId) {
      throw Exception('Депутат может создавать явки только для себя');
    }

    final attendance = Attendance(
      id: _firestore.collection('attendances').doc().id,
      eventId: eventId,
      deputyId: deputyId,
      status: AttendanceStatus.pending,
      respondedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('attendances')
        .doc(attendance.id)
        .set(attendance.toMap());
  }

  // Обновите метод updateAttendance
  Future<void> updateAttendance({
    required String attendanceId,
    required AttendanceStatus status,
    String? reason,
    List<EventAttachment> supportingDocuments = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Требуется авторизация');

    // Получаем текущую явку для проверки прав
    final attendanceDoc = await _firestore
        .collection('attendances')
        .doc(attendanceId)
        .get();
    if (!attendanceDoc.exists) throw Exception('Явка не найдена');

    final attendanceData = attendanceDoc.data();
    if (attendanceData == null) throw Exception('Данные явки не найдены');

    final currentAttendance = Attendance.fromMap(attendanceData);

    // Проверяем, что депутат обновляет только свою явку
    if (user.uid != currentAttendance.deputyId) {
      throw Exception('Недостаточно прав для обновления этой явки');
    }

    await _firestore.collection('attendances').doc(attendanceId).update({
      'status': status.name,
      if (reason != null) 'reason': reason,
      'supportingDocuments': supportingDocuments
          .map((doc) => doc.toMap())
          .toList(),
      'respondedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Получить явку для мероприятия и депутата
  Stream<Attendance?> getAttendanceForEvent(String eventId, String deputyId) {
    return _firestore
        .collection('attendances')
        .where('eventId', isEqualTo: eventId)
        .where('deputyId', isEqualTo: deputyId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return Attendance.fromMap(snapshot.docs.first.data());
        });
  }

  // Получить все явки для мероприятия (для админа)
  Stream<List<Attendance>> getAttendancesForEvent(String eventId) {
    return _firestore
        .collection('attendances')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Attendance.fromMap(doc.data()))
              .toList(),
        );
  }

  // Получить статистику по мероприятию
  Stream<Map<AttendanceStatus, int>> getAttendanceStats(String eventId) {
    return getAttendancesForEvent(eventId).map((attendances) {
      final stats = <AttendanceStatus, int>{};
      for (final status in AttendanceStatus.values) {
        stats[status] = attendances.where((a) => a.status == status).length;
      }
      return stats;
    });
  }

  // Отменить мероприятие
  Future<void> cancelEvent({
    required String eventId,
    required String cancellationReason,
  }) async {
    await _firestore.collection('events').doc(eventId).update({
      'isCancelled': true,
      'cancellationReason': cancellationReason,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
