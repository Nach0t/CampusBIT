# campus_bit_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


lib/
├── main.dart                 # Punto de entrada principal de la aplicación
├── android/                  # Todas las pantallas de la aplicación organizadas
│   ├── admin/                # Pantallas relacionadas con administración
│   │   ├── admin_screen.dart # Pantalla para funciones administrativas
│   ├── cart/                 # Pantallas relacionadas con carrito
│   │   ├── cart_screen.dart  # Pantalla para el carrito de compras
│   │   ├── punto_retiro_screen.dart # Pantalla para seleccionar puntos de retiro
│   ├── company/              # Pantallas relacionadas con empresas
│   │   ├── company_selection_screen.dart # Pantalla de selección de empresa
│   ├── qr/                   # Funcionalidades de QR
│   │   ├── generate_qr_code_screen.dart # Generación de códigos QR
│   │   ├── qr_screen.dart    # Pantalla de QR
│   ├── locales/              # Pantallas de locales y menús
│   │   ├── locales_screen.dart # Pantalla de locales
│   │   ├── menu_screen.dart  # Pantalla del menú
│   │   ├── restaurant_card.dart # Componente para tarjetas de restaurantes
│   │   ├── promo_screen.dart # Pantalla de promociones
│   ├── points/               # Pantallas relacionadas con puntos
│   │   ├── points_screen.dart # Pantalla de puntos acumulados
│   ├── user/                 # Pantallas relacionadas con usuario
│   │   ├── login_screen.dart # Pantalla de inicio de sesión
│   │   ├── profile_screen.dart # Pantalla de perfil de usuario
│   ├── main/                 # Pantalla principal y mapa
│   │   ├── main_screen.dart  # Pantalla principal con navegación
│   │   ├── map_screen.dart   # Pantalla interactiva del mapa
│   ├── edit/                 # Pantallas de edición
│   │   ├── edit_prices_screen.dart # Pantalla para editar precios
├── database/                 # Clases y utilidades de ayuda
│   ├── database_helper.dart  # Ayudante para la base de datos
│   ├── db_helper.dart        # Gestión de la conexión a la base de datos
