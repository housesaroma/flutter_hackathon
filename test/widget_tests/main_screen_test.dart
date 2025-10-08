import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/screens/calendar_screen.dart';
import 'package:flutter_application_1/screens/events_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import '../test_helpers.dart';

void main() {
  group('MainScreen Widget Tests', () {
    testWidgets('должен отображать нижнюю панель навигации с тремя вкладками', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      // Проверяем наличие BottomNavigationBar
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Проверяем все вкладки
      expect(find.text('Календарь'), findsOneWidget);
      expect(find.text('Мероприятия'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
      
      // Проверяем иконки
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('должен показывать CalendarScreen по умолчанию', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      // Проверяем, что отображается CalendarScreen
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(EventsScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsNothing);
    });

    testWidgets('должен переключаться на EventsScreen при нажатии на вкладку "Мероприятия"', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      // Нажимаем на вкладку "Мероприятия"
      await tester.tap(find.text('Мероприятия'));
      await tester.pumpAndSettle();

      // Проверяем, что отображается EventsScreen
      expect(find.byType(EventsScreen), findsOneWidget);
      expect(find.byType(CalendarScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsNothing);
    });

    testWidgets('должен переключаться на ProfileScreen при нажатии на вкладку "Профиль"', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      // Нажимаем на вкладку "Профиль"
      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();

      // Проверяем, что отображается ProfileScreen
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byType(CalendarScreen), findsNothing);
      expect(find.byType(EventsScreen), findsNothing);
    });

    testWidgets('должен сохранять правильный индекс активной вкладки', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      // Проверяем начальный индекс (Calendar = 0)
      final initialBottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(initialBottomNav.currentIndex, equals(0));

      // Переключаемся на Events (индекс 1)
      await tester.tap(find.text('Мероприятия'));
      await tester.pump();

      final eventsBottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(eventsBottomNav.currentIndex, equals(1));

      // Переключаемся на Profile (индекс 2)
      await tester.tap(find.text('Профиль'));
      await tester.pump();

      final profileBottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(profileBottomNav.currentIndex, equals(2));
    });

    testWidgets('должен возвращаться к Calendar при повторном нажатии на первую вкладку', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      // Переходим на другую вкладку
      await tester.tap(find.text('Мероприятия'));
      await tester.pumpAndSettle();
      expect(find.byType(EventsScreen), findsOneWidget);

      // Возвращаемся к календарю
      await tester.tap(find.text('Календарь'));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(EventsScreen), findsNothing);
    });

    testWidgets('должен сохранять состояние экранов при переключении', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      // Переключаемся между экранами несколько раз
      await tester.tap(find.text('Мероприятия'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Календарь'));
      await tester.pumpAndSettle();

      // Проверяем, что экраны корректно переключаются
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('должен корректно обрабатывать нажатия на иконки вкладок', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      // Нажимаем на иконку календаря
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarScreen), findsOneWidget);

      // Нажимаем на иконку списка
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();
      expect(find.byType(EventsScreen), findsOneWidget);

      // Нажимаем на иконку профиля
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('должен иметь правильные цвета для активной и неактивной вкладок', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      // Проверяем цвета
      expect(bottomNav.selectedItemColor, equals(Color(0xFF2E7D32)));
      expect(bottomNav.unselectedItemColor, equals(Colors.grey));
      expect(bottomNav.backgroundColor, equals(Colors.white));
      expect(bottomNav.type, equals(BottomNavigationBarType.fixed));
    });

    testWidgets('должен поддерживать все типы навигационных элементов', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      // Проверяем количество элементов
      expect(bottomNav.items.length, equals(3));

      // Проверяем, что все элементы имеют иконки и подписи
      expect(bottomNav.items[0].icon, isA<Icon>());
      expect(bottomNav.items[0].label, equals('Календарь'));

      expect(bottomNav.items[1].icon, isA<Icon>());
      expect(bottomNav.items[1].label, equals('Мероприятия'));

      expect(bottomNav.items[2].icon, isA<Icon>());
      expect(bottomNav.items[2].label, equals('Профиль'));
    });

    testWidgets('должен корректно работать с быстрыми переключениями', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      // Быстро переключаемся между вкладками
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Мероприятия'));
        await tester.pump();

        await tester.tap(find.text('Профиль'));
        await tester.pump();

        await tester.tap(find.text('Календарь'));
        await tester.pump();
      }

      // Проверяем финальное состояние
      expect(find.byType(CalendarScreen), findsOneWidget);

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, equals(0));
    });

    testWidgets('должен иметь фиксированную высоту навигационной панели', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      // Получаем размер нижней панели навигации
      final bottomNavRenderBox = tester.renderObject<RenderBox>(
        find.byType(BottomNavigationBar),
      );
      
      // Проверяем, что панель имеет разумную высоту
      expect(bottomNavRenderBox.size.height, greaterThan(50));
      expect(bottomNavRenderBox.size.height, lessThan(100));
    });

    testWidgets('должен отображать Scaffold с правильной структурой', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(MainScreen()),
      );

      await tester.pumpAndSettle();

      // Проверяем структуру Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
      
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, isNotNull);
      expect(scaffold.bottomNavigationBar, isNotNull);
    });
  });
}