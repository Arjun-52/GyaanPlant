// lib/views/HOD_role/naac/widgets/student_purchases_section.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/student_purchase_viewmodel.dart';
import 'package:gyaanplant/models/student_purchase_models.dart';

class StudentPurchasesSection extends StatelessWidget {
  final StudentPurchaseViewModel viewModel;
  const StudentPurchasesSection({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<StudentPurchaseViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const _ShimmerPlaceholders();
          }
          if (vm.error != null) {
            return Center(
              child: ElevatedButton(
                onPressed: vm.refresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
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
                    'Student Purchases Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _StatsCards(stats: vm.stats!),
              const SizedBox(height: 28),
              _TransactionsList(viewModel: vm),
            ],
          );
        },
      ),
    );
  }
}

class _StatsCards extends StatelessWidget {
  final StudentPurchaseStats stats;
  const _StatsCards({Key? key, required this.stats}) : super(key: key);

  Widget _card(String title, IconData icon, String value, String subtitle) {
    return Container(
      width: 165,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF061511).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00E676).withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(icon, color: const Color(0xFF00E676), size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _card('Active Learners', Icons.people_outline_rounded, '${stats.activeLearners}', 'Students with purchases'),
          _card('Gross Revenue', Icons.account_balance_wallet_outlined, '\u20B9${stats.grossRevenue.toStringAsFixed(0)}', 'Total revenue amount'),
          _card('Course Adoption', Icons.school_outlined, '${stats.courseAdoption}', 'Courses + prep packs'),
          _card('Mentorship', Icons.psychology_outlined, '${stats.mentorship}', 'Sessions completed'),
        ],
      ),
    );
  }
}

class _TransactionsList extends StatefulWidget {
  final StudentPurchaseViewModel viewModel;
  const _TransactionsList({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<_TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<_TransactionsList> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      'Institutional Transactions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Audit of student enrollment and payments',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF00E676).withOpacity(0.2),
                ),
              ),
              child: Text(
                '${vm.totalEntries} Purchases',
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: const Color(0xFF061511).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isSearchFocused
                        ? const Color(0xFF00E676).withOpacity(0.4)
                        : Colors.greenAccent.withOpacity(0.06),
                    width: 1.2,
                  ),
                  boxShadow: _isSearchFocused
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00E676).withOpacity(0.06),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                child: TextField(
                  focusNode: _searchFocusNode,
                  onChanged: (v) => vm.searchQuery = v,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search by Payment/Order ID',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: Colors.white38, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Premium Filter Button
            _FilterActionButton(onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        if (vm.filteredTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF061511).withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00E676).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFF00E676),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No transactions found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Adjust search filters to broaden query',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.filteredTransactions.length,
            itemBuilder: (_, idx) => _TransactionCard(transaction: vm.filteredTransactions[idx]),
          ),
      ],
    );
  }
}

class _FilterActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _FilterActionButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<_FilterActionButton> createState() => _FilterActionButtonState();
}

class _FilterActionButtonState extends State<_FilterActionButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF061511).withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF00E676).withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.08),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_list_rounded, color: Color(0xFF00E676), size: 18),
              SizedBox(width: 6),
              Text(
                'Filters',
                style: TextStyle(
                  color: Color(0xFF00E676),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final PaymentTransaction transaction;
  const _TransactionCard({Key? key, required this.transaction}) : super(key: key);

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
        return const Color(0xFF00E676);
      case 'pending':
        return const Color(0xFFFFB020);
      case 'failed':
        return const Color(0xFFFF5252);
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = transaction.status ?? 'Pending';
    final col = _statusColor(status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  transaction.studentName ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              // Beautiful glowing status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: col.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: col.withOpacity(0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: col.withOpacity(0.04),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: col,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.06), height: 1, thickness: 1),
          const SizedBox(height: 12),
          _buildDetailRow('Item', transaction.purchasedItem ?? '-'),
          const SizedBox(height: 6),
          _buildDetailRow('Amount', '\u20B9${transaction.amount?.toStringAsFixed(2) ?? '-'}', isValueBold: true),
          const SizedBox(height: 6),
          _buildDetailRow('Payment Method', transaction.paymentMethod ?? '-'),
          const SizedBox(height: 6),
          _buildDetailRow('Transaction Date', transaction.paymentDate ?? '-'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String val, {bool isValueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: isValueBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ShimmerPlaceholders extends StatelessWidget {
  const _ShimmerPlaceholders({Key? key}) : super(key: key);

  Widget _shimmerBox({double height = 20, double width = double.infinity}) {
    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF061511).withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.04),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // stats placeholders
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (_, i) => Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              child: _shimmerBox(height: 120),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // transaction list placeholder
        _shimmerBox(height: 40),
        _shimmerBox(height: 80),
        _shimmerBox(height: 80),
      ],
    );
  }
}
