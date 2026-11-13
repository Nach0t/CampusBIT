import 'package:flutter/material.dart';

import 'data/db_helper.dart';
import 'ui/app_theme.dart';
import 'ui/widgets.dart';

/// Imágenes de comida disponibles en assets/ para los productos nuevos.
const List<String> foodImages = [
  'assets/Pollo.png',
  'assets/Consome.png',
  'assets/Ensa.png',
  'assets/Ensalada.png',
  'assets/Jugo.png',
  'assets/Bawl.png',
  'assets/Vegano.png',
  'assets/Cafe.png',
  'assets/PromoDesayuno.png',
  'assets/PromoAlmuerzo.png',
];

/// Valida un precio escrito por el administrador. Devuelve el mensaje de
/// error o `null` si es válido.
String? validatePrice(String? value) {
  final price = int.tryParse((value ?? '').trim());
  if (price == null) return 'Ingresa un número';
  if (price <= 0) return 'Debe ser mayor que 0';
  if (price > 1000000) return 'Precio demasiado alto';
  return null;
}

String? validateName(String? value) =>
    (value == null || value.trim().isEmpty) ? 'Ingresa un nombre' : null;

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    try {
      final db = await DBHelper.database;
      final items = await db.getMenuItems();
      if (!mounted) return;
      setState(() {
        _menuItems = items;
        _errorMessage = '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar los productos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMenuItem(MenuItem updated) async {
    try {
      final db = await DBHelper.database;
      await db.updateMenuItem(updated);
      await _fetchMenuItems();
      if (!mounted) return;
      showAppMessage(context, '"${updated.name}" actualizado',
          type: MessageType.success);
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, 'Error al actualizar: $e',
          type: MessageType.error);
    }
  }

  Future<void> _confirmDelete(MenuItem item) async {
    final confirmed = await confirmAction(
      context,
      title: 'Eliminar producto',
      message: '¿Eliminar "${item.name}" del menú?',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      final db = await DBHelper.database;
      await db.deleteMenuItem(item.id!);
      await _fetchMenuItems();
      if (!mounted) return;
      showAppMessage(context, '"${item.name}" eliminado');
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, 'Error al eliminar: $e',
          type: MessageType.error);
    }
  }

  Future<void> _addNewMenuItem(MenuItem item) async {
    try {
      final db = await DBHelper.database;
      await db.insertMenuItem(item);
      await _fetchMenuItems();
      if (!mounted) return;
      showAppMessage(context, '"${item.name}" agregado al menú',
          type: MessageType.success);
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, 'Error al agregar: $e',
          type: MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar menú')),
      body: AppBackground(
        child: _isLoading
            ? const LoadingView()
            : _errorMessage.isNotEmpty
                ? MessageView.error(
                    message: _errorMessage,
                    onAction: () {
                      setState(() => _isLoading = true);
                      _fetchMenuItems();
                    },
                  )
                : ContentWidth(
                    maxWidth: 760,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      children: [
                        const Text(
                          'Edita nombre o precio y guarda con el ícono verde. '
                          'Los cambios se ven en el menú al abrirlo.',
                          style: TextStyle(color: AppColors.texto),
                        ),
                        const SizedBox(height: 12),
                        if (_menuItems.isEmpty)
                          const MessageView(
                            icon: Icons.no_food_outlined,
                            message: 'No hay productos. Agrega uno con el '
                                'botón "+".',
                          ),
                        for (final item in _menuItems)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AdminItemRow(
                              // La key por id + valores hace que la fila se
                              // reinicie solo cuando el producto cambia.
                              key: ValueKey(
                                  '${item.id}-${item.name}-${item.price}'),
                              item: item,
                              onSave: _updateMenuItem,
                              onDelete: () => _confirmDelete(item),
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.celesteOscuro,
        foregroundColor: Colors.white,
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  Future<void> _showAddItemDialog() async {
    final item = await showDialog<MenuItem>(
      context: context,
      builder: (context) => const _AddItemDialog(),
    );
    if (item != null) await _addNewMenuItem(item);
  }
}

/// Fila editable de un producto, con sus propios controladores (así lo
/// escrito no se pierde cuando la lista se redibuja).
class _AdminItemRow extends StatefulWidget {
  final MenuItem item;
  final Future<void> Function(MenuItem updated) onSave;
  final VoidCallback onDelete;

  const _AdminItemRow({
    super.key,
    required this.item,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_AdminItemRow> createState() => _AdminItemRowState();
}

class _AdminItemRowState extends State<_AdminItemRow> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.item.name);
  late final _priceController =
      TextEditingController(text: widget.item.price.toString());
  bool _saving = false;

  bool get _isDirty =>
      _nameController.text.trim() != widget.item.name ||
      _priceController.text.trim() != widget.item.price.toString();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.onSave(widget.item.copyWith(
      name: _nameController.text.trim(),
      price: int.parse(_priceController.text.trim()),
    ));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}), // Actualiza el estado "sin guardar"
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item.images.isNotEmpty
                  ? AssetImageBox(item.images.first, width: 56, height: 56)
                  : Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.celesteAgua,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.restaurant,
                          color: AppColors.celesteOscuro),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.celesteOscuro,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // En pantallas angostas los campos van en columna.
                        final narrow = constraints.maxWidth < 360;
                        final name = TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            isDense: true,
                          ),
                          validator: validateName,
                        );
                        final price = TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Precio',
                            prefixText: '\$ ',
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          validator: validatePrice,
                        );
                        return narrow
                            ? Column(children: [
                                name,
                                const SizedBox(height: 8),
                                price,
                              ])
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: name),
                                  const SizedBox(width: 8),
                                  Expanded(flex: 2, child: price),
                                ],
                              );
                      },
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    tooltip: 'Guardar cambios',
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    color: AppColors.exito,
                    onPressed: _isDirty && !_saving ? _save : null,
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                    onPressed: _saving ? null : widget.onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo para crear un producto. Devuelve el producto o `null`.
class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  var _category = MenuCategory.almuerzo;
  String? _image;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      MenuItem(
        name: _nameController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        category: _category,
        images: [if (_image != null) _image!],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Nuevo Producto'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: validateName,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: validatePrice,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MenuCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Sección'),
                  items: [
                    for (final c in MenuCategory.values)
                      DropdownMenuItem(value: c, child: Text(c.label)),
                  ],
                  onChanged: (value) =>
                      setState(() => _category = value ?? _category),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Imagen (opcional)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final path in foodImages)
                      GestureDetector(
                        onTap: () => setState(
                            () => _image = _image == path ? null : path),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _image == path
                                  ? AppColors.celesteOscuro
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: AssetImageBox(path, width: 52, height: 52),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Agregar')),
      ],
    );
  }
}
