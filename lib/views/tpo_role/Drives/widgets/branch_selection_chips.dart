import 'package:flutter/material.dart';

class BranchSelectionChips extends StatelessWidget {
  final List<String> availableBranches;
  final Set<String> selectedBranches;
  final Function(String) onToggleBranch;

  const BranchSelectionChips({
    super.key,
    required this.availableBranches,
    required this.selectedBranches,
    required this.onToggleBranch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Eligible Branches',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableBranches.map((branch) {
            final isSelected = selectedBranches.contains(branch);
            return GestureDetector(
              onTap: () => onToggleBranch(branch),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00C853)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00C853)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  branch,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
