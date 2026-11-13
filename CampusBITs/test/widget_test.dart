import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_bit_app/company_selection_screen.dart';
import 'package:campus_bit_app/main.dart';

void main() {
  testWidgets('La app inicia en la pantalla de login', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bienvenido a CampusBite'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('Login con campos vacíos muestra un error', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(
      find.text('Por favor, ingresa un nombre de usuario y una contraseña.'),
      findsOneWidget,
    );
    expect(find.byType(CompanySelectionScreen), findsNothing);
  });

  testWidgets('Login válido navega a la selección de empresa', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).at(0), 'alumno');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(CompanySelectionScreen), findsOneWidget);
  });
}
