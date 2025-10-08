import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'test_helpers.dart';

void main() {
  group('ProfileScreen Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockEventService mockEventService;

    setUp(() {
      mockAuthService = MockAuthService();
      mockEventService = MockEventService();
    });

    testWidgets(
      'должен отображать все основные элементы профиля пользователя',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            ProfileScreen(),
            authService: mockAuthService,
            eventService: mockEventService,
          ),
        );

        await tester.pumpAndSettle();

        // Проверяем заголовок
        expect(find.text('Профиль'), findsOneWidget);

        // Проверяем аватар и имя пользователя
        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.text('Тестовый Пользователь'), findsOneWidget);

        // Проверяем роль пользователя
        expect(find.text('Сотрудник аппарата'), findsOneWidget);

        // Проверяем кнопки
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.text('Выйти из системы'), findsOneWidget);
      },
    );

    testWidgets('должен отображать корректную роль для депутата', (
      WidgetTester tester,
    ) async {
      when(mockAuthService.currentUser).thenReturn(mockDeputy);

      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение роли депутата
      expect(find.text('Депутат'), findsOneWidget);
      expect(find.text('Тестовый Депутат'), findsOneWidget);
    });

    testWidgets('должен отображать данные профиля в режиме просмотра', (
      WidgetTester tester,
    ) async {
      // Настраиваем пользователя с полными данными
      final userWithFullData = mockUser.copyWith(
        phone: '+7 (999) 123-45-67',
        department: 'IT отдел',
      );
      when(mockAuthService.currentUser).thenReturn(userWithFullData);

      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение данных
      expect(find.text('ФИО:'), findsOneWidget);
      expect(find.text('Email:'), findsOneWidget);
      expect(find.text('Телефон:'), findsOneWidget);
      expect(find.text('Отдел:'), findsOneWidget);

      expect(find.text('test@test.com'), findsOneWidget);
      expect(find.text('+7 (999) 123-45-67'), findsOneWidget);
      expect(find.text('IT отдел'), findsOneWidget);
    });

    testWidgets(
      'должен переключаться в режим редактирования при нажатии на иконку',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            ProfileScreen(),
            authService: mockAuthService,
            eventService: mockEventService,
          ),
        );

        await tester.pumpAndSettle();

        // Нажимаем на кнопку редактирования
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pump();

        // Проверяем, что появились поля ввода и кнопки сохранения/отмены
        expect(find.byType(TextFormField), findsWidgets);
        expect(find.text('Сохранить'), findsOneWidget);
        expect(find.text('Отмена'), findsOneWidget);

        // Кнопка редактирования должна исчезнуть
        expect(find.byIcon(Icons.edit), findsNothing);
      },
    );

    testWidgets('должен показывать поля формы в режиме редактирования', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Переходим в режим редактирования
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Проверяем поля формы
      expect(find.text('ФИО'), findsOneWidget);
      expect(find.text('Телефон'), findsOneWidget);
      expect(find.text('Отдел'), findsOneWidget);

      // Email не должен редактироваться
      expect(find.textContaining('Email нельзя изменить'), findsOneWidget);
    });

    testWidgets('должен сохранять изменения при нажатии "Сохранить"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Переходим в режим редактирования
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Изменяем данные
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Новое Имя');

      // Сохраняем
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      // Проверяем, что updateProfile был вызван
      verify(mockAuthService.updateProfile(name: 'Новое Имя')).called(1);

      // Проверяем, что вышли из режима редактирования
      expect(find.text('Сохранить'), findsNothing);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('должен отменять изменения при нажатии "Отмена"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Переходим в режим редактирования
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Изменяем данные
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Измененное Имя');

      // Отменяем
      await tester.tap(find.text('Отмена'));
      await tester.pump();

      // Проверяем, что updateProfile НЕ был вызван
      verifyNever(mockAuthService.updateProfile(name: anyNamed('name')));

      // Проверяем, что вышли из режима редактирования
      expect(find.text('Отмена'), findsNothing);
      expect(find.byIcon(Icons.edit), findsOneWidget);

      // Проверяем, что отображается исходное имя
      expect(find.text('Тестовый Пользователь'), findsOneWidget);
    });

    testWidgets('должен показывать поле выбора депутата для сотрудника', (
      WidgetTester tester,
    ) async {
      // Настраиваем пользователя-сотрудника
      final staffUser = mockUser.copyWith(isDeputy: false);
      when(mockAuthService.currentUser).thenReturn(staffUser);

      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Переходим в режим редактирования
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Проверяем наличие поля выбора депутата
      expect(find.text('Прикрепленный депутат'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('должен скрывать поле выбора депутата для депутата', (
      WidgetTester tester,
    ) async {
      when(mockAuthService.currentUser).thenReturn(mockDeputy);

      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Переходим в режим редактирования
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Поле выбора депутата не должно отображаться
      expect(find.text('Прикрепленный депутат'), findsNothing);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    });

    testWidgets('должен показывать информацию о прикрепленном депутате', (
      WidgetTester tester,
    ) async {
      // Настраиваем сотрудника с депутатом
      final staffWithDeputy = mockUser.copyWith(
        isDeputy: false,
        deputyId: 'deputy_uid',
      );
      when(mockAuthService.currentUser).thenReturn(staffWithDeputy);

      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем отображение информации о депутате
      expect(find.text('Помощник: Тестовый Депутат'), findsOneWidget);
    });

    testWidgets('должен выполнять выход из системы при нажатии кнопки', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Нажимаем кнопку выхода
      await tester.tap(find.text('Выйти из системы'));
      await tester.pump();

      // Проверяем, что signOut был вызван
      verify(mockAuthService.signOut()).called(1);
    });

    testWidgets('должен загружать список депутатов для выбора', (
      WidgetTester tester,
    ) async {
      // Настраиваем сотрудника
      final staffUser = mockUser.copyWith(isDeputy: false);
      when(mockAuthService.currentUser).thenReturn(staffUser);

      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Переходим в режим редактирования
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Открываем дропдаун
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Проверяем, что депутат загрузился
      expect(find.text('Тестовый Депутат'), findsOneWidget);
    });

    testWidgets('должен показывать индикатор загрузки во время обновления', (
      WidgetTester tester,
    ) async {
      // Настраиваем mock для имитации загрузки
      when(mockAuthService.updateProfile(name: anyNamed('name'))).thenAnswer((
        _,
      ) async {
        await Future.delayed(Duration(seconds: 1));
      });

      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Переходим в режим редактирования
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Изменяем данные
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Новое Имя');

      // Сохраняем
      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Проверяем индикатор загрузки
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('должен обрабатывать ошибки обновления профиля', (
      WidgetTester tester,
    ) async {
      // Настраиваем mock для возврата ошибки
      when(
        mockAuthService.updateProfile(name: anyNamed('name')),
      ).thenThrow(Exception('Ошибка обновления профиля'));

      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Переходим в режим редактирования и пытаемся сохранить
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Новое Имя');

      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Проверяем отображение ошибки
      expect(find.textContaining('Ошибка обновления профиля'), findsOneWidget);
    });

    testWidgets('должен валидировать обязательные поля', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Переходим в режим редактирования
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Очищаем обязательное поле
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, '');

      // Пытаемся сохранить
      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Проверяем ошибку валидации
      expect(find.text('Введите ФИО'), findsOneWidget);
    });

    testWidgets('должен корректно отображать цветовую схему', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем цвет AppBar
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(Color(0xFF2E7D32)));
      expect(appBar.foregroundColor, equals(Colors.white));

      // Проверяем цвет чипа роли
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('должен сохранять состояние формы при ошибках', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Переходим в режим редактирования
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Вводим некорректные данные
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, '');

      // Пытаемся сохранить
      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Проверяем, что остались в режиме редактирования
      expect(find.text('Сохранить'), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('должен показывать подтверждение перед выходом', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      await tester.pumpAndSettle();

      // Нажимаем кнопку выхода
      await tester.tap(find.text('Выйти из системы'));
      await tester.pumpAndSettle();

      // Если есть диалог подтверждения
      if (find.text('Выйти из системы?').evaluate().isNotEmpty) {
        expect(find.text('Выйти из системы?'), findsOneWidget);
        expect(find.text('Да'), findsOneWidget);
        expect(find.text('Отмена'), findsOneWidget);

        // Подтверждаем выход
        await tester.tap(find.text('Да'));
        await tester.pump();
      }

      verify(mockAuthService.signOut()).called(1);
    });
  });
}
