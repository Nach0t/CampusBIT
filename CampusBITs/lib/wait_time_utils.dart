// wait_time_utils.dart
String calcularTiempoEspera(String localName) {
  DateTime now = DateTime.now();
  int hour = now.hour;

  if (localName == 'Cafeteria' || localName == 'Hall') {
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
    int min = (5 + (hour % 3) * 5); // Ejemplo dinámico basado en la hora
    int max = min + 10;
    return '$min-$max minutos';
  }
}
