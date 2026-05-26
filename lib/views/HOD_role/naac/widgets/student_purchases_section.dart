// lib/views/HOD_role/naac/widgets/student_purchases_section.dart
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
                child: const Text('Retry'),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text('Student Purchases', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _StatsCards(stats: vm.stats!),
              const SizedBox(height: 24),
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
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F3D34), Color(0xFF021B15)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _card('Active Learners', Icons.people, '${stats.activeLearners}', 'students with purchases'),
          _card('Gross Revenue', Icons.attach_money, '\u20B9${stats.grossRevenue.toStringAsFixed(2)}', 'total amount'),
          _card('Course Adoption', Icons.school, '${stats.courseAdoption}', 'courses + prep packs'),
          _card('Mentorship', Icons.people_outline, '${stats.mentorship}', 'sessions'),
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
  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('INSTITUTIONAL TRANSACTIONS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Audit of student enrollment and payments', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (v) => vm.searchQuery = v,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by Payment/Order ID',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {}, // placeholder for filters
              child: const Text('Filters'),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade100.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${vm.totalEntries} Purchases', style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (vm.filteredTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3D34).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.greenAccent,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No transactions found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Adjust filters to broaden search',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
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

class _TransactionCard extends StatelessWidget {
  final PaymentTransaction transaction;
  const _TransactionCard({Key? key, required this.transaction}) : super(key: key);

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F3D34), Color(0xFF021B15)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(transaction.studentName ?? '-', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Item: ${transaction.purchasedItem ?? '-'}', style: const TextStyle(color: Colors.white70)),
          Text('Amount: \u20B9${transaction.amount?.toStringAsFixed(2) ?? '-'}', style: const TextStyle(color: Colors.white70)),
          Text('Method: ${transaction.paymentMethod ?? '-'}', style: const TextStyle(color: Colors.white70)),
          Text('Date: ${transaction.paymentDate ?? '-'}', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text('Status: ${transaction.status ?? '-'}', style: TextStyle(color: _statusColor(transaction.status), fontWeight: FontWeight.bold)),
        ],
      ),
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
      color: Colors.white30,
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
            itemBuilder: (_, i) => Container(width: 150, margin: const EdgeInsets.only(right: 12), child: _shimmerBox(height: 120)),
          ),
        ),
        const SizedBox(height: 24),
        // transaction list placeholder
        _shimmerBox(height: 20),
        _shimmerBox(height: 20),
        _shimmerBox(height: 20),
      ],
    );
  }
}
