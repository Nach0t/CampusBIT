import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'qr_codes_screen.dart';
import 'ui/app_theme.dart';
import 'ui/widgets.dart';

class ProfileScreen extends StatelessWidget {
  final String username;

  const ProfileScreen({super.key, required this.username});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await confirmAction(
      context,
      title: 'Cerrar sesión',
      message: '¿Quieres salir de tu cuenta?',
      confirmLabel: 'Cerrar sesión',
    );
    if (!confirmed || !context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Elimina el historial
    );
  }

  void _comingSoon(BuildContext context, String feature) {
    // Antes decía "Navegando a..." sin navegar a ninguna parte.
    showAppMessage(context, '$feature estará disponible próximamente.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: AppBackground(
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.celesteOscuro,
                        child:
                            Icon(Icons.person, size: 56, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        username,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.texto,
                        ),
                      ),
                      const Text(
                        'Universidad San Sebastián',
                        style: TextStyle(color: AppColors.textoSecundario),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _ProfileOption(
                      icon: Icons.history,
                      title: 'Historial de Pedidos',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              QrCodesScreen(username: username),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    _ProfileOption(
                      icon: Icons.payment,
                      title: 'Métodos de Pago',
                      onTap: () => _comingSoon(context, 'Métodos de Pago'),
                    ),
                    const Divider(height: 1),
                    _ProfileOption(
                      icon: Icons.settings,
                      title: 'Configuraciones',
                      onTap: () => _comingSoon(context, 'Configuraciones'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                clipBehavior: Clip.antiAlias,
                child: _ProfileOption(
                  icon: Icons.logout,
                  title: 'Cerrar Sesión',
                  color: AppColors.error,
                  showChevron: false,
                  onTap: () => _logout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;
  final bool showChevron;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.celesteOscuro,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: color == AppColors.celesteOscuro ? AppColors.texto : color,
        ),
      ),
      trailing: showChevron
          ? const Icon(Icons.chevron_right, color: AppColors.textoSecundario)
          : null,
    );
  }
}
