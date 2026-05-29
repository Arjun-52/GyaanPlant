import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/drives_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/Drives/widgets/drive_card.dart';
import 'create_drive_screen.dart';

class DrivesScreen extends StatefulWidget {
  const DrivesScreen({super.key});

  @override
  State<DrivesScreen> createState() => _DrivesScreenState();
}

class _DrivesScreenState extends State<DrivesScreen> {
  @override
  void initState() {
    super.initState();
    print('🎯 DrivesScreen.initState() called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🔔 Calling DrivesViewModel.fetchDrives() from initState');
        context.read<DrivesViewModel>().fetchDrives();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DrivesViewModel>();
    print(
      '📱 DrivesScreen.build() - isLoading: ${vm.isLoading}, drives: ${vm.drives.length}',
    );

    final activeDrives = vm.drives
        .where((d) =>
            d.status.toLowerCase() == 'open' ||
            d.status.toLowerCase() == 'active')
        .length;
    final upcomingDrives = vm.drives
        .where((d) => d.status.toLowerCase() == 'upcoming')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: RefreshIndicator(
        onRefresh: () {
          print('🔄 Refresh triggered for drives');
          return vm.refreshDrives();
        },
        color: const Color(0xFF00FFAA),
        backgroundColor: const Color(0xFF0A2E1A),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Hero Header ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOut,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -20 * (1 - value)),
                    child: child,
                  ),
                ),
                child: _buildHeroHeader(activeDrives, upcomingDrives),
              ),
            ),

            // ── Create Drive CTA ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.88, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) => Transform.scale(
                  scale: scale,
                  child: child,
                ),
                child: _buildCreateDriveButton(context),
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────────
            if (vm.isLoading)
              const SliverFillRemaining(child: _LoadingState())
            else if (vm.error != null)
              SliverFillRemaining(child: _ErrorState(error: vm.error!))
            else if (vm.drives.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => TweenAnimationBuilder<double>(
                      key: ValueKey(i),
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + i * 60),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DriveCard(drive: vm.drives[i]),
                      ),
                    ),
                    childCount: vm.drives.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Hero Header ─────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(int active, int upcoming) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 56, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2E1C), Color(0xFF061A10)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00FFAA).withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFAA).withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFAA).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00FFAA).withOpacity(0.3),
                  ),
                ),
                child: const Text('💼', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Placement Drives',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Manage recruitment drives & track placements.',
                      style: TextStyle(color: Color(0xFF6B8F76), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _heroStat('🟢', '$active', 'Active'),
              const SizedBox(width: 12),
              _heroStat('🕒', '$upcoming', 'Upcoming'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF00FFAA).withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF00FFAA).withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF00FFAA),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B8F76),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Create Drive Button ─────────────────────────────────────────────────────
  Widget _buildCreateDriveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateDriveScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00FFAA), Color(0xFF00C853)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFAA).withOpacity(0.35),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🚀', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Text(
                'Create New Drive',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00FFAA),
          strokeWidth: 2,
        ),
      );
}

// ── Error ─────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Color(0xFF8A9E94), fontSize: 14),
              ),
            ],
          ),
        ),
      );
}

// ── Empty ─────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D2E1C), Color(0xFF061A10)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF00FFAA).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFAA).withOpacity(0.06),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFAA).withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00FFAA).withOpacity(0.2),
                    ),
                  ),
                  child: const Text('🚀',
                      style: TextStyle(fontSize: 40)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Placement Drives Yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Create your first placement drive to start recruiting students.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B8F76),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
