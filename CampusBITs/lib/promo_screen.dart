import 'package:flutter/material.dart';
import 'DBHelper.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> menuItems = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    try {
      final items = await dbHelper.getMenuItems();
      setState(() {
        menuItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar los menús: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menús Disponibles',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF4682B4), // Celeste oscuro
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Gradiente de fondo
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
            : menuItems.isEmpty
            ? Center(
          child: Text(
            'No hay menús disponibles.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                'Selecciona tu menú favorito:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              _buildMenuSection(
                context: context,
                sectionTitle: 'Menús Disponibles',
                menus: menuItems,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required BuildContext context,
    required String sectionTitle,
    required List<Map<String, dynamic>> menus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        ...menus.map((menu) {
          return Card(
            color: Colors.white.withOpacity(0.1),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      menu['imagePath'] != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          menu['imagePath'],
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                          : SizedBox.shrink(),
                      SizedBox(width: 16),
                      Text(
                        '${menu['name']} - \$${menu['price']}',
                        style: TextStyle(
                          color: Color(0xFF4682B4),
                          fontSize: 18,
                          fontFamily: 'Exo2',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Seleccionaste: ${menu['name']} - \$${menu['price']}'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4682B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'Seleccionar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
