import 'package:flutter/material.dart';
import 'CartScreen.dart';
import 'DBHelper.dart'; // Importar correctamente el archivo DBHelper

class MenuScreen extends StatefulWidget {
  final String username;

  MenuScreen({required this.username});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> menuItems = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menú de Compra',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF5B3E96), // Morado más oscuro
        elevation: 5.0, // Elevación para darle sombra al AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF71679C), Color(0xFF44337A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: menuItems.isEmpty
            ? Center(
          child: CircularProgressIndicator(), // Indicador de carga mientras se cargan los datos
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(
                            menuItem: item['name'],
                            price: item['price'],
                            username: widget.username,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF71679C),
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text('Comprar', style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
