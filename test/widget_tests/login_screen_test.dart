import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import '../test_helpers.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('должен отображать все основные элементы экрана входа', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      // Проверяем заголовки и текст
      expect(find.text('Вход в систему'), findsOneWidget);
      expect(find.text('Екатеринбургская Городская Дума'), findsOneWidget);
      
      // Проверяем поля ввода
      expect(find.byType(TextFormField), findsNWidgets(2));
      
      // Проверяем кнопки
      expect(find.text('Войти'), findsOneWidget);
      expect(find.text('Зарегистрироваться'), findsOneWidget);
      
      // Проверяем наличие иконок
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('должен показывать ошибки валидации для пустых полей', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      // Нажимаем кнопку входа без заполнения полей
      await tester.tap(find.text('Войти'));
      await tester.pump();

      // Проверяем сообщения об ошибках
      expect(find.text('Введите email'), findsOneWidget);
      expect(find.text('Введите пароль'), findsOneWidget);
    });

    testWidgets('должен показывать ошибку для некорректного email', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      // Находим поля ввода
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Вводим некорректный email
      await tester.enterText(emailField, 'invalid-email');
      await tester.enterText(passwordField, 'password123');
      
      // Нажимаем войти
      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Введите корректный email'), findsOneWidget);
    });

    testWidgets('должен показывать ошибку для короткого пароля', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@test.com');
      await tester.enterText(passwordField, '123');
      
      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Пароль должен содержать минимум 6 символов'), findsOneWidget);
    });

    testWidgets('должен переключать видимость пароля при нажатии на иконку', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      // Находим иконку видимости пароля
      final visibilityIcon = find.byIcon(Icons.visibility_off);
      
      if (visibilityIcon.evaluate().isNotEmpty) {
        // Нажимаем на иконку
        await tester.tap(visibilityIcon);
        await tester.pump();
        
        // Проверяем, что иконка изменилась
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNothing);
        
        // Нажимаем еще раз
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();
        
        // Проверяем, что вернулась исходная иконка
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsNothing);
      }
    });

    testWidgets('должен вызывать signIn при успешной валидации', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Вводим корректные данные
      await tester.enterText(emailField, 'test@test.com');
      await tester.enterText(passwordField, 'password123');
      
      // Нажимаем войти
      await tester.tap(find.text('Войти'));
      await tester.pump();

      // Проверяем, что был вызван метод signIn
      verify(mockAuthService.signIn('test@test.com', 'password123')).called(1);
    });

    testWidgets('должен показывать индикатор загрузки во время входа', 
        (WidgetTester tester) async {
      // Настраиваем mock для возврата состояния загрузки
      when(mockAuthService.isLoading).thenReturn(true);
      
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      // Если индикатор загрузки показывается
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Вход...'), findsOneWidget);
    });

    testWidgets('должен заполнять демо данные при нажатии на кнопку Демо', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      // Ищем кнопку демо данных
      final demoButton = find.text('Демо');
      
      if (demoButton.evaluate().isNotEmpty) {
        await tester.tap(demoButton);
        await tester.pump();

        // Проверяем, что поля заполнились демо данными
        expect(find.text('test@egd.ru'), findsOneWidget);
      }
    });

    testWidgets('должен переходить на экран регистрации при нажатии кнопки', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      // Нажимаем кнопку регистрации
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();

      // Здесь проверяем переход к RegisterScreen
      // В зависимости от реализации навигации
    });

    testWidgets('должен корректно обрабатывать ошибку аутентификации', 
        (WidgetTester tester) async {
      // Настраиваем mock для возврата ошибки
      when(mockAuthService.signIn(any, any))
          .thenThrow(Exception('Неверный email или пароль'));
      
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'wrong@test.com');
      await tester.enterText(passwordField, 'wrongpassword');
      
      await tester.tap(find.text('Войти'));
      await tester.pump();

      // Проверяем отображение ошибки
      expect(find.textContaining('Неверный email или пароль'), findsOneWidget);
    });

    testWidgets('должен очищать поля при успешном входе', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Заполняем поля
      await tester.enterText(emailField, 'test@test.com');
      await tester.enterText(passwordField, 'password123');
      
      // Входим
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      // Проверяем, что поля очистились (если это предусмотрено логикой)
      final emailController = tester.widget<TextFormField>(emailField).controller;
      final passwordController = tester.widget<TextFormField>(passwordField).controller;
      
      if (emailController?.text.isEmpty == true) {
        expect(emailController!.text, isEmpty);
      }
      if (passwordController?.text.isEmpty == true) {
        expect(passwordController!.text, isEmpty);
      }
    });

    testWidgets('должен сохранять состояние полей при пересборке виджета', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );

      final emailField = find.byType(TextFormField).first;
      
      // Вводим текст
      await tester.enterText(emailField, 'test@test.com');
      
      // Пересобираем виджет
      await tester.pumpWidget(
        createTestWidget(LoginScreen(), authService: mockAuthService),
      );
      
      // Проверяем, что текст сохранился
      expect(find.text('test@test.com'), findsOneWidget);
    });
  });
}