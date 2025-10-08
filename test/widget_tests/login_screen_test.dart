import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/login_screen.dart';

void main() {
  // Проверка наличия всех основных элементов
  testWidgets('Проверка наличия всех полей на экране входа', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    final elements = {
      'Заголовок "Вход в систему"': find.text('Вход в систему'),
      'Текст "Екатеринбургская Городская Дума"': find.text('Екатеринбургская Городская Дума'),
      'Текст "Кабинет депутата и сотрудника аппарата"': find.text('Кабинет депутата и сотрудника аппарата'),
      'Поле Email': find.text('Email'),
      'Поле Пароль': find.text('Пароль'),
      'Поле ввода Email': find.byIcon(Icons.email),
      'Поле ввода Пароль': find.byIcon(Icons.lock),
      'Кнопка "Войти"': find.text('Войти'),
      'Кнопка "Зарегистрироваться"': find.text('Зарегистрироваться'),
      'Ссылка "Забыли пароль?"': find.text('Забыли пароль?'),
    };
    elements.forEach((name, finder) {
      final found = finder.evaluate().isNotEmpty;
      final status = found ? '✅' : '❌';
      debugPrint('$name $status');
      expect(found, true, reason: 'Элемент "$name" не найден на экране');
    });
  });

  // Тест ввода текста в поля Email и Password
  testWidgets('Ввод текста в Email и Password', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });


  // Неверный формат e-mail
  testWidgets('Проверка пустого формата email', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;
    await tester.enterText(emailField, 'test');
    await tester.enterText(passwordField, 'password123');

    final loginButton = find.text('Войти');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Введите корректный email'), findsOneWidget);
  });


  // Тест валидации формы (проверка пустых и некорректных данных)
  testWidgets('Проверка пустого email', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    final emailField = find.byType(TextFormField).first;
    await tester.enterText(emailField, '');

    final loginButton = find.text('Войти');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Введите email'), findsOneWidget);
  });

    testWidgets('Проверка пустого пароля', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    final passwordField = find.byType(TextFormField).first;
    await tester.enterText(passwordField, '');

    final loginButton = find.text('Войти');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Введите пароль'), findsOneWidget);
  });

  testWidgets('Проверка пустых форм', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    final loginButton = find.text('Войти');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Введите email'), findsOneWidget);
  });

    testWidgets('Проверка пустых форм', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    final loginButton = find.text('Войти');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Введите пароль'), findsOneWidget);
  });


  // Тест перехода по ссылке "Зарегистрироваться"
  testWidgets('Переход по ссылке "Зарегистрироваться"', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    final registerButton = find.text('Зарегистрироваться');
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Здесь нужно проверить, что произошёл переход на экран регистрации,
    // например, find.byType(RegisterScreen) или find.text('Регистрация')
  });

  // Тест показа окна восстановления пароля
  testWidgets('Показ окна восстановления пароля', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    final forgotPasswordLink = find.text('Забыли пароль?');
    await tester.tap(forgotPasswordLink);
    await tester.pumpAndSettle();

    // Проверить, появился ли диалог восстановления пароля
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
