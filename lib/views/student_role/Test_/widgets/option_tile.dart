import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final parts = label.split("  ");

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0D2F24), Color(0xFF0A241D)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF0F2A22),
          borderRadius: BorderRadius.circular(16),

          //  BORDER FIX
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00C853)
                : const Color(0xFF1E4D3D),
            width: isSelected ? 1.5 : 1,
          ),
        ),

        child: Row(
          children: [
            //  OPTION LETTER BOX
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00C853)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00C853)
                      : const Color(0xFF1E4D3D),
                ),
              ),
              child: Text(
                parts[0], // A, B, C, D
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // 🔹 OPTION TEXT
            Text(
              parts.length > 1 ? parts[1] : "",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
