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

  testWidgets('Login con campos vacíos marca los campos con error',
      (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Ingresa tu usuario'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(find.byType(CompanySelectionScreen), findsNothing);

    // Al completar solo el usuario, queda el error de la contraseña.
    await tester.enterText(find.byType(TextField).at(0), 'alumno');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Ingresa tu usuario'), findsNothing);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });

  testWidgets('El botón del ojo muestra y oculta la contraseña',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    EditableText password() =>
        tester.widget<EditableText>(find.byType(EditableText).at(1));

    expect(password().obscureText, isTrue);
    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();
    expect(password().obscureText, isFalse);
  });

  testWidgets('admin/admin abre la administración', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'admin');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Administrar menú'), findsOneWidget);
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
