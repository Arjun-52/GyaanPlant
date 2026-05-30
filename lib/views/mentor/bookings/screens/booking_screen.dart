import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/booking_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/common_widgets/mentor_bottom_nav.dart';

import 'package:gyaanplant/views/mentor/bookings/widgets/booking_card.dart';
import 'package:gyaanplant/views/mentor/bookings/widgets/bookings_header.dart';
import 'package:gyaanplant/views/mentor/bookings/widgets/tab_selector.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
        backgroundColor: const Color(0xFF020B08),
        body: Consumer<BookingViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00E676),
                ),
              );
            }

            // Start entrance animations
            _animController.forward();

            final list = vm.currentBookings;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Header Fade-In
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        );
                      },
                      child: const BookingsHeader(),
                    ),
                    const SizedBox(height: 20),

                    // Tabs Animated Entry
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value * 0.5),
                            child: child,
                          ),
                        );
                      },
                      child: TabSelector(
                        selectedIndex: vm.selectedTab,
                        onTabChanged: (index) => vm.changeTab(index),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Booking Cards Slide-Up
                    Expanded(
                      child: list.isEmpty
                          ? AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: child,
                                );
                              },
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F3D34).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(0xFF00E676).withOpacity(0.1),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00E676).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month_outlined,
                                          color: Color(0xFF00E676),
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "No Bookings Available",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Bookings will appear here when students schedule sessions.",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _slideAnimation.value),
                                    child: child,
                                  ),
                                );
                              },
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  final b = list[index];

                                  return Column(
                                    children: [
                                      BookingCard(
                                        booking: b,
                                        initials: getInitials(b.name),
                                        avatarColor: Colors.green,
                                        onAccept: () async {
                                          final error = await vm.updateBookingStatus(b.id, "accepted");
                                          if (context.mounted) {
                                            if (error == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('✅ Booking accepted successfully!'),
                                                  backgroundColor: Color(0xFF00E676),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('❌ Failed: $error'),
                                                  backgroundColor: Colors.redAccent,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        onDecline: () async {
                                          final error = await vm.updateBookingStatus(b.id, "rejected");
                                          if (context.mounted) {
                                            if (error == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('✅ Booking declined successfully.'),
                                                  backgroundColor: Colors.orange,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('❌ Failed: $error'),
                                                  backgroundColor: Colors.redAccent,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                      
                                      // Add final margin before bottom nav
                                      if (index == list.length - 1)
                                        const SizedBox(height: 120)
                                      else
                                        const SizedBox(height: 6),
                                    ],
                                  );
                                },
                              ),
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
