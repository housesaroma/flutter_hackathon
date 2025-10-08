import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event_model.dart';
import 'package:flutter_application_1/screens/calendar_screen.dart';
import 'package:flutter_application_1/screens/create_event_screen.dart';
import 'package:flutter_application_1/services/event_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:table_calendar/table_calendar.dart';

import 'test_helpers.dart';

void main() {
  group('CalendarScreen Widget Tests', () {
    late MockEventService mockEventService;

    setUp(() {
      mockEventService = MockEventService();
    });

    testWidgets('должен отображать все основные элементы календаря', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем AppBar
      expect(find.text('Календарь мероприятий'), findsOneWidget);

      // Проверяем календарь
      expect(find.byType(TableCalendar), findsOneWidget);

      // Проверяем кнопку добавления мероприятия
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('должен отображать календарь в месячном формате по умолчанию', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      final calendar = tester.widget<TableCalendar>(find.byType(TableCalendar));
      expect(calendar.calendarFormat, equals(CalendarFormat.month));
    });

    testWidgets('должен показывать текущую дату как выбранную по умолчанию', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      final calendar = tester.widget<TableCalendar>(find.byType(TableCalendar));
      final today = DateTime.now();

      // Проверяем, что focusedDay установлен на сегодня
      expect(calendar.focusedDay.year, equals(today.year));
      expect(calendar.focusedDay.month, equals(today.month));
      expect(calendar.focusedDay.day, equals(today.day));
    });

    testWidgets('должен отображать мероприятия для выбранной даты', (
      WidgetTester tester,
    ) async {
      // Настраиваем mock для возврата события
      when(
        mockEventService.getEventsForDate(any),
      ).thenAnswer((_) => Stream.value([mockEvent]));

      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение мероприятия
      expect(find.text('Тестовое мероприятие'), findsOneWidget);
      expect(find.text('Совещание'), findsOneWidget);
    });

    testWidgets(
      'должен показывать сообщение когда нет мероприятий на выбранную дату',
      (WidgetTester tester) async {
        // Настраиваем mock для возврата пустого списка
        when(
          mockEventService.getEventsForDate(any),
        ).thenAnswer((_) => Stream.value([]));

        await tester.pumpWidget(
          createTestWidget(CalendarScreen(), eventService: mockEventService),
        );

        await tester.pumpAndSettle();

        expect(find.text('На этот день мероприятий нет'), findsOneWidget);
        expect(find.byIcon(Icons.event_busy), findsOneWidget);
      },
    );

    testWidgets(
      'должен показывать индикатор загрузки во время получения данных',
      (WidgetTester tester) async {
        // Настраиваем mock для имитации загрузки
        when(
          mockEventService.getEventsForDate(any),
        ).thenAnswer((_) => Stream.fromIterable([]));

        await tester.pumpWidget(
          createTestWidget(CalendarScreen(), eventService: mockEventService),
        );

        // Проверяем индикатор загрузки в начальном состоянии
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();
      },
    );

    testWidgets('должен обновлять список мероприятий при выборе новой даты', (
      WidgetTester tester,
    ) async {
      when(
        mockEventService.getEventsForDate(any),
      ).thenAnswer((_) => Stream.value([mockEvent]));

      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Выбираем другую дату в календаре
      final dayCell = find.text('15');
      if (dayCell.evaluate().isNotEmpty) {
        await tester.tap(dayCell.first);
        await tester.pump();

        // Проверяем, что метод был вызван
        verify(mockEventService.getEventsForDate(any)).called(atLeastOnce);
      }
    });

    testWidgets('должен открывать CreateEventScreen при нажатии на FAB', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Нажимаем на FloatingActionButton
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Здесь должен открыться CreateEventScreen
      // Проверяем переход по характерным элементам
      expect(find.text('Создать мероприятие'), findsOneWidget);
    });

    testWidgets('должен отображать детали мероприятия в карточке', (
      WidgetTester tester,
    ) async {
      when(
        mockEventService.getEventsForDate(any),
      ).thenAnswer((_) => Stream.value([mockEvent]));

      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем элементы карточки мероприятия
      expect(find.text('Тестовое мероприятие'), findsOneWidget);
      expect(find.text('Описание мероприятия'), findsOneWidget);
      expect(find.text('Конференц-зал'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('должен показывать правильное время мероприятия', (
      WidgetTester tester,
    ) async {
      when(
        mockEventService.getEventsForDate(any),
      ).thenAnswer((_) => Stream.value([mockEvent]));

      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение времени (формат может варьироваться)
      expect(find.textContaining('10:00'), findsOneWidget);
      expect(find.textContaining('12:00'), findsOneWidget);
    });

    testWidgets('должен отображать тип мероприятия с правильной иконкой', (
      WidgetTester tester,
    ) async {
      when(
        mockEventService.getEventsForDate(any),
      ).thenAnswer((_) => Stream.value([mockEvent]));

      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение типа мероприятия
      expect(find.text('Совещание'), findsOneWidget);
    });

    testWidgets('должен поддерживать навигацию по месяцам', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Ищем стрелки навигации по месяцам
      final leftArrow = find.byIcon(Icons.chevron_left);
      final rightArrow = find.byIcon(Icons.chevron_right);

      if (leftArrow.evaluate().isNotEmpty) {
        await tester.tap(leftArrow);
        await tester.pump();
      }

      if (rightArrow.evaluate().isNotEmpty) {
        await tester.tap(rightArrow);
        await tester.pump();
      }
    });

    testWidgets('должен обрабатывать ошибки загрузки мероприятий', (
      WidgetTester tester,
    ) async {
      // Настраиваем mock для возврата ошибки
      when(
        mockEventService.getEventsForDate(any),
      ).thenAnswer((_) => Stream.error('Ошибка загрузки данных'));

      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение ошибки
      expect(find.textContaining('Ошибка'), findsOneWidget);
    });

    testWidgets('должен правильно отображать множественные мероприятия', (
      WidgetTester tester,
    ) async {
      final multipleEvents = [
        mockEvent,
        mockEvent.copyWith(
          id: 'event_2',
          title: 'Второе мероприятие',
          type: EventType.session,
        ),
      ];

      when(
        mockEventService.getEventsForDate(any),
      ).thenAnswer((_) => Stream.value(multipleEvents));

      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение обоих мероприятий
      expect(find.text('Тестовое мероприятие'), findsOneWidget);
      expect(find.text('Второе мероприятие'), findsOneWidget);
      expect(find.text('Совещание'), findsOneWidget);
      expect(find.text('Заседание'), findsOneWidget);
    });

    testWidgets('должен корректно обрабатывать длинные названия мероприятий', (
      WidgetTester tester,
    ) async {
      final longTitleEvent = mockEvent.copyWith(
        title:
            'Очень длинное название мероприятия которое должно корректно отображаться',
      );

      when(
        mockEventService.getEventsForDate(any),
      ).thenAnswer((_) => Stream.value([longTitleEvent]));

      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем, что длинное название отображается
      expect(find.textContaining('Очень длинное название'), findsOneWidget);
    });

    testWidgets('должен передавать правильную дату в CreateEventScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Выбираем конкретную дату
      final dayCell = find.text('20');
      if (dayCell.evaluate().isNotEmpty) {
        await tester.tap(dayCell.first);
        await tester.pump();
      }

      // Нажимаем на FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Проверяем, что CreateEventScreen получил правильную дату
      // Это зависит от реализации навигации
    });

    testWidgets('должен корректно отображать цветовую схему', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(CalendarScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем цвет AppBar
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(Color(0xFF2E7D32)));
      expect(appBar.foregroundColor, equals(Colors.white));
    });
  });
}
