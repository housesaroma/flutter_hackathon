import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'test_helpers.dart';

void main() {
  testWidgets('отладочный вывод', (tester) async {
    print('Тест запущен');
    await tester.pumpWidget(createTestWidget(LoginScreen()));
    print('Страницу загружена');
    expect(find.text('ТекстКоторогоНет'), findsOneWidget);
  });
}
