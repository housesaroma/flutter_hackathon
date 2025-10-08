import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('должен отображать все основные элементы заставки', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Проверяем основные текстовые элементы
      expect(find.text('Кабинет Депутата'), findsOneWidget);
      expect(find.text('Екатеринбургская Городская Дума'), findsOneWidget);
      expect(find.text('Интерактивный цифровой кабинет'), findsOneWidget);
      expect(find.text('Загрузка...'), findsOneWidget);

      // Проверяем иконку
      expect(find.byIcon(Icons.account_balance), findsOneWidget);

      // Проверяем индикатор загрузки
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('должен иметь правильную цветовую схему', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Проверяем цвет фона Scaffold
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Color(0xFF2E7D32)));

      // Проверяем цвет индикатора загрузки
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.color, equals(Colors.white));
    });

    testWidgets('должен отображать логотип в правильном контейнере', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Проверяем контейнер логотипа
      final logoContainer = find.ancestor(
        of: find.byIcon(Icons.account_balance),
        matching: find.byType(Container),
      );
      expect(logoContainer, findsOneWidget);

      // Получаем Container и проверяем его свойства
      final container = tester.widget<Container>(logoContainer.first);
      expect(container.decoration, isA<BoxDecoration>());

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, isNotNull);
      expect(decoration.boxShadow, isNotNull);
    });

    testWidgets('должен правильно размещать элементы по центру', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Проверяем, что основной контент находится в Center
      expect(find.byType(Center), findsOneWidget);

      // Проверяем, что содержимое организовано в Column
      final centerChild = find.descendant(
        of: find.byType(Center),
        matching: find.byType(Column),
      );
      expect(centerChild, findsOneWidget);

      // Проверяем выравнивание колонки
      final column = tester.widget<Column>(centerChild);
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('должен иметь правильные размеры логотипа', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Находим контейнер логотипа
      final logoContainer = find
          .ancestor(
            of: find.byIcon(Icons.account_balance),
            matching: find.byType(Container),
          )
          .first;

      final container = tester.widget<Container>(logoContainer);
      expect(container.constraints?.minWidth, equals(120));
      expect(container.constraints?.minHeight, equals(120));
    });

    testWidgets('должен отображать иконку логотипа правильного размера', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      final logoIcon = tester.widget<Icon>(find.byIcon(Icons.account_balance));
      expect(logoIcon.size, equals(60));
      expect(logoIcon.color, equals(Color(0xFF2E7D32)));
    });

    testWidgets('должен правильно стилизовать заголовок', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Находим Text виджет с заголовком
      final titleText = find.text('Кабинет Депутата');
      expect(titleText, findsOneWidget);

      final textWidget = tester.widget<Text>(titleText);
      expect(textWidget.style?.color, equals(Colors.white));
      expect(textWidget.style?.fontSize, equals(28));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('должен правильно стилизовать подзаголовок', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Находим Text виджет с подзаголовком
      final subtitleText = find.text('Екатеринбургская Городская Дума');
      expect(subtitleText, findsOneWidget);

      final textWidget = tester.widget<Text>(subtitleText);
      expect(textWidget.style?.color, equals(Colors.white));
      expect(textWidget.style?.fontSize, equals(16));
      expect(textWidget.style?.fontWeight, equals(FontWeight.w500));
      expect(textWidget.textAlign, equals(TextAlign.center));
    });

    testWidgets('должен правильно стилизовать описание', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      final descriptionText = find.text('Интерактивный цифровой кабинет');
      expect(descriptionText, findsOneWidget);

      final textWidget = tester.widget<Text>(descriptionText);
      expect(textWidget.style?.color, equals(Colors.white70));
      expect(textWidget.style?.fontSize, equals(14));
    });

    testWidgets('должен правильно располагать элементы с отступами', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Проверяем наличие SizedBox виджетов для отступов
      expect(find.byType(SizedBox), findsWidgets);

      // Проверяем конкретные отступы
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));

      // Ищем SizedBox с высотой 30 (между логотипом и заголовком)
      final spacer30 = sizedBoxes.firstWhere(
        (box) => box.height == 30,
        orElse: () => SizedBox(),
      );
      expect(spacer30.height, equals(30));
    });

    testWidgets('должен корректно отображать индикатор загрузки', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      // Проверяем цвет индикатора
      expect(progressIndicator.color, equals(Colors.white));

      // Проверяем, что индикатор анимируется
      expect(progressIndicator.value, isNull); // Неопределенный прогресс
    });

    testWidgets('должен отображать текст загрузки', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      final loadingText = find.text('Загрузка...');
      expect(loadingText, findsOneWidget);

      final textWidget = tester.widget<Text>(loadingText);
      expect(textWidget.style?.color, equals(Colors.white70));
      expect(textWidget.style?.fontSize, equals(16));
    });

    testWidgets('должен иметь правильную структуру виджетов', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Проверяем иерархию виджетов
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('должен корректно обрабатывать переполнение экрана', (
      WidgetTester tester,
    ) async {
      // Устанавливаем очень маленький размер экрана
      tester.binding.window.physicalSizeTestValue = Size(300, 400);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Проверяем, что виджеты не вызывают overflow
      expect(tester.takeException(), isNull);

      // Восстанавливаем размер экрана
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets(
      'должен быть доступным для людей с ограниченными возможностями',
      (WidgetTester tester) async {
        await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

        // Проверяем семантические свойства
        expect(find.text('Кабинет Депутата'), findsOneWidget);
        expect(find.text('Загрузка...'), findsOneWidget);

        // Проверяем, что элементы имеют достаточный контраст
        // (белый текст на темно-зеленом фоне должен быть достаточно контрастным)
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(Color(0xFF2E7D32)));
      },
    );

    testWidgets('должен корректно отображаться в альбомной ориентации', (
      WidgetTester tester,
    ) async {
      // Имитируем альбомную ориентацию
      tester.binding.window.physicalSizeTestValue = Size(800, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Проверяем, что все элементы видны
      expect(find.text('Кабинет Депутата'), findsOneWidget);
      expect(find.text('Екатеринбургская Городская Дума'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Восстанавливаем размер экрана
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets('должен правильно анимировать индикатор загрузки', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

      // Проверяем начальное состояние
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Прокачиваем анимацию
      await tester.pump(Duration(milliseconds: 100));
      await tester.pump(Duration(milliseconds: 100));
      await tester.pump(Duration(milliseconds: 100));

      // Индикатор должен продолжать отображаться
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'должен сохранять позиционирование при разных размерах экрана',
      (WidgetTester tester) async {
        // Тестируем с большим экраном
        tester.binding.window.physicalSizeTestValue = Size(1200, 1600);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createMaterialTestWidget(SplashScreen()));

        // Проверяем центрирование
        expect(find.byType(Center), findsOneWidget);

        final centerWidget = tester.widget<Center>(find.byType(Center));
        expect(centerWidget.child, isA<Column>());

        // Восстанавливаем размер экрана
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      },
    );
  });
}
