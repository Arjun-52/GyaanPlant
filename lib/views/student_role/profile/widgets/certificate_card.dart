import 'package:flutter/material.dart';

class CertificateCard extends StatelessWidget {
  const CertificateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1F19), Color(0xFF0D2F24)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF12352C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///  TOP ROW
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart, color: Colors.white),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Data Structures & Algorithms",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "GyaanPlant Industry Certification · Apr 2025",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ///  VERIFIED ROW
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2A22),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFF1E4D3D)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// LEFT SIDE
                Row(
                  children: const [
                    Icon(Icons.check_box, size: 16, color: Color(0xFF00C853)),
                    SizedBox(width: 6),
                    Text(
                      "Blockchain Verified",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),

                /// RIGHT SIDE
                const Text(
                  "GP-2025-04782",
                  style: TextStyle(
                    color: Color(0xFF00C853),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// BUTTONS
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1DA1F2), Color(0xFF0A66C2)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Share LinkedIn",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2A22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E4D3D)),
                  ),
                  child: const Center(
                    child: Text(
                      "Download PDF",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
