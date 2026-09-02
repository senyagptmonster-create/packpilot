import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:packpilot/app/theme.dart';
import 'package:packpilot/product/product_app.dart';

void main() {
  setUp(() {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget app() => MaterialApp(theme: AppTheme.build(), home: const ProductApp());

  testWidgets('каталог поездок открывается', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('PackPilot'), findsOneWidget);
    expect(find.text('Поездка в Стамбул'), findsWidgets);
    expect(find.text('Открыть чек-лист'), findsWidgets);
  });

  testWidgets('вкладки переключаются без ошибок', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Чек-лист'));
    await tester.pumpAndSettle();
    expect(find.text('Поездка в Стамбул'), findsWidgets);

    await tester.tap(find.text('Багаж'));
    await tester.pumpAndSettle();
    expect(find.text('Готовность багажа'), findsWidgets);

    await tester.tap(find.text('Опции'));
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsWidgets);
  });

  testWidgets('на узком экране ничего не переполняется', (tester) async {
    tester.view.physicalSize = const Size(720, 1440);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
