import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'data/db_helper.dart';
import 'qr_detail_screen.dart';
import 'ui/app_theme.dart';
import 'ui/widgets.dart';

/// Lista los códigos QR del usuario (pestaña "QR" e historial).
///
/// Esta pantalla solo lee y elimina: los códigos se crean al pagar o al
/// canjear puntos, una sola vez, dentro de la transacción de la compra.
class QrCodesScreen extends StatefulWidget {
  final String username;

  /// Códigos recién creados (se resaltan al llegar desde el carrito).
  final List<GeneratedQr> newCodes;

  /// Mensaje opcional que se muestra arriba de la lista.
  final String? message;

  const QrCodesScreen({
    super.key,
    required this.username,
    this.newCodes = const [],
    this.message,
  });

  @override
  State<QrCodesScreen> createState() => _QrCodesScreenState();
}

class _QrCodesScreenState extends State<QrCodesScreen> {
  List<GeneratedQr> _qrList = [];
  bool isLoading = true;
  String errorMessage = '';

  late final Set<String> _newIds = widget.newCodes.map((q) => q.id).toSet();

  @override
  void initState() {
    super.initState();
    _loadQrCodes();
  }

  Future<void> _loadQrCodes() async {
    try {
      final db = await DBHelper.database;
      final data = await db.getQrCodesForUser(widget.username);
      if (!mounted) return;
      setState(() {
        _qrList = data;
        errorMessage = '';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al cargar los QR: $e';
        isLoading = false;
      });
    }
  }

  void _showQrDetails(GeneratedQr qr) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QrDetailScreen(qr: qr)),
    );
  }

  Future<void> _confirmDelete(GeneratedQr qr) async {
    final confirmed = await confirmAction(
      context,
      title: 'Eliminar código QR',
      message: '¿Eliminar el QR de "${qr.menuType}"? '
          'No podrás usarlo para retirar el pedido.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      final db = await DBHelper.database;
      await db.deleteQrCode(qr.id);
      await _loadQrCodes(); // Solo recarga; no genera nada nuevo
      if (!mounted) return;
      showAppMessage(context, 'Código QR eliminado');
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, 'Error al eliminar QR: $e',
          type: MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vigentes = _qrList.where((q) => !q.isExpired).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Mis códigos QR')),
      body: AppBackground(
        child: isLoading
            ? const LoadingView()
            : errorMessage.isNotEmpty
                ? MessageView.error(
                    message: errorMessage,
                    onAction: () {
                      setState(() => isLoading = true);
                      _loadQrCodes();
                    },
                  )
                : RefreshIndicator(
                    onRefresh: _loadQrCodes,
                    child: ContentWidth(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (widget.message != null) _buildMessage(),
                          if (_qrList.isEmpty)
                            const MessageView(
                              icon: Icons.qr_code_2,
                              message: 'No hay códigos QR disponibles.\n'
                                  'Aparecerán aquí al comprar o canjear '
                                  'puntos.',
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                '$vigentes vigente(s) de ${_qrList.length} · '
                                'toca un código para verlo en grande',
                                style: const TextStyle(
                                    color: AppColors.texto, fontSize: 14),
                              ),
                            ),
                          for (final qr in _qrList) _buildQrCard(qr),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: AppColors.exito,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrCard(GeneratedQr qr) {
    final isNew = _newIds.contains(qr.id);
    final expired = qr.isExpired;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isNew
              ? const BorderSide(color: AppColors.exito, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () => _showQrDetails(qr),
          onLongPress: () => _confirmDelete(qr),
          child: Opacity(
            opacity: expired ? 0.6 : 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
              child: Row(
                children: [
                  QrImage(
                    data: qr.id,
                    version: QrVersions.auto,
                    size: 64,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (isNew)
                              const _Tag('Nuevo', color: AppColors.exito),
                            if (expired)
                              const _Tag('Vencido', color: AppColors.error),
                            if (qr.price == 0)
                              const _Tag('Canje',
                                  color: AppColors.celesteOscuro),
                          ],
                        ),
                        Text(
                          'Menú: ${qr.menuType}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.texto,
                          ),
                        ),
                        Text('Retiro: ${qr.pickupPoint}', style: _detailStyle),
                        if (qr.price > 0)
                          Text('Precio: ${formatPrice(qr.price)}',
                              style: _detailStyle),
                        Text(
                          expired
                              ? 'Venció el ${formatDateTime(qr.validity)}'
                              : 'Válido hasta: ${formatDateTime(qr.validity)}',
                          style: _detailStyle.copyWith(
                            color: expired ? AppColors.error : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.textoSecundario,
                    onPressed: () => _confirmDelete(qr),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _detailStyle = TextStyle(
    fontSize: 14,
    color: AppColors.textoSecundario,
  );
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
