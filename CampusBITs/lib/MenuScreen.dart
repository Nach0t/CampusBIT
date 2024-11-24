import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'DBHelper.dart';

class MenuScreen extends StatefulWidget {
  final String username;

  MenuScreen({required this.username});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  void _loadMenuItems() async {
    final items = await dbHelper.getMenuItems();
    setState(() {
      menuItems = items;
    });
  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      cartItems.add(item);
    });
  }

  int getCartItemCount() {
    return cartItems.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menú de Compra',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF87CEEB), // Celeste agua
        elevation: 5.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Degradado celeste agua
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: menuItems.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Promoción Semanal:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Exo2',
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildPromoItem('Promo desayuno', 1800),
                            _buildPromoItem('Promo almuerzo', 2500),
                            SizedBox(height: 32),
                            Text(
                              'Almuerzos:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Exo2',
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: menuItems.length,
                              itemBuilder: (context, index) {
                                final item = menuItems[index];
                                return Card(
                                  color: Colors.white.withOpacity(0.1),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      '${item['name']} - \$${item['price']}',
                                      style: TextStyle(
                                        fontFamily: 'Exo2',
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        _addToCart(item);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF87CEEB),
                                        elevation: 3.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Añadir',
                                        style: TextStyle(
                                          fontFamily: 'Exo2',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.grey[800],
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Carrito (${getCartItemCount()})',
                              style: TextStyle(
                                fontFamily: 'Exo2',
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: cartItems.isNotEmpty
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CartScreen(
                                        cartItems: cartItems,
                                        username: widget.username,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            'Ir al Carrito',
                            style: TextStyle(
                              fontFamily: 'Exo2',
                              color: Color(0xFF87CEEB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPromoItem(String name, int price) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListTile(
        title: Text(
          '$name - \$$price',
          style: TextStyle(
            fontFamily: 'Exo2',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            _addToCart({'name': name, 'price': price});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF87CEEB),
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Text(
            'Añadir',
            style: TextStyle(
              fontFamily: 'Exo2',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
