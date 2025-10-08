import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/event_service.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/models/event_model.dart';

// Генерировать mock классы командой: flutter packages pub run build_runner build
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  DocumentSnapshot,
  QuerySnapshot,
  CollectionReference,
  DocumentReference,
])
import 'test_helpers.mocks.dart';

// Mock данные для тестов
final mockUser = AppUser(
  uid: 'test_uid',
  name: 'Тестовый Пользователь',
  email: 'test@test.com',
  isDeputy: false,
  isAdmin: false,
  createdAt: DateTime.now(),
);

final mockAdmin = AppUser(
  uid: 'admin_uid',
  name: 'Администратор',
  email: 'admin@test.com',
  isDeputy: false,
  isAdmin: true,
  createdAt: DateTime.now(),
);

final mockDeputy = AppUser(
  uid: 'deputy_uid',
  name: 'Тестовый Депутат',
  email: 'deputy@test.com',
  isDeputy: true,
  isAdmin: false,
  createdAt: DateTime.now(),
);

final mockEvent = CalendarEvent(
  id: 'event_id',
  title: 'Тестовое мероприятие',
  description: 'Описание мероприятия',
  startTime: DateTime(2025, 10, 15, 10, 0),
  endTime: DateTime(2025, 10, 15, 12, 0),
  location: 'Конференц-зал',
  type: EventType.meeting,
  deputyId: 'deputy_uid',
  createdBy: 'test_uid',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Утилита для создания тестового виджета с провайдерами
Widget createTestWidget(Widget child, {
  AuthService? authService,
  EventService? eventService,
}) {
  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(
          value: authService ?? MockAuthService(),
        ),
        Provider<EventService>.value(
          value: eventService ?? MockEventService(),
        ),
      ],
      child: child,
    ),
  );
}

// Утилита для создания материального приложения без провайдеров
Widget createMaterialTestWidget(Widget child) {
  return MaterialApp(
    home: child,
  );
}

// Mock AuthService
class MockAuthService extends Mock implements AuthService {
  AppUser? _currentUser;
  bool _isLoading = false;

  MockAuthService({AppUser? user}) : _currentUser = user ?? mockUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  bool get isLoading => _isLoading;

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(_currentUser);

  @override
  Future<AppUser?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(Duration(milliseconds: 100));
    
    _currentUser = mockUser;
    _isLoading = false;
    notifyListeners();
    
    return _currentUser;
  }

  @override
  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String name,
    bool isDeputy = false,
    bool isAdmin = false,
    String? phone,
    String? department,
    String? deputyId,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(Duration(milliseconds: 100));
    
    _currentUser = AppUser(
      uid: 'new_user_uid',
      name: name,
      email: email,
      isDeputy: isDeputy,
      isAdmin: isAdmin,
      phone: phone,
      department: department,
      deputyId: deputyId,
      createdAt: DateTime.now(),
    );
    _isLoading = false;
    notifyListeners();
    
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? department,
    String? deputyId,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        department: department ?? _currentUser!.department,
        deputyId: deputyId ?? _currentUser!.deputyId,
      );
      notifyListeners();
    }
  }
}

// Mock EventService
class MockEventService extends Mock implements EventService {
  List<CalendarEvent> _events = [mockEvent];
  List<AppUser> _deputies = [mockDeputy];

  @override
  Stream<List<CalendarEvent>> getEvents() {
    return Stream.value(_events);
  }

  @override
  Stream<List<CalendarEvent>> getEventsForDate(DateTime date) {
    final eventsForDate = _events.where((event) {
      return event.startTime.year == date.year &&
             event.startTime.month == date.month &&
             event.startTime.day == date.day;
    }).toList();
    return Stream.value(eventsForDate);
  }

  @override
  Stream<List<AppUser>> getDeputies() {
    return Stream.value(_deputies);
  }

  @override
  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime dateTime,
    required String location,
    required String deputyId,
    required EventType type,
    String? notes,
  }) async {
    final newEvent = CalendarEvent(
      id: 'new_event_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      startTime: dateTime,
      endTime: dateTime.add(Duration(hours: 1)),
      location: location,
      type: type,
      deputyId: deputyId,
      createdBy: 'current_user_uid',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: notes,
    );
    _events.add(newEvent);
  }

  @override
  Future<void> updateEvent(String eventId, {
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    EventType? type,
    String? notes,
  }) async {
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      final event = _events[index];
      _events[index] = event.copyWith(
        title: title ?? event.title,
        description: description ?? event.description,
        startTime: dateTime ?? event.startTime,
        location: location ?? event.location,
        type: type ?? event.type,
        notes: notes ?? event.notes,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((event) => event.id == eventId);
  }
}

// Расширения для AppUser
extension AppUserCopyWith on AppUser {
  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    bool? isDeputy,
    bool? isAdmin,
    String? phone,
    String? department,
    String? deputyId,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      isDeputy: isDeputy ?? this.isDeputy,
      isAdmin: isAdmin ?? this.isAdmin,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      deputyId: deputyId ?? this.deputyId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Расширения для CalendarEvent
extension CalendarEventCopyWith on CalendarEvent {
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

// Вспомогательные матчеры для тестов
class IsDateTimeMatcher extends Matcher {
  final DateTime expectedDate;
  
  const IsDateTimeMatcher(this.expectedDate);
  
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! DateTime) return false;
    return item.year == expectedDate.year &&
           item.month == expectedDate.month &&
           item.day == expectedDate.day;
  }
  
  @override
  Description describe(Description description) {
    return description.add('matches date $expectedDate');
  }
}

Matcher isDate(DateTime date) => IsDateTimeMatcher(date);