import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/register_screen.dart';

void main() {
  testWidgets('Проверка наличия всех важных текстов на экране регистрации', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    final elements = {
      'ФИО': find.text('ФИО'),
      'Роль': find.text('Роль'),
      'Email': find.text('Email'),
      'Телефон (необязательно)': find.text('Телефон (необязательно)'),
      'Отдел/комиссия (необязательно)': find.text('Отдел/комиссия (необязательно)'),
      'Пароль': find.text('Пароль'),
      'Подтвердите пароль': find.text('Подтвердите пароль'),
      'Зарегистрироваться': find.text('Зарегистрироваться'),
    };

    elements.forEach((name, finder) {
      final found = finder.evaluate().isNotEmpty;
      final status = found ? '✅' : '❌';
      debugPrint('$name $status');
      expect(found, true, reason: 'Текст "$name" не найден на экране');
    });
  });
}