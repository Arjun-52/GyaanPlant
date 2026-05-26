import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';

class HeaderCard extends StatelessWidget {
  final Department dept;
  const HeaderCard({Key? key, required this.dept}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3D34), Color(0xFF021B15)],
        ),
        // subtle glass‑morphism overlay
        color: Colors.white.withOpacity(0.05),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dept.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              if (dept.code != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dept.code!.toUpperCase(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.location_city, color: Colors.white70, size: 16),
              SizedBox(width: 4),
            ],
          ),
          Text(dept.college?.city ?? "", style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Row(
            children: const [
              Icon(Icons.account_balance, color: Colors.white70, size: 16),
              SizedBox(width: 4),
            ],
          ),
          Text(dept.college?.name ?? "", style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('HEAD OF DEPARTMENT', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: () {
                  // TODO: implement edit action
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(dept.head?.name ?? 'Unassigned', style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
