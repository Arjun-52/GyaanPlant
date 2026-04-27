import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/booking_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/common_widgets/mentor_bottom_nav.dart';

import 'package:gyaanplant/views/mentor/bookings/widgets/booking_card.dart';
import 'package:gyaanplant/views/mentor/bookings/widgets/bookings_header.dart';
import 'package:gyaanplant/views/mentor/bookings/widgets/tab_selector.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'S';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingViewModel()..loadBookings(),
      child: Scaffold(
        backgroundColor: const Color(0xFF050A0A),

        body: Consumer<BookingViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = vm.pending;

            return SafeArea(
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
                      child: list.isEmpty
                          ? const Center(
                              child: Text(
                                "No bookings yet",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final b = list[index];

                                return Column(
                                  children: [
                                    BookingCard(
                                      initials: getInitials(b.name),
                                      name: b.name,
                                      college: b.college,
                                      time: b.time,
                                      topic: b.topic,
                                      price: "₹${b.price}",
                                      avatarColor: Colors.green,
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        bottomNavigationBar: const MentorBottomNav(currentIndex: 1),
      ),
    );
  }
}
