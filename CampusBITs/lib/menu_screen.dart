import 'package:flutter/material.dart';

import 'cart_screen.dart';
import 'data/db_helper.dart';
import 'logic/cart.dart';
import 'logic/checkout.dart';
import 'ui/app_theme.dart';
import 'ui/widgets.dart';

class MenuScreen extends StatefulWidget {
  final String username;

  /// Local AE donde se hace el pedido (el retiro es siempre en la Cafetería).
  final String localName;

  const MenuScreen({
    super.key,
    required this.username,
    required this.localName,
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
  /// administrador se ven al abrir el menú (o al deslizar para recargar).
  Future<void> _loadMenu() async {
    try {
      final db = await DBHelper.database;
      final items = await db.getMenuItems();
      if (!mounted) return;
      setState(() {
        menuItems = items;
        errorMessage = '';
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

  void _retry() {
    setState(() => isLoading = true);
    _loadMenu();
  }

  void _addToCart(MenuItem item) {
    _cart.add(item);
    showAppMessage(
      context,
      '${item.name} agregado al carrito',
      type: MessageType.success,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final promos =
        menuItems.where((m) => m.category == MenuCategory.promo).toList();
    final almuerzos =
        menuItems.where((m) => m.category == MenuCategory.almuerzo).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Menú de Compra')),
      body: AppBackground(
        child: isLoading
            ? const LoadingView(message: 'Cargando menú...')
            : errorMessage.isNotEmpty
                ? MessageView.error(message: errorMessage, onAction: _retry)
                : RefreshIndicator(
                    onRefresh: _loadMenu,
                    child: ContentWidth(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _PickupBanner(localName: widget.localName),
                          if (menuItems.isEmpty)
                            const MessageView(
                              icon: Icons.no_food_outlined,
                              message: 'No hay productos disponibles.',
                            ),
                          if (promos.isNotEmpty) ...[
                            const SectionTitle('Promoción Semanal'),
                            for (final item in promos) _buildMenuCard(item),
                          ],
                          if (almuerzos.isNotEmpty) ...[
                            const SectionTitle('Almuerzos Disponibles'),
                            for (final item in almuerzos) _buildMenuCard(item),
                          ],
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar:
          isLoading || errorMessage.isNotEmpty ? null : _buildCartBar(),
    );
  }

  Widget _buildMenuCard(MenuItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texto,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatPrice(item.price),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.celesteOscuro,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 110,
                child: item.images.isNotEmpty
                    ? ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: item.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) => AssetImageBox(
                          item.images[i],
                          width: 110,
                          height: 110,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: AppColors.celesteAgua,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.restaurant,
                              color: AppColors.celesteOscuro, size: 48),
                        ),
                      ),
              ),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _addToCart(item),
                    icon: const Icon(Icons.add_shopping_cart, size: 20),
                    label: const Text('Añadir'),
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
                              style: const TextStyle(
                                color: AppColors.celesteOscuro,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartBar() {
    return ListenableBuilder(
      listenable: _cart,
      builder: (context, _) {
        final hasItems = !_cart.isEmpty;
        return Material(
          color: AppColors.celesteOscuro,
          elevation: 8,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Badge(
                    isLabelVisible: hasItems,
                    label: Text('${_cart.itemCount}'),
                    child: const Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Carrito (${_cart.itemCount}) · '
                      '${formatPrice(_cart.total)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: hasItems
                        ? () {
                            // El aviso "agregado al carrito" no debe quedar
                            // encima de la pantalla siguiente.
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartScreen(
                                  cart: _cart,
                                  username: widget.username,
                                  localName: widget.localName,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.celesteOscuro,
                    ),
                    child: const Text('Ir al Carrito'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PickupBanner extends StatelessWidget {
  final String localName;

  const _PickupBanner({required this.localName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: AppColors.texto),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pedido en $localName · Retiro en $pickupPointName',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.texto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
