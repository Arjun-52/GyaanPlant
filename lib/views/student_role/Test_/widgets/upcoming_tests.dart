import 'package:flutter/material.dart';
import 'test_pack_card.dart';
import 'package:gyaanplant/models/prep_pack_model.dart';

class UpcomingTests extends StatelessWidget {
  const UpcomingTests({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Test Packs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 14),

        TestPackCard(
          pack: PrepPack(
            id: '1',
            title: "TCS NQT Full Mock",
            description: "3 rounds · 90 min",
            price: 299.0,
          ),
        ),

        TestPackCard(
          pack: PrepPack(
            id: '2',
            title: "Infosys InfyTQ Prep",
            description: "Aptitude + Coding",
            price: 249.0,
          ),
        ),

        TestPackCard(
          pack: PrepPack(
            id: '3',
            title: "Wipro NLTH Pack",
            description: "4 sections · 120 min",
            price: 279.0,
          ),
        ),
      ],
    );
  }
}
// 21EC3D58