import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/assessment/mock_test_models.dart';
import '../../../../viewmodels/student_viewmodel/prep_pack_details_viewmodel.dart';
import '../../../../viewmodels/student_viewmodel/prep_pack_state.dart';
import '../../../../viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'question_screen.dart';

class PrepPackDetailsScreen extends StatelessWidget {
  final String packId;

  const PrepPackDetailsScreen({super.key, required this.packId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrepPackDetailsViewModel>(
      create: (_) => PrepPackDetailsViewModel(packId: packId)..loadDetails(),
      child: const _PrepPackDetailsScreenContent(),
    );
  }
}

class _PrepPackDetailsScreenContent extends StatelessWidget {
  const _PrepPackDetailsScreenContent();

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF00E676);
      case 'medium':
        return Colors.orangeAccent;
      case 'hard':
        return Colors.redAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PrepPackDetailsViewModel>(context);
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B08),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Preparation Pack Details",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
            onPressed: () => viewModel.loadDetails(),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.05),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        child: _buildBodyForState(context, viewModel, state),
      ),
    );
  }

  Widget _buildBodyForState(
    BuildContext context,
    PrepPackDetailsViewModel viewModel,
    PrepPackState state,
  ) {
    switch (state) {
      case PreparationLoading():
        return _buildShimmerLoading();
      case PreparationError(message: final msg):
        return _buildErrorState(viewModel, msg);
      case PreparationLocked(previewPack: final pack):
        return _buildLockedScreen(context, viewModel, pack, isPurchasing: false);
      case PreparationPurchaseLoading(previewPack: final pack):
        return _buildLockedScreen(context, viewModel, pack, isPurchasing: true);
      case PreparationUnlocked(fullPack: final pack):
        return _buildUnlockedScreen(context, pack);
    }
    return const SizedBox.shrink();
  }

  // ── LOCKED VIEW ─────────────────────────────────────────────────────────

  Widget _buildLockedScreen(
    BuildContext context,
    PrepPackDetailsViewModel viewModel,
    PrepPackDetailsModel pack, {
    required bool isPurchasing,
  }) {
    final user = context.read<AuthViewModel>().user;

    return SingleChildScrollView(
      key: const ValueKey('LockedStateView'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Locked Icon Accents
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0x1F00C853),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Color(0xFF00C853),
                size: 64,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Pack Title
          Text(
            pack.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Chips Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(pack.difficulty).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getDifficultyColor(pack.difficulty).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  pack.difficulty.toUpperCase(),
                  style: TextStyle(
                    color: _getDifficultyColor(pack.difficulty),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (pack.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "PREMIUM",
                    style: TextStyle(
                      color: Color(0xFF020B08),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Description
          if (pack.description.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2A22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                pack.description,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Subtext info
          const Text(
            "Unlock this pack to access all questions and assessments",
            style: TextStyle(
              color: Colors.white30,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Pricing Summary Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2A22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00C853).withOpacity(0.2), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SPECIAL INTRO PRICE",
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "₹${pack.discountedPrice}",
                          style: const TextStyle(
                            color: Color(0xFF00C853),
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "₹${pack.price}",
                          style: const TextStyle(
                            color: Colors.white24,
                            fontSize: 15,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${pack.discountPercentage}% OFF",
                    style: const TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Large CTA "Unlock Pack"
          ElevatedButton(
            onPressed: isPurchasing
                ? null
                : () {
                    viewModel.unlockPack(
                      user: user,
                      showSuccess: (msg) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: const Color(0xFF00C853),
                          ),
                        );
                      },
                      showError: (msg) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      },
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: const Color(0xFF020B08),
              disabledBackgroundColor: const Color(0xFF00C853).withOpacity(0.4),
              disabledForegroundColor: const Color(0xFF020B08).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
            ),
            child: isPurchasing
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF020B08)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Processing payment...",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : const Text(
                    "Unlock Pack",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── UNLOCKED VIEW ───────────────────────────────────────────────────────

  Widget _buildUnlockedScreen(BuildContext context, PrepPackDetailsModel pack) {
    final targetTags = [
      ...pack.targetCompanies,
      ...pack.targetRoles,
      ...pack.industries,
    ];

    return SingleChildScrollView(
      key: const ValueKey('UnlockedStateView'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C853), Color(0xFF00E676)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F00C853),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFF020B08),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Difficulty Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(pack.difficulty).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getDifficultyColor(pack.difficulty).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            pack.difficulty.toUpperCase(),
                            style: TextStyle(
                              color: _getDifficultyColor(pack.difficulty),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Target Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pack.targetType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (pack.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "PREMIUM",
                              style: TextStyle(
                                color: Color(0xFF020B08),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pack.description.isNotEmpty) ...[
            Text(
              pack.description,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
          ],
          // Unlocked Success Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x1F00C853),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF00C853), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "PREMIUM PACK UNLOCKED",
                        style: TextStyle(
                          color: Color(0xFF00C853),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "You have full unlimited practice access.",
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats Metrics Card
          const Text(
            "PACK METRICS",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2A22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildMetricTile("Questions", "${pack.totalQuestions}", Icons.quiz_outlined)),
                    Container(width: 1, height: 40, color: Colors.white10),
                    Expanded(child: _buildMetricTile("Duration", "${pack.totalDurationMins} mins", Icons.timer_outlined)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                Row(
                  children: [
                    Expanded(child: _buildMetricTile("Attempts", "${pack.attempts}", Icons.history)),
                    Container(width: 1, height: 40, color: Colors.white10),
                    Expanded(child: _buildMetricTile("Passing Score", "${pack.passingScore.toInt()}%", Icons.check_circle_outline)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Scoring Grid
          const Text(
            "SCORING SYSTEM",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2A22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMarkingRule("Correct", "+${pack.markingScheme.correct.toInt()}", const Color(0xFF00E676)),
                Container(width: 1, height: 30, color: Colors.white10),
                _buildMarkingRule("Wrong", "-${pack.markingScheme.wrong.toInt()}", Colors.orangeAccent),
                Container(width: 1, height: 30, color: Colors.white10),
                _buildMarkingRule("Negative", "-${pack.markingScheme.negative.toInt()}", Colors.redAccent),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Target Tags
          if (targetTags.isNotEmpty) ...[
            const Text(
              "TARGET SECTORS & COMPANIES",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: targetTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2A22),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          // Sections List
          const Text(
            "ASSESSMENT DECK SECTIONS",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          if (pack.sections.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pack.sections.length,
              itemBuilder: (context, index) {
                final sec = pack.sections[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2A22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0x1F00C853),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: Color(0xFF00C853),
                          size: 22,
                        ),
                      ),
                      title: Text(
                        sec.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "${sec.questionsCount} Questions  •  ${sec.duration} Mins",
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestionScreen(
                              sectionTitle: sec.title,
                              questions: sec.questions,
                              markingScheme: pack.markingScheme,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── SHIMMER & HELPER WIDGETS ────────────────────────────────────────────

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      key: const ValueKey('ShimmerLoadingView'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F2A22),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 20, color: const Color(0xFF0F2A22)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(width: 60, height: 16, color: const Color(0xFF0F2A22)),
                        const SizedBox(width: 8),
                        Container(width: 60, height: 16, color: const Color(0xFF0F2A22)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF0F2A22),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF0F2A22),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.white30),
          SizedBox(height: 12),
          Text(
            "No assessments inside this pack.",
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PrepPackDetailsViewModel viewModel, String error) {
    return Center(
      key: const ValueKey('ErrorStateView'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              "Unable to load details",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.loadDetails(),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: const Color(0xFF020B08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00C853), size: 20),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarkingRule(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
