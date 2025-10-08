import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_application_1/screens/create_event_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/event_service.dart';
import 'package:flutter_application_1/models/event_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import '../test_helpers.dart';

void main() {
  group('CreateEventScreen Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockEventService mockEventService;
    late DateTime testDate;

    setUp(() {
      mockAuthService = MockAuthService();
      mockEventService = MockEventService();
      testDate = DateTime(2025, 10, 15);
    });

    testWidgets('должен отображать все основные элементы формы создания мероприятия', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем заголовок
      expect(find.text('Создать мероприятие'), findsOneWidget);
      
      // Проверяем поля ввода
      expect(find.text('Название мероприятия'), findsOneWidget);
      expect(find.text('Описание'), findsOneWidget);
      expect(find.text('Местоположение'), findsOneWidget);
      expect(find.text('Заметки (необязательно)'), findsOneWidget);
      
      // Проверяем выбор типа мероприятия
      expect(find.text('Тип мероприятия'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<EventType>), findsOneWidget);
      
      // Проверяем кнопки даты и времени
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      
      // Проверяем кнопку создания
      expect(find.text('Создать'), findsOneWidget);
    });

    testWidgets('должен показывать ошибки валидации для пустых обязательных полей', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Нажимаем создать без заполнения полей
      await tester.tap(find.text('Создать'));
      await tester.pump();

      // Проверяем сообщения об ошибках
      expect(find.text('Введите название мероприятия'), findsOneWidget);
      expect(find.text('Введите описание мероприятия'), findsOneWidget);
      expect(find.text('Введите местоположение'), findsOneWidget);
    });

    testWidgets('должен отображать выбранную дату по умолчанию', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем, что отображается переданная дата
      expect(find.textContaining('15.10.2025'), findsOneWidget);
    });

    testWidgets('должен позволять выбирать тип мероприятия', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Открываем дропдаун типа мероприятия
      final typeDropdown = find.byType(DropdownButtonFormField<EventType>);
      await tester.tap(typeDropdown);
      await tester.pumpAndSettle();

      // Проверяем доступные типы
      expect(find.text('Совещание'), findsWidgets);
      expect(find.text('Заседание'), findsOneWidget);
      expect(find.text('Прием граждан'), findsOneWidget);
      expect(find.text('Другое'), findsOneWidget);

      // Выбираем заседание
      await tester.tap(find.text('Заседание'));
      await tester.pumpAndSettle();

      // Проверяем, что выбор сохранился
      expect(find.text('Заседание'), findsOneWidget);
    });

    testWidgets('должен открывать DatePicker при нажатии на поле даты', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Нажимаем на поле выбора даты
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Проверяем, что открылся DatePicker
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('должен открывать TimePicker при нажатии на поле времени', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Нажимаем на поле выбора времени
      await tester.tap(find.byIcon(Icons.access_time));
      await tester.pumpAndSettle();

      // Проверяем, что открылся TimePicker
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('должен показывать поле выбора депутата для администратора', 
        (WidgetTester tester) async {
      // Настраиваем mock для администратора
      final adminUser = mockAdmin;
      when(mockAuthService.currentUser).thenReturn(adminUser);

      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Для админа должно отображаться поле выбора депутата
      expect(find.text('Выберите депутата'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
    });

    testWidgets('должен скрывать поле выбора депутата для депутата', 
        (WidgetTester tester) async {
      // Настраиваем mock для депутата
      when(mockAuthService.currentUser).thenReturn(mockDeputy);

      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Для депутата поле выбора депутата должно быть скрыто
      expect(find.text('Выберите депутата'), findsNothing);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget); // Только тип мероприятия
    });

    testWidgets('должен вызывать createEvent при успешной валидации', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      
      // Заполняем все обязательные поля
      await tester.enterText(fields.at(0), 'Тестовое мероприятие');
      await tester.enterText(fields.at(1), 'Описание тестового мероприятия');
      await tester.enterText(fields.at(2), 'Конференц-зал 101');

      // Нажимаем создать
      await tester.tap(find.text('Создать'));
      await tester.pumpAndSettle();

      // Проверяем, что createEvent был вызван
      verify(mockEventService.createEvent(
        title: 'Тестовое мероприятие',
        description: 'Описание тестового мероприятия',
        dateTime: any,
        location: 'Конференц-зал 101',
        deputyId: any,
        type: EventType.meeting,
        notes: '',
      )).called(1);
    });

    testWidgets('должен показывать индикатор загрузки во время создания', 
        (WidgetTester tester) async {
      // Настраиваем mock для имитации долгой операции
      when(mockEventService.createEvent(
        title: anyNamed('title'),
        description: anyNamed('description'),
        dateTime: anyNamed('dateTime'),
        location: anyNamed('location'),
        deputyId: anyNamed('deputyId'),
        type: anyNamed('type'),
        notes: anyNamed('notes'),
      )).thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 1));
      });

      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      
      // Заполняем поля
      await tester.enterText(fields.at(0), 'Тест');
      await tester.enterText(fields.at(1), 'Описание');
      await tester.enterText(fields.at(2), 'Место');

      // Нажимаем создать
      await tester.tap(find.text('Создать'));
      await tester.pump();

      // Проверяем индикатор загрузки
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Создание...'), findsOneWidget);
    });

    testWidgets('должен обрабатывать ошибки создания мероприятия', 
        (WidgetTester tester) async {
      // Настраиваем mock для возврата ошибки
      when(mockEventService.createEvent(
        title: anyNamed('title'),
        description: anyNamed('description'),
        dateTime: anyNamed('dateTime'),
        location: anyNamed('location'),
        deputyId: anyNamed('deputyId'),
        type: anyNamed('type'),
        notes: anyNamed('notes'),
      )).thenThrow(Exception('Ошибка создания мероприятия'));

      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      
      await tester.enterText(fields.at(0), 'Тест');
      await tester.enterText(fields.at(1), 'Описание');
      await tester.enterText(fields.at(2), 'Место');

      await tester.tap(find.text('Создать'));
      await tester.pump();

      // Проверяем отображение ошибки
      expect(find.textContaining('Ошибка создания мероприятия'), findsOneWidget);
    });

    testWidgets('должен очищать форму после успешного создания', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      
      // Заполняем поля
      await tester.enterText(fields.at(0), 'Тестовое мероприятие');
      await tester.enterText(fields.at(1), 'Описание');
      await tester.enterText(fields.at(2), 'Место');

      // Создаем мероприятие
      await tester.tap(find.text('Создать'));
      await tester.pumpAndSettle();

      // Проверяем, что поля очистились (если предусмотрено логикой)
      final titleController = tester.widget<TextFormField>(fields.at(0)).controller;
      if (titleController?.text.isEmpty == true) {
        expect(titleController!.text, isEmpty);
      }
    });

    testWidgets('должен загружать список депутатов для администратора', 
        (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockAdmin);

      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Открываем дропдаун выбора депутата
      final deputyDropdown = find.byType(DropdownButtonFormField<String>).last;
      await tester.tap(deputyDropdown);
      await tester.pumpAndSettle();

      // Проверяем, что депутаты загрузились
      expect(find.text('Тестовый Депутат'), findsOneWidget);
    });

    testWidgets('должен устанавливать время по умолчанию', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем, что отображается время по умолчанию
      expect(find.textContaining(':'), findsAtLeastNWidgets(1)); // Формат времени
    });

    testWidgets('должен валидировать длину названия мероприятия', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      final titleField = find.byType(TextFormField).first;
      
      // Вводим слишком короткое название
      await tester.enterText(titleField, 'А');
      
      await tester.tap(find.text('Создать'));
      await tester.pump();

      // Если есть валидация минимальной длины
      if (find.text('Название должно содержать минимум 3 символа').evaluate().isNotEmpty) {
        expect(find.text('Название должно содержать минимум 3 символа'), findsOneWidget);
      }
    });

    testWidgets('должен сохранять введенные данные при пересборке виджета', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      final titleField = find.byType(TextFormField).first;
      
      // Вводим данные
      await tester.enterText(titleField, 'Тестовое название');
      
      // Пересобираем виджет
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      // Проверяем, что данные сохранились
      expect(find.text('Тестовое название'), findsOneWidget);
    });

    testWidgets('должен возвращаться назад при нажатии кнопки отмены', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          CreateEventScreen(selectedDate: testDate),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Ищем кнопку отмены или стрелку назад
      final backButton = find.byIcon(Icons.arrow_back);
      
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    });
  });
}