import 'package:flutter/material.dart';
import 'DBHelper.dart';

class EditPricesScreen extends StatefulWidget {
  @override
  _EditPricesScreenState createState() => _EditPricesScreenState();
}

class _EditPricesScreenState extends State<EditPricesScreen> {
  List<Map<String, dynamic>> menuItems = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuItems() async {
    try {
      final dbHelper = DBHelper();
      final items = await dbHelper.getMenuItems();
      setState(() {
        menuItems = items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los productos.')),
      );
    }
  }

  Future<void> _updatePrice(int id, int newPrice) async {
    try {
      final dbHelper = DBHelper();
      await dbHelper.updateMenuItem(id, newPrice);
      _loadMenuItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Precio actualizado correctamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el precio.')),
      );
    }
  }

  Future<void> _addMenuItem(String name, int price) async {
    try {
      final dbHelper = DBHelper();
      await dbHelper.insertMenuItem(name, price);
      _nameController.clear();
      _priceController.clear();
      _loadMenuItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto agregado correctamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar el producto.')),
      );
    }
  }

  Future<void> _deleteMenuItem(int id) async {
    try {
      final dbHelper = DBHelper();
      await dbHelper.deleteMenuItem(id);
      _loadMenuItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado correctamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el producto.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Precios',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF5B3E96),
        elevation: 5.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF71679C), Color(0xFF44337A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                  text: item['price'].toString()),
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: item['name'],
                                labelStyle: TextStyle(color: Colors.white),
                                filled: true,
                                fillColor: Colors.grey[800],
                              ),
                              keyboardType: TextInputType.number,
                              onSubmitted: (value) {
                                if (value.isNotEmpty && int.tryParse(value) != null) {
                                  _updatePrice(item['id'], int.parse(value));
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteMenuItem(item['id']);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Agregar Nuevo Producto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nombre del Producto',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _priceController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Precio del Producto',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty &&
                      _priceController.text.isNotEmpty &&
                      int.tryParse(_priceController.text) != null) {
                    _addMenuItem(
                        _nameController.text, int.parse(_priceController.text));
                  }
                },
                child: Text('Agregar Producto', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B3E96),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
