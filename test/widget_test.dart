// Test básico para la aplicación de inventario de ferretería.
//
// Para realizar una interacción con un widget en tu test, usa WidgetTester
// utility en el paquete flutter_test. Por ejemplo, puedes enviar gestos de tap y scroll.
// También puedes usar WidgetTester para encontrar widgets hijos en el árbol de widgets,
// leer texto, y verificar que los valores de las propiedades del widget son correctos.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_proyecto/main.dart';

void main() {
  testWidgets('Ferretería app loads home screen', (WidgetTester tester) async {
    // Construye nuestra app y dispara un frame.
    await tester.pumpWidget(MyApp());

    // Verifica que la pantalla principal se carga correctamente.
    // Busca elementos típicos de la pantalla de inicio
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Container), findsWidgets);

    // Verifica que la app se construye sin errores
    expect(tester.takeException(), isNull);
  });

  testWidgets('MyApp creates MaterialApp', (WidgetTester tester) async {
    // Construye la app
    await tester.pumpWidget(MyApp());

    // Verifica que se crea una MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
