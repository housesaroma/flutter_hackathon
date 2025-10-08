// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('Login -> Navigate -> Create Event -> Logout', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Splash Screen
      expect(find.text('Загрузка...'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Login Screen
      expect(find.text('Вход в систему'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      // Main Screen - Calendar
      expect(find.text('Календарь мероприятий'), findsOneWidget);

      // Navigate to Events
      await tester.tap(find.text('Мероприятия'));
      await tester.pumpAndSettle();
      expect(find.text('Все мероприятия'), findsOneWidget);

      // Navigate to Profile
      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();
      expect(find.text('Профиль'), findsOneWidget);

      // Navigate back to Calendar
      await tester.tap(find.text('Календарь'));
      await tester.pumpAndSettle();

      // Create Event
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Создать мероприятие'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'E2E Event');
      await tester.enterText(find.byType(TextFormField).at(1), 'E2E Description');
      await tester.enterText(find.byType(TextFormField).at(2), 'E2E Location');
      await tester.tap(find.text('Создать'));
      await tester.pumpAndSettle();

      // Verify event in Events list
      await tester.tap(find.text('Мероприятия'));
      await tester.pumpAndSettle();
      expect(find.text('E2E Event'), findsOneWidget);

      // Logout from Profile
      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выйти из системы'));
      await tester.pumpAndSettle();

      // Back to Login Screen
      expect(find.text('Вход в систему'), findsOneWidget);
    });
  });
}


// pubspec.yaml additions:
//
dev_dependencies:
//  integration_test:
//    sdk: flutter
//  flutter_test:
//    sdk: flutter

// Для запуска:
// flutter test integration_test/app_test.dart
