import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получить тип текущего пользователя
  Future<Map<String, dynamic>> _getCurrentUserType() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Требуется авторизация');

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) throw Exception('Пользователь не найден');

    final userData = userDoc.data();
    if (userData == null) throw Exception('Данные пользователя не найдены');

    return {
      'isAdmin': userData['isAdmin'] ?? false,
      'isDeputy': userData['isDeputy'] ?? false,
      'deputyId': userData['deputyId'],
      'uid': user.uid,
    };
  }

  // Получить все события с учетом прав доступа - ИСПРАВЛЕННАЯ ВЕРСИЯ
  Stream<List<CalendarEvent>> getEvents() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(<CalendarEvent>[]);

      return _firestore.collection('users').doc(user.uid).snapshots().asyncMap((
        userDoc,
      ) async {
        if (!userDoc.exists) return <CalendarEvent>[];

        final userData = userDoc.data();
        if (userData == null) return <CalendarEvent>[];

        final isAdmin = userData['isAdmin'] ?? false;
        final isDeputy = userData['isDeputy'] ?? false;
        final deputyId = userData['deputyId'];

        Query eventsQuery = _firestore.collection('events');

        if (isAdmin) {
          // Администратор видит все мероприятия
          eventsQuery = eventsQuery.orderBy('startTime', descending: false);
        } else if (isDeputy) {
          // Депутат видит свои мероприятия
          eventsQuery = eventsQuery
              .where('deputyId', isEqualTo: user.uid)
              .orderBy('startTime', descending: false);
        } else {
          // Помощник видит мероприятия своего депутата
          if (deputyId != null) {
            eventsQuery = eventsQuery
                .where('deputyId', isEqualTo: deputyId)
                .orderBy('startTime', descending: false);
          } else {
            // Если помощник не привязан к депутату, не показываем мероприятия
            return <CalendarEvent>[];
          }
        }

        try {
          final eventsSnapshot = await eventsQuery.get();
          return eventsSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CalendarEvent.fromMap(data, id: doc.id);
          }).toList();
        } catch (e) {
          print('Ошибка загрузки мероприятий: $e');
          return <CalendarEvent>[];
        }
      });
    });
  }

  // Получить события на определенную дату с учетом прав доступа - ИСПРАВЛЕННАЯ ВЕРСИЯ
  Stream<List<CalendarEvent>> getEventsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(<CalendarEvent>[]);

      return _firestore.collection('users').doc(user.uid).snapshots().asyncMap((
        userDoc,
      ) async {
        if (!userDoc.exists) return <CalendarEvent>[];

        final userData = userDoc.data();
        if (userData == null) return <CalendarEvent>[];

        final isAdmin = userData['isAdmin'] ?? false;
        final isDeputy = userData['isDeputy'] ?? false;
        final deputyId = userData['deputyId'];

        Query eventsQuery = _firestore
            .collection('events')
            .where(
              'startTime',
              isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch,
            )
            .where(
              'startTime',
              isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch,
            );

        if (isAdmin) {
          // Администратор видит все мероприятия на дату
          eventsQuery = eventsQuery.orderBy('startTime', descending: false);
        } else if (isDeputy) {
          // Депутат видит свои мероприятия на дату
          eventsQuery = eventsQuery
              .where('deputyId', isEqualTo: user.uid)
              .orderBy('startTime', descending: false);
        } else {
          // Помощник видит мероприятия своего депутата на дату
          if (deputyId != null) {
            eventsQuery = eventsQuery
                .where('deputyId', isEqualTo: deputyId)
                .orderBy('startTime', descending: false);
          } else {
            // Если помощник не привязан к депутату, не показываем мероприятия
            return <CalendarEvent>[];
          }
        }

        try {
          final eventsSnapshot = await eventsQuery.get();
          return eventsSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CalendarEvent.fromMap(data, id: doc.id);
          }).toList();
        } catch (e) {
          print('Ошибка загрузки мероприятий на дату: $e');
          return <CalendarEvent>[];
        }
      });
    });
  }

  // Создать событие
  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime dateTime,
    required String location,
    required String deputyId,
    EventType type = EventType.meeting,
    String? notes,
    List<EventAttachment> attachments = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Требуется авторизация');

    final userType = await _getCurrentUserType();
    final isAdmin = userType['isAdmin'];
    final isDeputy = userType['isDeputy'];
    final userDeputyId = userType['deputyId'];

    if (!isAdmin) {
      if (isDeputy) {
        if (deputyId != user.uid) {
          throw Exception(
            'Депутат может создавать мероприятия только для себя',
          );
        }
      } else {
        if (deputyId != userDeputyId) {
          throw Exception(
            'Помощник может создавать мероприятия только для своего депутата',
          );
        }
      }
    }

    final event = CalendarEvent(
      id: _firestore.collection('events').doc().id,
      title: title,
      description: description,
      startTime: dateTime,
      endTime: dateTime.add(const Duration(hours: 1)),
      location: location,
      type: type,
      deputyId: deputyId,
      createdBy: user.uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: notes,
      attachments: attachments,
    );

    await _firestore.collection('events').doc(event.id).set(event.toMap());
  }

  // Обновить событие
  Future<void> updateEvent(CalendarEvent event) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Требуется авторизация');

    final eventDoc = await _firestore.collection('events').doc(event.id).get();
    if (!eventDoc.exists) throw Exception('Событие не найдено');

    final eventData = eventDoc.data();
    if (eventData == null) throw Exception('Данные события не найдены');

    final currentEvent = CalendarEvent.fromMap(eventData, id: eventDoc.id);
    final userType = await _getCurrentUserType();
    final isAdmin = userType['isAdmin'];

    if (!isAdmin) {
      final userDeputyId = userType['isDeputy']
          ? user.uid
          : userType['deputyId'];
      if (currentEvent.deputyId != userDeputyId) {
        throw Exception('Нет прав для редактирования этого мероприятия');
      }
      if (currentEvent.deputyId != event.deputyId) {
        throw Exception('Нельзя изменить депутата для мероприятия');
      }
    }

    final updatedEvent = event.copyWith(updatedAt: DateTime.now());
    await _firestore
        .collection('events')
        .doc(updatedEvent.id)
        .update(updatedEvent.toMap());
  }

  // Удалить событие
  Future<void> deleteEvent(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Требуется авторизация');

    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    if (!eventDoc.exists) throw Exception('Событие не найдено');

    final eventData = eventDoc.data();
    if (eventData == null) throw Exception('Данные события не найдены');

    final event = CalendarEvent.fromMap(eventData, id: eventDoc.id);
    final userType = await _getCurrentUserType();
    final isAdmin = userType['isAdmin'];
    final isDeputy = userType['isDeputy'];
    final userDeputyId = userType['deputyId'];

    // Проверка прав доступа
    if (!isAdmin) {
      if (isDeputy) {
        // Депутат может удалять только свои мероприятия
        if (event.deputyId != user.uid) {
          throw Exception('Депутат может удалять только свои мероприятия');
        }
      } else {
        // Помощник может удалять мероприятия своего депутата
        if (event.deputyId != userDeputyId) {
          throw Exception(
            'Помощник может удалять только мероприятия своего депутата',
          );
        }
      }
    }

    await _firestore.collection('events').doc(eventId).delete();
  }

  // Получить список депутатов
  Stream<List<AppUser>> getDeputies() {
    return _firestore
        .collection('users')
        .where('isDeputy', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return AppUser.fromMap(data);
          }).toList(),
        );
  }

  // Получить мероприятия конкретного депутата
  Stream<List<CalendarEvent>> getEventsForDeputy(String deputyId) {
    return _firestore
        .collection('events')
        .where('deputyId', isEqualTo: deputyId)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return CalendarEvent.fromMap(data, id: doc.id);
          }).toList(),
        );
  }
}
