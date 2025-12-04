import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final purpleColor = const Color(0xFF3605EB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: purpleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Configuraciones',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Sección: Autenticación
            Text(
              'Autenticación',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // Card de Autenticación
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.lock_outline,
                    title: 'Cambiar contraseña',
                    onTap: () => _showSimulationMessage(context, 'Cambiar contraseña'),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildSettingItem(
                    icon: Icons.shield_outlined,
                    title: 'Autenticación de factores',
                    onTap: () => _showSimulationMessage(context, 'Autenticación de factores'),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: 'Preguntas de seguridad',
                    onTap: () => _showSimulationMessage(context, 'Preguntas de seguridad'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Sección: Aplicación
            Text(
              'Aplicación',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // Card de Aplicación
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.tune,
                    title: 'Interfaz',
                    onTap: () => _showSimulationMessage(context, 'Interfaz'),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    onTap: () => _showSimulationMessage(context, 'Notificaciones'),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildSettingItem(
                    icon: Icons.settings_outlined,
                    title: 'Avanzado',
                    onTap: () => _showSimulationMessage(context, 'Avanzado'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final purpleColor = const Color(0xFF3605EB);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: purpleColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showSimulationMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature (simulación)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

