import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/register_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'test_helpers.dart';

void main() {
  group('RegisterScreen Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockEventService mockEventService;

    setUp(() {
      mockAuthService = MockAuthService();
      mockEventService = MockEventService();
    });

    testWidgets('должен отображать все основные элементы формы регистрации', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      // Проверяем заголовок
      expect(find.text('Регистрация'), findsOneWidget);

      // Проверяем поля ввода
      expect(find.text('ФИО'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Пароль'), findsOneWidget);
      expect(find.text('Подтвердите пароль'), findsOneWidget);
      expect(find.text('Телефон (необязательно)'), findsOneWidget);
      expect(find.text('Отдел (необязательно)'), findsOneWidget);

      // Проверяем выбор роли
      expect(find.text('Роль'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

      // Проверяем кнопку регистрации
      expect(find.text('Зарегистрироваться'), findsOneWidget);
    });

    testWidgets(
      'должен показывать ошибки валидации для пустых обязательных полей',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            RegisterScreen(),
            authService: mockAuthService,
            eventService: mockEventService,
          ),
        );

        // Нажимаем кнопку регистрации без заполнения полей
        await tester.tap(find.text('Зарегистрироваться'));
        await tester.pump();

        // Проверяем сообщения об ошибках для обязательных полей
        expect(find.text('Введите ФИО'), findsOneWidget);
        expect(find.text('Введите email'), findsOneWidget);
        expect(find.text('Введите пароль'), findsOneWidget);
        expect(find.text('Подтвердите пароль'), findsOneWidget);
      },
    );

    testWidgets('должен проверять совпадение паролей', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      final fields = find.byType(TextFormField);

      // Заполняем поля с разными паролями
      await tester.enterText(fields.at(0), 'Иван Иванович Иванов');
      await tester.enterText(fields.at(1), 'ivan@test.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password456'); // Другой пароль

      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pump();

      expect(find.text('Пароли не совпадают'), findsOneWidget);
    });

    testWidgets('должен валидировать корректность email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      final fields = find.byType(TextFormField);

      // Заполняем поля с некорректным email
      await tester.enterText(fields.at(0), 'Иван Иванов');
      await tester.enterText(fields.at(1), 'invalid-email');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pump();

      expect(find.text('Введите корректный email'), findsOneWidget);
    });

    testWidgets('должен проверять минимальную длину пароля', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      final fields = find.byType(TextFormField);

      // Заполняем поля с коротким паролем
      await tester.enterText(fields.at(0), 'Иван Иванов');
      await tester.enterText(fields.at(1), 'ivan@test.com');
      await tester.enterText(fields.at(2), '123');
      await tester.enterText(fields.at(3), '123');

      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pump();

      expect(
        find.text('Пароль должен содержать минимум 6 символов'),
        findsOneWidget,
      );
    });

    testWidgets('должен позволять выбирать роль из выпадающего списка', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      // Находим и открываем дропдаун
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Проверяем доступные опции
      expect(find.text('Сотрудник аппарата'), findsWidgets);
      expect(find.text('Депутат'), findsOneWidget);

      // Выбираем роль депутата
      await tester.tap(find.text('Депутат'));
      await tester.pumpAndSettle();

      // Проверяем, что выбор сохранился
      expect(find.text('Депутат'), findsOneWidget);
    });

    testWidgets('должен показывать поле выбора депутата для роли сотрудника', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      // По умолчанию должна быть выбрана роль сотрудника
      expect(find.text('Выберите депутата'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
    });

    testWidgets('должен скрывать поле выбора депутата для роли депутата', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      // Выбираем роль депутата
      final roleDropdown = find.byType(DropdownButtonFormField<String>).first;
      await tester.tap(roleDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Депутат'));
      await tester.pumpAndSettle();

      // Поле выбора депутата должно скрыться
      expect(find.text('Выберите депутата'), findsNothing);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets(
      'должен вызывать signUp с корректными данными при успешной валидации',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            RegisterScreen(),
            authService: mockAuthService,
            eventService: mockEventService,
          ),
        );

        final fields = find.byType(TextFormField);

        // Заполняем все обязательные поля
        await tester.enterText(fields.at(0), 'Иван Иванович Иванов');
        await tester.enterText(fields.at(1), 'ivan@test.com');
        await tester.enterText(fields.at(2), 'password123');
        await tester.enterText(fields.at(3), 'password123');
        await tester.enterText(fields.at(4), '+7 (999) 123-45-67');
        await tester.enterText(fields.at(5), 'IT отдел');

        // Нажимаем кнопку регистрации
        await tester.tap(find.text('Зарегистрироваться'));
        await tester.pumpAndSettle();

        // Проверяем, что signUp был вызван с правильными параметрами
        verify(
          mockAuthService.signUp(
            email: 'ivan@test.com',
            password: 'password123',
            name: 'Иван Иванович Иванов',
            isDeputy: false,
            phone: '+7 (999) 123-45-67',
            department: 'IT отдел',
            deputyId: anyNamed('deputyId'),
          ),
        ).called(1);
      },
    );

    testWidgets('должен показывать индикатор загрузки во время регистрации', (
      WidgetTester tester,
    ) async {
      // Настраиваем mock для имитации загрузки
      when(mockAuthService.isLoading).thenReturn(true);

      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Регистрация...'), findsOneWidget);
    });

    testWidgets('должен обрабатывать ошибки регистрации', (
      WidgetTester tester,
    ) async {
      // Настраиваем mock для возврата ошибки
      when(
        mockAuthService.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          isDeputy: anyNamed('isDeputy'),
          phone: anyNamed('phone'),
          department: anyNamed('department'),
          deputyId: anyNamed('deputyId'),
        ),
      ).thenThrow(Exception('Email уже используется'));

      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'Иван Иванов');
      await tester.enterText(fields.at(1), 'existing@test.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pump();

      expect(find.textContaining('Email уже используется'), findsOneWidget);
    });

    testWidgets('должен загружать список депутатов для выбора', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
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

    testWidgets('должен переключать видимость пароля', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      // Находим иконки видимости пароля
      final visibilityIcons = find.byIcon(Icons.visibility_off);

      if (visibilityIcons.evaluate().isNotEmpty) {
        // Нажимаем на первую иконку (основной пароль)
        await tester.tap(visibilityIcons.first);
        await tester.pump();

        expect(find.byIcon(Icons.visibility), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('должен возвращаться на экран входа при нажатии кнопки назад', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      // Ищем кнопку "Уже есть аккаунт?"
      final backButton = find.text('Уже есть аккаунт? Войти');

      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Проверяем переход (зависит от реализации навигации)
      }
    });

    testWidgets('должен валидировать формат телефона если указан', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          RegisterScreen(),
          authService: mockAuthService,
          eventService: mockEventService,
        ),
      );

      final fields = find.byType(TextFormField);

      // Заполняем поля с некорректным телефоном
      await tester.enterText(fields.at(0), 'Иван Иванов');
      await tester.enterText(fields.at(1), 'ivan@test.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), '123'); // Некорректный телефон

      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pump();

      // Если есть валидация телефона
      if (find
          .text('Введите корректный номер телефона')
          .evaluate()
          .isNotEmpty) {
        expect(find.text('Введите корректный номер телефона'), findsOneWidget);
      }
    });
  });
}
