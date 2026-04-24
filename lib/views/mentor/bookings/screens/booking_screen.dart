import 'package:flutter/material.dart';
import 'package:gyaanplant/views/mentor/bookings/widgets/booking_card.dart';
import 'package:gyaanplant/views/mentor/bookings/widgets/bookings_header.dart';
import 'package:gyaanplant/views/mentor/bookings/widgets/tab_selector.dart';
import 'package:gyaanplant/core/common_widgets/mentor_bottom_nav.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A0A),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BookingsHeader(),
              const SizedBox(height: 16),

              const TabSelector(),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: const [
                    BookingCard(
                      initials: "PG",
                      name: "Pooja Gupta",
                      college: "MVSR · IT · 2025",
                      time: "Mar 15, 2:00 PM",
                      topic: "Aptitude + mock interview",
                      price: "₹299",
                      avatarColor: Colors.green,
                    ),

                    SizedBox(height: 14),

                    BookingCard(
                      initials: "KN",
                      name: "Karthik Nair",
                      college: "CBIT · CSE · 2026",
                      time: "Mar 16, 11:00 AM",
                      topic: "Career guidance session",
                      price: "₹199",
                      avatarColor: Colors.orange,
                    ),

                    SizedBox(height: 14),

                    BookingCard(
                      initials: "DS",
                      name: "Divya Sharma",
                      college: "GRIET · ECE · 2025",
                      time: "Mar 17, 4:00 PM",
                      topic: "Resume review",
                      price: "₹299",
                      avatarColor: Colors.pink,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const TpoBottomNav(currentIndex: 1),
    );
  }
}
