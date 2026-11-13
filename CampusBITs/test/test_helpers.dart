import 'package:flutter_test/flutter_test.dart';

/// Los widget tests corren con un reloj simulado; la base en memoria usa
/// async real, así que sus operaciones se ejecutan dentro de `runAsync`.
Future<T> real<T>(WidgetTester tester, Future<T> Function() action) async {
  return (await tester.runAsync(action)) as T;
}

/// Deja que terminen las operaciones de base pendientes y redibuja.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}
