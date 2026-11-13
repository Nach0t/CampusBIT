import 'package:flutter/material.dart';

import 'cart_screen.dart';
import 'data/db_helper.dart';
import 'logic/cart.dart';

class MenuScreen extends StatefulWidget {
  final String username;
  final String pickupPoint;

  const MenuScreen({
    super.key,
    required this.username,
    required this.pickupPoint,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final Cart _cart = Cart();
  List<MenuItem> menuItems = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  /// El catálogo viene siempre de la base de datos, así los cambios del
  /// administrador se ven al abrir el menú.
  Future<void> _loadMenu() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final db = await DBHelper.database;
      final items = await db.getMenuItems();
      if (!mounted) return;
      setState(() {
        menuItems = items;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al cargar el menú: $e';
        isLoading = false;
      });
    }
  }

  void _addToCart(MenuItem item) {
    _cart.add(item);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.name} agregado al carrito'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final promos =
        menuItems.where((m) => m.category == MenuCategory.promo).toList();
    final almuerzos =
        menuItems.where((m) => m.category == MenuCategory.almuerzo).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menú de Compra',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4682B4),
        elevation: 5.0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? _buildError()
                : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadMenu,
                          child: ListView(
                            padding: const EdgeInsets.all(16.0),
                            children: [
                              if (menuItems.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 48),
                                  child: Text(
                                    'No hay productos disponibles.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              if (promos.isNotEmpty) ...[
                                _buildSectionTitle('Promoción Semanal:'),
                                for (final item in promos) _buildMenuCard(item),
                                const SizedBox(height: 16),
                              ],
                              if (almuerzos.isNotEmpty) ...[
                                _buildSectionTitle('Almuerzos Disponibles:'),
                                for (final item in almuerzos)
                                  _buildMenuCard(item),
                              ],
                            ],
                          ),
                        ),
                      ),
                      _buildCartButton(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMenu,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMenuCard(MenuItem item) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${item.name} - \$${item.price}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 150,
            child: item.images.isNotEmpty
                ? ListView(
                    scrollDirection: Axis.horizontal,
                    children: item.images.map((path) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            path,
                            fit: BoxFit.cover,
                            width: 120,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                              width: 120,
                              child: Icon(Icons.image_not_supported,
                                  color: Colors.white70, size: 48),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : const Center(
                    child: Icon(Icons.restaurant,
                        color: Colors.white70, size: 64),
                  ),
          ),
          if (item.description.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                item.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _addToCart(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4682B4),
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Añadir',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                ListenableBuilder(
                  listenable: _cart,
                  builder: (context, _) {
                    final qty = _cart.quantityOf(item);
                    return qty == 0
                        ? const SizedBox.shrink()
                        : Text(
                            '$qty en el carrito',
                            style: const TextStyle(color: Colors.white),
                          );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    return ListenableBuilder(
      listenable: _cart,
      builder: (context, _) {
        final hasItems = !_cart.isEmpty;
        return Container(
          color: Colors.grey[800],
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.white),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Carrito (${_cart.itemCount}) · \$${_cart.total}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: hasItems
                      ? () {
                          // El aviso "agregado al carrito" taparía el botón
                          // "Pagar" de la pantalla siguiente.
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartScreen(
                                cart: _cart,
                                username: widget.username,
                                pickupPoint: widget.pickupPoint,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasItems ? Colors.white : Colors.grey[600],
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Ir al Carrito',
                    style: TextStyle(
                      color:
                          hasItems ? const Color(0xFF4682B4) : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
