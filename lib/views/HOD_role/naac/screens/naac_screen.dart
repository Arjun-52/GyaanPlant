import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/naac_view_model.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/student_purchase_viewmodel.dart';
import 'package:gyaanplant/views/HOD_role/naac/widgets/student_purchases_section.dart';
import 'package:provider/provider.dart';

class NaacScreen extends StatefulWidget {
  const NaacScreen({super.key});

  @override
  State<NaacScreen> createState() => _NaacScreenState();
}

class _NaacScreenState extends State<NaacScreen> {
  late final NaacViewModel _vm;
  late final StudentPurchaseViewModel _studentVm;

  @override
  void initState() {
    super.initState();
    _vm = NaacViewModel();
    _studentVm = StudentPurchaseViewModel();

    // Wrap API call in addPostFrameCallback to prevent setState during build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _vm.fetchNaac();
        _studentVm.fetchAll();
      }
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    _studentVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<NaacViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF020B08), // Deep premium black
            body: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00E676),
                    ),
                  )
                : vm.naac == null
                    ? const Center(
                        child: Text(
                          'Failed to load NAAC data',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : Stack(
                        children: [
                          // ── Ambient Background Glows ─────────────────────────────────
                          Positioned(
                            top: -100,
                            right: -50,
                            child: Container(
                              width: 260,
                              height: 260,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E676).withOpacity(0.06),
                                    blurRadius: 90,
                                    spreadRadius: 25,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 100,
                            left: -80,
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E676).withOpacity(0.04),
                                    blurRadius: 100,
                                    spreadRadius: 30,
                                  )
                                ],
                              ),
                            ),
                          ),

                          // ── Main Scrollable Layout ────────────────────────────────────
                          SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'NAAC Accreditation',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF00E676),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Institutional Standards & Quality Assurance',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Accreditation Summary Hero Card
                                _buildSummaryCard(vm),
                                const SizedBox(height: 24),

                                // Subsection Title
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00E676),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Accreditation Criteria Breakdown',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Criteria List
                                ...List.generate(vm.naac!.criteria.length, (i) {
                                  final item = vm.naac!.criteria[i];
                                  return Column(
                                    children: [
                                      _buildCriteriaCard(item, i + 1),
                                      if (item.title == 'Governance')
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: StudentPurchasesSection(viewModel: _studentVm),
                                        ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(NaacViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF061511).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.03),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Large Premium Accreditation Badge
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF09291D), Color(0xFF02130E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: const Color(0xFF00E676).withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.12),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          vm.naac!.grade,
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'GRADE',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Institutional Status',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'NAAC Accredited',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.white38,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Valid until ${vm.naac!.validTill}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Premium Scale Action Button
              _AnimatedCTAButton(
                onTap: vm.isGeneratingReport
                    ? null
                    : () => vm.generateNaacReport(context),
                isLoading: vm.isGeneratingReport,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCriteriaCard(dynamic item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF061511).withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.06),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF00E676).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  'Criterion $index',
                  style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '${item.score}/4',
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AnimatedProgressBar(value: item.score / 4),
        ],
      ),
    );
  }
}

class _AnimatedCTAButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const _AnimatedCTAButton({
    required this.onTap,
    required this.isLoading,
  });

  @override
  State<_AnimatedCTAButton> createState() => _AnimatedCTAButtonState();
}

class _AnimatedCTAButtonState extends State<_AnimatedCTAButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00E676), Color(0xFF00C853)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Generate Full NAAC Report',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF031B15),
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF031B15),
                      size: 16,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  final double value;

  const _AnimatedProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, val, _) {
          return FractionalTranslation(
            translation: Offset(val - 1.0, 0.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00C853)],
                ),
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
          );
        },
      ),
    );
  }
}
