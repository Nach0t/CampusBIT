/// Locales con más demanda (cafetería principal y hall): su tiempo de
/// espera depende de la hora punta del almuerzo.
bool _esLocalConcurrido(String localName) {
  final name = localName.toLowerCase();
  return name.contains('cafeteria') ||
      name.contains('casino') ||
      name.contains('hall');
}

/// Tiempo de espera estimado para retirar en [localName].
///
/// Antes se comparaba con 'Cafeteria' y 'Hall' exactos, pero los locales se
/// llaman 'Punto Casino', 'Punto Hall', etc., así que la hora punta nunca
/// se aplicaba.
String calcularTiempoEspera(String localName, {DateTime? now}) {
  final hour = (now ?? DateTime.now()).hour;

  if (_esLocalConcurrido(localName)) {
    if (hour >= 13 && hour < 14) {
      return '20-30 minutos';
    } else if (hour >= 12 && hour < 13) {
      return '10-20 minutos';
    } else if (hour >= 11 && hour < 12) {
      return '5-10 minutos';
    } else {
      return '30-45 minutos o más';
    }
  } else {
    // Tiempos de espera genéricos para otros locales
    final min = 5 + (hour % 3) * 5; // Ejemplo dinámico basado en la hora
    final max = min + 10;
    return '$min-$max minutos';
  }
}
