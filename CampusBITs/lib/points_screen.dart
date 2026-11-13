import 'package:flutter/material.dart';

import 'data/db_helper.dart';
import 'logic/checkout.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar canje'),
        content: Text(
            '¿Canjear "${reward.name}" por ${reward.cost} puntos?\n'
            'Recibirás un código QR para retirarlo en $rewardPickupPoint.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Canjear'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

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
      ScaffoldMessenger.of(context).showSnackBar(
        qr != null
            ? SnackBar(
                content: Text(
                  '¡Has canjeado: ${reward.name}! Tu QR está en la pestaña QR.',
                  style: const TextStyle(fontFamily: 'Exo2'),
                ),
                backgroundColor: Colors.green,
              )
            : const SnackBar(
                content: Text(
                  'No tienes suficientes puntos para canjear este artículo',
                  style: TextStyle(fontFamily: 'Exo2'),
                ),
                backgroundColor: Colors.redAccent,
              ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo realizar el canje: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Canjea tus Puntos',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4682B4),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPoints,
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        _buildBalance(),
                        const SizedBox(height: 8),
                        const Text(
                          'Ganas 10 puntos por cada \$1.000 en compras.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        _buildTitle('Opciones de Canje:'),
                        for (final reward in rewards) _buildRedeemOption(reward),
                        const SizedBox(height: 24),
                        _buildTitle('Historial de movimientos:'),
                        if (_history.isEmpty)
                          const Text(
                            'Aún no tienes movimientos.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        for (final tx in _history) _buildHistoryItem(tx),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildBalance() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Puntos Totales: $totalPoints',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Constructor de las opciones de canje
  Widget _buildRedeemOption(Reward reward) {
    final canAfford = totalPoints >= reward.cost;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            reward.name,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(
            canAfford
                ? 'Costo: ${reward.cost} puntos'
                : 'Costo: ${reward.cost} puntos · te faltan '
                    '${reward.cost - totalPoints}',
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: canAfford
              ? ElevatedButton(
                  onPressed: _redeeming ? null : () => _redeem(reward),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4682B4),
                  ),
                  child: const Text('Canjear',
                      style: TextStyle(color: Colors.white)),
                )
              : const Text(
                  'No suficientes\npuntos',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(PointsTransaction tx) {
    final positive = tx.points >= 0;
    final d = tx.timestamp.toLocal();
    final date = '${d.day}/${d.month}/${d.year}';
    return Card(
      color: Colors.white.withValues(alpha: 0.15),
      elevation: 0,
      child: ListTile(
        leading: Icon(
          tx.type == TransactionType.purchase
              ? Icons.shopping_bag
              : Icons.card_giftcard,
          color: Colors.white,
        ),
        title: Text(tx.description,
            style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          tx.type == TransactionType.purchase
              ? '$date · Compra de \$${tx.amount}'
              : '$date · Canje',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Text(
          '${positive ? '+' : ''}${tx.points}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: positive ? Colors.green.shade800 : Colors.red.shade700,
          ),
        ),
      ),
    );
  }
}
