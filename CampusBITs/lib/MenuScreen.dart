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
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Configuración inicial del menú
    menuItems = [
      {
        'name': 'Almuerzo ejecutivo',
        'price': 3500,
        'images': [
          'assets/Pollo.png',
          'assets/Consome.png',
          'assets/Jugo.png',
          'assets/Ensa.png'
        ],
        'description': 'Incluye consomé, plato fuerte, ensalada y jugo.'
      },
      {
        'name': 'Almuerzo normal',
        'price': 3300,
        'images': ['assets/Pollo.png', 'assets/Consome.png', 'assets/Jugo.png'],
        'description': 'Incluye consomé, plato fuerte y jugo.'
      },
      {
        'name': 'Hipocalórico',
        'price': 3200,
        'images': ['assets/Bawl.png'],
        'description': 'Bawl naturista a elección.'
      },
      {
        'name': 'Vegetariana',
        'price': 3000,
        'images': ['assets/Vegano.png'],
        'description': 'Hamburgesa de quinoa con arroz.'
      },
    ];
    setState(() {
      isLoading = false;
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
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF4682B4),
        elevation: 5.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        )
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promoción Semanal:',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildPromoItem(
                        'Promo desayuno',
                        1800,
                        ['assets/PromoDesayuno.png', 'assets/Cafe.png'],
                        'PAN CON PALTA JAMÓN + CAFÉ EXPRESO PEQUEÑO',
                      ),
                      SizedBox(height: 16),
                      _buildPromoItem(
                        'Promo almuerzo',
                        2500,
                        ['assets/PromoAlmuerzo.png', 'assets/Cafe.png'],
                        'SAND CHEESEBURGER BBQ + BEBIDA MÁQUINA O JUGO 200 CC',
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Almuerzos Disponibles:',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildAlmuerzoSection(menuItems),
                    ],
                  ),
                ),
              ),
            ),
            _buildCartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoItem(
      String name, int price, List<String> imagePaths, String description) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$name - \$$price',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: imagePaths.map((path) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      path,
                      fit: BoxFit.cover,
                      width: 120,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _addToCart({'name': name, 'price': price});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4682B4),
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text('Añadir', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlmuerzoSection(List<Map<String, dynamic>> almuerzos) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: almuerzos.length,
      itemBuilder: (context, index) {
        final item = almuerzos[index];

        final List<String> images = item['images'] is List
            ? List<String>.from(item['images'])
            : [];
        final String description =
            item['description'] ?? 'Descripción no disponible';

        return Card(
          color: Colors.white.withOpacity(0.1),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${item['name']} - \$${item['price']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                height: 150,
                child: images.isNotEmpty
                    ? ListView(
                  scrollDirection: Axis.horizontal,
                  children: images.map((path) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          path,
                          fit: BoxFit.cover,
                          width: 120,
                        ),
                      ),
                    );
                  }).toList(),
                )
                    : Center(
                  child: Text(
                    'No hay imágenes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _addToCart(item);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4682B4),
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text('Añadir', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartButton() {
    return Container(
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
              backgroundColor: cartItems.isNotEmpty ? Colors.white : Colors.grey[600],
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              'Ir al Carrito',
              style: TextStyle(
                color: cartItems.isNotEmpty ? Color(0xFF4682B4) : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
