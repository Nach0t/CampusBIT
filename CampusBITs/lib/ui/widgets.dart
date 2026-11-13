import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Número con separador de miles chileno: 4500 -> "4.500".
String formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}$buffer';
}

/// Precio en pesos chilenos con separador de miles: 3300 -> "$3.300".
String formatPrice(int amount) =>
    '${amount < 0 ? '-' : ''}\$${formatNumber(amount.abs())}';

/// Fecha corta: 10/3/2026 14:05.
String formatDateTime(DateTime date) {
  final d = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.day}/${d.month}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}

/// Fondo degradado celeste de todas las pantallas.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.fondo),
      child: SizedBox.expand(child: child),
    );
  }
}

/// Limita el ancho del contenido en pantallas grandes (Web, tablets) para
/// que las tarjetas no se estiren de borde a borde.
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentWidth({super.key, required this.child, this.maxWidth = 640});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      // Alto = el del hijo. Sin esto, Align ocupa todo el alto disponible
      // (por ejemplo, un panel en bottomNavigationBar taparía la pantalla).
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(color: AppColors.texto)),
          ],
        ],
      ),
    );
  }
}

/// Mensaje centrado con ícono, para estados vacíos y de error.
class MessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  const MessageView({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isError = false,
  });

  const MessageView.error({
    super.key,
    required this.message,
    this.actionLabel = 'Reintentar',
    this.onAction,
  })  : icon = Icons.error_outline,
        isError = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: isError ? AppColors.error : AppColors.celesteOscuro,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: isError ? AppColors.error : AppColors.texto,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.texto,
        ),
      ),
    );
  }
}

/// Imagen de los assets con un ícono de respaldo si no se puede cargar.
class AssetImageBox extends StatelessWidget {
  final String path;
  final double width;
  final double height;
  final BoxFit fit;

  const AssetImageBox(
    this.path, {
    super.key,
    this.width = 120,
    this.height = 120,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: AppColors.celesteAgua,
          child: const Icon(Icons.image_not_supported,
              color: AppColors.celesteOscuro),
        ),
      ),
    );
  }
}

enum MessageType { success, error, info }

/// Aviso flotante consistente en toda la app.
void showAppMessage(
  BuildContext context,
  String message, {
  MessageType type = MessageType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final color = switch (type) {
    MessageType.success => AppColors.exito,
    MessageType.error => AppColors.error,
    MessageType.info => AppColors.texto,
  };
  final icon = switch (type) {
    MessageType.success => Icons.check_circle,
    MessageType.error => Icons.error,
    MessageType.info => Icons.info,
  };
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: color,
        duration: duration,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

/// Diálogo de confirmación. Devuelve `true` solo si el usuario confirma.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor:
                destructive ? AppColors.error : AppColors.celesteOscuro,
            // fontFamily explícito: un textStyle propio reemplaza la fuente
            // del tema (en el teléfono este botón salía en Roboto).
            textStyle: const TextStyle(
              fontFamily: appFont,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
