import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/naac_view_model.dart';
import 'package:provider/provider.dart';

class NaacScreen extends StatefulWidget {
  const NaacScreen({super.key});

  @override
  State<NaacScreen> createState() => _NaacScreenState();
}

class _NaacScreenState extends State<NaacScreen> {
  late final NaacViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = NaacViewModel();
    _vm.fetchNaac();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<NaacViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF061A14),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.naac == null
                    ? const Center(
                        child: Text('Failed to load NAAC data',
                            style: TextStyle(color: Colors.white54)))
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView(
                          children: [
                            const Text(
                              'NAAC Accreditation',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 29,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F3D34),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.green.withAlpha(80)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('🏆',
                                          style: TextStyle(fontSize: 28)),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('${vm.naac!.grade} Grade',
                                              style: const TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                          Text(
                                              'Valid until ${vm.naac!.validTill}',
                                              style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Generate Full NAAC Report →',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(vm.naac!.criteria.length, (i) {
                              final item = vm.naac!.criteria[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F3D34),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Criterion ${i + 1}',
                                            style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(item.title,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w900)),
                                        ),
                                        Text('${item.score}/4',
                                            style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: item.score / 4,
                                      backgroundColor: Colors.white12,
                                      valueColor:
                                          const AlwaysStoppedAnimation(
                                              Colors.green),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }
}
