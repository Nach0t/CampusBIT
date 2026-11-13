import 'package:flutter/material.dart';

import 'data/db_helper.dart';
import 'logic/checkout.dart';
import 'ui/app_theme.dart';
import 'ui/widgets.dart';

class PointsScreen extends StatefulWidget {
  final String username;

  const PointsScreen({super.key, required this.username});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  int totalPoints = 0;
  List<PointsTransaction> _history = [];
  bool _isLoading = true;
  bool _redeeming = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  /// Saldo e historial guardados en la base de datos.
  Future<void> _loadPoints() async {
    try {
      final db = await DBHelper.database;
      final points = await db.getUserPoints(widget.username);
      final history = await db.getTransactions(widget.username);
      if (!mounted) return;
      setState(() {
        totalPoints = points;
        _history = history;
        _errorMessage = '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar tus puntos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _redeem(Reward reward) async {
    final confirmed = await confirmAction(
      context,
      title: 'Confirmar canje',
      message:
          '¿Canjear "${reward.name}" por ${formatNumber(reward.cost)} puntos?\n'
          'Recibirás un código QR para retirarlo en $pickupPointName.',
      confirmLabel: 'Canjear',
    );
    if (!confirmed || !mounted) return;

    setState(() => _redeeming = true);
    try {
      final db = await DBHelper.database;
      final qr = await redeemReward(
        db: db,
        username: widget.username,
        reward: reward,
      );
      await _loadPoints();
      if (!mounted) return;
      if (qr != null) {
        showAppMessage(
          context,
          '¡Has canjeado: ${reward.name}! Tu QR está en la pestaña QR.',
          type: MessageType.success,
        );
      } else {
        showAppMessage(
          context,
          'No tienes suficientes puntos para canjear este artículo',
          type: MessageType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, 'No se pudo realizar el canje: $e',
          type: MessageType.error);
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canjea tus Puntos')),
      body: AppBackground(
        child: _isLoading
            ? const LoadingView()
            : _errorMessage.isNotEmpty
                ? MessageView.error(
                    message: _errorMessage,
                    onAction: () {
                      setState(() => _isLoading = true);
                      _loadPoints();
                    },
                  )
                : RefreshIndicator(
                    onRefresh: _loadPoints,
                    child: ContentWidth(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildBalance(),
                          const SizedBox(height: 8),
                          const SectionTitle('Opciones de Canje'),
                          for (final reward in rewards)
                            _buildRedeemOption(reward),
                          const SizedBox(height: 8),
                          const SectionTitle('Historial de movimientos'),
                          if (_history.isEmpty)
                            const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Aún no tienes movimientos. '
                                  'Tus compras y canjes aparecerán aquí.',
                                  style: TextStyle(
                                      color: AppColors.textoSecundario),
                                ),
                              ),
                            ),
                          for (final tx in _history) _buildHistoryItem(tx),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildBalance() {
    return Card(
      color: AppColors.celesteOscuro,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(
              'Puntos Totales: ${formatNumber(totalPoints)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ganas 10 puntos por cada \$1.000 en compras.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Constructor de las opciones de canje
  Widget _buildRedeemOption(Reward reward) {
    final canAfford = totalPoints >= reward.cost;
    final progress = (totalPoints / reward.cost).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.texto,
                          ),
                        ),
                        Text(
                          canAfford
                              ? 'Costo: ${formatNumber(reward.cost)} puntos'
                              : 'Costo: ${formatNumber(reward.cost)} puntos · te faltan '
                                  '${formatNumber(reward.cost - totalPoints)}',
                          style:
                              const TextStyle(color: AppColors.textoSecundario),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        canAfford && !_redeeming ? () => _redeem(reward) : null,
                    child: const Text('Canjear'),
                  ),
                ],
              ),
              if (!canAfford) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.celesteAgua,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(PointsTransaction tx) {
    final positive = tx.points >= 0;
    final isPurchase = tx.type == TransactionType.purchase;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 1,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.celesteAgua,
            child: Icon(
              isPurchase ? Icons.shopping_bag : Icons.card_giftcard,
              color: AppColors.celesteOscuro,
            ),
          ),
          title: Text(tx.description),
          subtitle: Text(
            isPurchase
                ? '${formatDateTime(tx.timestamp)} · '
                    'Compra de ${formatPrice(tx.amount)}'
                : '${formatDateTime(tx.timestamp)} · Canje',
          ),
          trailing: Text(
            '${positive ? '+' : ''}${formatNumber(tx.points)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: positive ? AppColors.exito : AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}
