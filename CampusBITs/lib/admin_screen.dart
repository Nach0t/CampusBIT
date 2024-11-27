import 'package:flutter/material.dart';
import 'DBHelper.dart'; // Conexión con SQLite

class EditPricesScreen extends StatefulWidget {
  @override
  _EditPricesScreenState createState() => _EditPricesScreenState();
}

class _EditPricesScreenState extends State<EditPricesScreen> {
  List<Map<String, dynamic>> _menuItems = []; // Lista para almacenar los productos
  bool _isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    try {
      final dbHelper = DBHelper();
      final items = await dbHelper.getMenuItems();
      setState(() {
        _menuItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateMenuItem(int id, String newName, int newPrice) async {
    try {
      final dbHelper = DBHelper();
      await dbHelper.updateMenuItem(id, newPrice, newName);
      _fetchMenuItems(); // Refrescar los datos
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteMenuItem(int id) async {
    try {
      final dbHelper = DBHelper();
      await dbHelper.deleteMenuItem(id);
      _fetchMenuItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addNewMenuItem(String name, int price) async {
    try {
      final dbHelper = DBHelper();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Precios'),
        backgroundColor: Color(0xFF5B3E96), // Color distintivo
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          final TextEditingController nameController =
          TextEditingController(text: item['name']);
          final TextEditingController priceController =
          TextEditingController(text: item['price'].toString());

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Nombre'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'Precio'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.save, color: Colors.green),
                    onPressed: () {
                      final newName = nameController.text.trim();
                      final newPrice = int.tryParse(priceController.text) ?? 0;
                      if (newName.isNotEmpty && newPrice > 0) {
                        _updateMenuItem(item['id'], newName, newPrice);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Nombre o precio inválidos'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteMenuItem(item['id']);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF5B3E96),
        onPressed: _showAddItemDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Nuevo Producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = int.tryParse(priceController.text) ?? 0;
              if (name.isNotEmpty && price > 0) {
                _addNewMenuItem(name, price);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nombre o precio inválidos'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
