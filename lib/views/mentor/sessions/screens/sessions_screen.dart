import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/session_viewmodel.dart';
import 'package:gyaanplant/views/mentor/sessions/widgets/session_history_card.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/common_widgets/mentor_bottom_nav.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> with SingleTickerProviderStateMixin {
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
    return name.split(" ").map((e) => e[0]).take(2).join();
  }

  String formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return "TBD";
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionViewModel()..loadSessions(),
      child: Scaffold(
        backgroundColor: const Color(0xFF020B08),
        body: Consumer<SessionViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00E676),
                ),
              );
            }

            // Start animations
            _animController.forward();

            final list = vm.completed;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Header Animated Fade-In
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E676).withOpacity(0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Session History",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sessions Content & Empty State
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
                                          Icons.chat_bubble_outline_rounded,
                                          color: Color(0xFF00E676),
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "No Session History Yet",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Completed mentor sessions will appear here.",
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
                                  final s = list[index];

                                  return Column(
                                    children: [
                                      SessionHistoryCard(
                                        initials: getInitials(s.name),
                                        name: s.name,
                                        date: formatDate(s.time),
                                        topic: s.topic,
                                        feedback: s.review,
                                        avatarColor: Colors.greenAccent,
                                        rating: s.rating,
                                        duration: "${s.duration} min",
                                      ),
                                      
                                      // Final margin space for bottom navigation
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
        bottomNavigationBar: const MentorBottomNav(currentIndex: 2),
      ),
    );
  }
}
