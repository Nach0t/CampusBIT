import 'dart:convert';

/// Producto del menú (almuerzos, promos, etc.).
class MenuItem {
  final int? id;
  final String name;
  final int price;
  final String description;
  final List<String> images;

  const MenuItem({
    this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.images = const [],
  });

  MenuItem copyWith({
    int? id,
    String? name,
    int? price,
    String? description,
    List<String>? images,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      images: images ?? this.images,
    );
  }

  @override
  String toString() => 'MenuItem($id, $name, \$$price)';
}

/// Código QR de retiro generado por una compra.
class GeneratedQr {
  final String id; // UUID v4, es el contenido del QR
  final String menuType;
  final int price;
  final String username;
  final String pickupPoint;
  final DateTime validity;

  const GeneratedQr({
    required this.id,
    required this.menuType,
    required this.price,
    required this.username,
    required this.pickupPoint,
    required this.validity,
  });

  bool get isExpired => DateTime.now().isAfter(validity);

  Map<String, Object?> toMap() => {
        'id': id,
        'menuType': menuType,
        'price': price,
        'username': username,
        'pickupPoint': pickupPoint,
        'validity': validity.toIso8601String(),
      };

  factory GeneratedQr.fromMap(Map<String, Object?> map) {
    return GeneratedQr(
      id: map['id'] as String,
      menuType: map['menuType'] as String,
      price: _asInt(map['price']),
      username: map['username'] as String,
      pickupPoint: map['pickupPoint'] as String,
      validity: DateTime.parse(map['validity'] as String),
    );
  }
}

enum TransactionType { purchase, redemption }

/// Movimiento de puntos: una compra (suma) o un canje (resta).
class PointsTransaction {
  final int? id;
  final String username;
  final TransactionType type;
  final String description;

  /// Monto en pesos de la compra (0 en los canjes).
  final int amount;

  /// Puntos del movimiento: positivo al comprar, negativo al canjear.
  final int points;
  final DateTime timestamp;

  const PointsTransaction({
    this.id,
    required this.username,
    required this.type,
    required this.description,
    required this.amount,
    required this.points,
    required this.timestamp,
  });

  Map<String, Object?> toMap() => {
        'username': username,
        'type': type.name,
        'description': description,
        'amount': amount,
        'points': points,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PointsTransaction.fromMap(Map<String, Object?> map, {int? id}) {
    return PointsTransaction(
      id: id ?? map['id'] as int?,
      username: map['username'] as String,
      type: TransactionType.values.byName(map['type'] as String),
      description: map['description'] as String,
      amount: _asInt(map['amount']),
      points: _asInt(map['points']),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

/// Lee la lista de imágenes guardada como JSON (`["assets/a.png"]`).
///
/// Acepta también el formato antiguo sin comillas que podía quedar en
/// bases creadas por versiones previas.
List<String> decodeImages(Object? raw) {
  if (raw == null) return [];
  if (raw is List) return List<String>.from(raw);
  final text = (raw as String).trim();
  if (text.isEmpty) return [];
  try {
    return (jsonDecode(text) as List).cast<String>();
  } on FormatException {
    return text
        .replaceAll(RegExp(r'[\[\]"]'), '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

String encodeImages(List<String> images) => jsonEncode(images);

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
