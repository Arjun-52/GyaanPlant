import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/settings_item_model.dart';
import 'package:gyaanplant/views/tpo_role/settings/screens/security_screen.dart';

class SettingsTile extends StatelessWidget {
  final SettingsItem item;
  final VoidCallback? onTap;

  const SettingsTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            // Default navigation for Security & Privacy
            if (item.title == 'Security & Privacy') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecurityScreen()),
              );
            }
          },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF0C2A22), Color(0xFF071E17)],
          ),
          border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 22)),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
