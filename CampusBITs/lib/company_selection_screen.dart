import 'package:flutter/material.dart';

import 'main_screen.dart';
import 'ui/app_theme.dart';
import 'ui/widgets.dart';

class CompanySelectionScreen extends StatelessWidget {
  final String username;

  const CompanySelectionScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Empresa')),
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ContentWidth(
              maxWidth: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bienvenido, $username',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texto,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona la empresa a la que deseas acceder:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.texto),
                  ),
                  const SizedBox(height: 24),
                  _CompanyCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(username: username),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/uss_logo.png',
                      height: 140,
                      fit: BoxFit.contain,
                      semanticLabel: 'Universidad San Sebastián',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CompanyCard(
                    onTap: () => showAppMessage(
                      context,
                      'Otra empresa no disponible actualmente',
                      type: MessageType.error,
                    ),
                    // `const Column` no compila en Flutter 3.50 (assert de
                    // CrossAxisAlignment); los hijos sí son const.
                    // ignore: prefer_const_constructors
                    child: Column(
                      children: const [
                        Icon(Icons.business, size: 72, color: AppColors.petroleo),
                        SizedBox(height: 8),
                        Text(
                          'OTRO',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.petroleo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _CompanyCard({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: child),
        ),
      ),
    );
  }
}
