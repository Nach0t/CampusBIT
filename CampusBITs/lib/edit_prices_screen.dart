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
  bool isLoading = true; // Estado para indicar si los datos están cargando
  String errorMessage = ''; // Mensaje de error en caso de problemas

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
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar los productos: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _updatePrice(int id, int newPrice) async {
    final dbHelper = DBHelper();
    await dbHelper.updateMenuItem(id, newPrice);
    _loadMenuItems();
  }



  Future<void> _deleteMenuItem(int id) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteMenuItem(id);
    _loadMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Precios',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF4682B4), // Celeste oscuro
        elevation: 5.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Gradiente celeste agua
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
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    final TextEditingController _priceController =
                    TextEditingController(
                        text: item['price'].toString());
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _priceController,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Exo2'),
                              decoration: InputDecoration(
                                labelText: item['name'],
                                labelStyle: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'Exo2'),
                                filled: true,
                                fillColor:
                                Color(0xFF5F9EA0), // Celeste oscuro
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  _updatePrice(
                                      item['id'], int.parse(value));
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon:
                            Icon(Icons.delete, color: Colors.red),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Exo2',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Exo2'),
                decoration: InputDecoration(
                  hintText: 'Nombre del Producto',
                  hintStyle: TextStyle(
                      color: Colors.white70, fontFamily: 'Exo2'),
                  filled: true,
                  fillColor: Color(0xFF5F9EA0), // Celeste oscuro
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _priceController,
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Exo2'),
                decoration: InputDecoration(
                  hintText: 'Precio del Producto',
                  hintStyle: TextStyle(
                      color: Colors.white70, fontFamily: 'Exo2'),
                  filled: true,
                  fillColor: Color(0xFF5F9EA0), // Celeste oscuro
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty &&
                      _priceController.text.isNotEmpty) {

                  }
                },
                child: Text(
                  'Agregar Producto',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Exo2',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Color(0xFF4682B4), // Celeste oscuro
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
