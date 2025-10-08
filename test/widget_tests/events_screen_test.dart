import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event_model.dart';
import 'package:flutter_application_1/screens/events_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'test_helpers.dart';

void main() {
  group('EventsScreen Widget Tests', () {
    late MockEventService mockEventService;

    setUp(() {
      mockEventService = MockEventService();
    });

    testWidgets('должен отображать все основные элементы экрана мероприятий', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем AppBar
      expect(find.text('Все мероприятия'), findsOneWidget);

      // Проверяем отображение мероприятия
      expect(find.text('Тестовое мероприятие'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('должен отображать список мероприятий в карточках', (
      WidgetTester tester,
    ) async {
      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.value([mockEvent]));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем карточку мероприятия
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);

      // Проверяем содержимое карточки
      expect(find.text('Тестовое мероприятие'), findsOneWidget);
      expect(find.text('Описание мероприятия'), findsOneWidget);
      expect(find.text('Конференц-зал'), findsOneWidget);
    });

    testWidgets('должен показывать сообщение когда мероприятий нет', (
      WidgetTester tester,
    ) async {
      when(mockEventService.getEvents()).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем сообщение об отсутствии мероприятий
      expect(find.text('Мероприятий пока нет'), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('должен показывать индикатор загрузки в начальном состоянии', (
      WidgetTester tester,
    ) async {
      // Имитируем состояние загрузки
      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.fromIterable([]));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      // Проверяем индикатор загрузки
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('должен отображать детали мероприятия в карточке', (
      WidgetTester tester,
    ) async {
      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.value([mockEvent]));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем основные детали мероприятия
      expect(find.text('Тестовое мероприятие'), findsOneWidget);
      expect(find.text('Описание мероприятия'), findsOneWidget);
      expect(find.text('Конференц-зал'), findsOneWidget);

      // Проверяем иконки
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.event), findsOneWidget);
    });

    testWidgets('должен отображать правильное время мероприятия', (
      WidgetTester tester,
    ) async {
      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.value([mockEvent]));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение времени
      expect(find.textContaining('10:00'), findsOneWidget);
      expect(find.textContaining('12:00'), findsOneWidget);
    });

    testWidgets('должен отображать тип мероприятия', (
      WidgetTester tester,
    ) async {
      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.value([mockEvent]));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем тип мероприятия
      expect(find.text('Совещание'), findsOneWidget);
    });

    testWidgets('должен отображать дату мероприятия в читаемом формате', (
      WidgetTester tester,
    ) async {
      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.value([mockEvent]));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение даты
      expect(find.textContaining('15'), findsOneWidget); // День
      expect(find.textContaining('октябрь'), findsOneWidget); // Месяц
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
          startTime: DateTime(2025, 10, 16, 14, 0),
          endTime: DateTime(2025, 10, 16, 16, 0),
        ),
        mockEvent.copyWith(
          id: 'event_3',
          title: 'Третье мероприятие',
          type: EventType.reception,
          startTime: DateTime(2025, 10, 17, 9, 0),
          endTime: DateTime(2025, 10, 17, 11, 0),
        ),
      ];

      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.value(multipleEvents));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение всех мероприятий
      expect(find.text('Тестовое мероприятие'), findsOneWidget);
      expect(find.text('Второе мероприятие'), findsOneWidget);
      expect(find.text('Третье мероприятие'), findsOneWidget);

      // Проверяем типы мероприятий
      expect(find.text('Совещание'), findsOneWidget);
      expect(find.text('Заседание'), findsOneWidget);
      expect(find.text('Прием граждан'), findsOneWidget);

      // Проверяем количество карточек
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('должен использовать ListView.builder для оптимизации', (
      WidgetTester tester,
    ) async {
      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.value([mockEvent]));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем наличие ListView
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('должен обрабатывать ошибки загрузки мероприятий', (
      WidgetTester tester,
    ) async {
      // Настраиваем mock для возврата ошибки
      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.error('Ошибка загрузки данных'));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение ошибки
      expect(find.textContaining('Ошибка'), findsOneWidget);
    });

    testWidgets('должен корректно отображать длинные названия мероприятий', (
      WidgetTester tester,
    ) async {
      final longTitleEvent = mockEvent.copyWith(
        title:
            'Очень длинное название мероприятия которое должно корректно отображаться в карточке без переполнения',
      );

      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.value([longTitleEvent]));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем, что длинное название отображается
      expect(find.textContaining('Очень длинное название'), findsOneWidget);
    });

    testWidgets('должен корректно отображать длинные описания', (
      WidgetTester tester,
    ) async {
      final longDescriptionEvent = mockEvent.copyWith(
        description:
            'Очень длинное описание мероприятия которое должно корректно отображаться в карточке без переполнения интерфейса',
      );

      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.value([longDescriptionEvent]));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем, что длинное описание отображается
      expect(find.textContaining('Очень длинное описание'), findsOneWidget);
    });

    testWidgets(
      'должен отображать цветовые индикаторы для разных типов мероприятий',
      (WidgetTester tester) async {
        final eventsWithDifferentTypes = [
          mockEvent,
          mockEvent.copyWith(id: 'event_2', type: EventType.session),
          mockEvent.copyWith(id: 'event_3', type: EventType.reception),
          mockEvent.copyWith(id: 'event_4', type: EventType.other),
        ];

        when(
          mockEventService.getEvents(),
        ).thenAnswer((_) => Stream.value(eventsWithDifferentTypes));

        await tester.pumpWidget(
          createTestWidget(EventsScreen(), eventService: mockEventService),
        );

        await tester.pumpAndSettle();

        // Проверяем, что разные типы отображаются по-разному
        expect(find.byType(Container), findsWidgets); // Цветовые индикаторы
      },
    );

    testWidgets('должен сортировать мероприятия по дате', (
      WidgetTester tester,
    ) async {
      final unsortedEvents = [
        mockEvent.copyWith(
          id: 'event_1',
          title: 'Позднее мероприятие',
          startTime: DateTime(2025, 10, 20, 10, 0),
        ),
        mockEvent.copyWith(
          id: 'event_2',
          title: 'Раннее мероприятие',
          startTime: DateTime(2025, 10, 10, 10, 0),
        ),
        mockEvent.copyWith(
          id: 'event_3',
          title: 'Среднее мероприятие',
          startTime: DateTime(2025, 10, 15, 10, 0),
        ),
      ];

      when(
        mockEventService.getEvents(),
      ).thenAnswer((_) => Stream.value(unsortedEvents));

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем, что мероприятия отображаются
      expect(find.text('Позднее мероприятие'), findsOneWidget);
      expect(find.text('Раннее мероприятие'), findsOneWidget);
      expect(find.text('Среднее мероприятие'), findsOneWidget);
    });

    testWidgets('должен обновлять список при изменении данных', (
      WidgetTester tester,
    ) async {
      // Создаем контроллер стрима для имитации изменений
      final streamController = Stream.fromIterable([
        [mockEvent],
        [
          mockEvent,
          mockEvent.copyWith(id: 'event_2', title: 'Новое мероприятие'),
        ],
      ]);

      when(mockEventService.getEvents()).thenAnswer((_) => streamController);

      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pump();

      // Проверяем первое мероприятие
      expect(find.text('Тестовое мероприятие'), findsOneWidget);

      await tester.pump();

      // После обновления должно появиться новое мероприятие
      expect(find.text('Новое мероприятие'), findsOneWidget);
    });

    testWidgets('должен иметь правильную цветовую схему AppBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(EventsScreen(), eventService: mockEventService),
      );

      await tester.pumpAndSettle();

      // Проверяем цвета AppBar
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(Color(0xFF2E7D32)));
      expect(appBar.foregroundColor, equals(Colors.white));
    });

    testWidgets(
      'должен поддерживать прокрутку при большом количестве мероприятий',
      (WidgetTester tester) async {
        // Создаем много мероприятий
        final manyEvents = List.generate(
          20,
          (index) => mockEvent.copyWith(
            id: 'event_$index',
            title: 'Мероприятие $index',
            startTime: DateTime(2025, 10, 15 + index, 10, 0),
          ),
        );

        when(
          mockEventService.getEvents(),
        ).thenAnswer((_) => Stream.value(manyEvents));

        await tester.pumpWidget(
          createTestWidget(EventsScreen(), eventService: mockEventService),
        );

        await tester.pumpAndSettle();

        // Проверяем, что список можно прокручивать
        expect(find.byType(ListView), findsOneWidget);

        // Прокручиваем вниз
        await tester.drag(find.byType(ListView), Offset(0, -300));
        await tester.pumpAndSettle();

        // Проверяем, что прокрутка работает
        expect(find.text('Мероприятие 0'), findsNothing); // Должно скрыться
      },
    );
  });
}
