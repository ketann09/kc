import 'package:flutter/material.dart';

import '../../models/lot_item.dart';
import '../../models/transaction.dart';

class TransactionCreatedScreen extends StatelessWidget {
  const TransactionCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    final Map data = args is Map ? args : {};

    final String recyclerName = data['recyclerName']?.toString() ?? 'रीसाइक्लर';

    final double offerPrice = (data['offerPrice'] as num?)?.toDouble() ?? 0;

    final bool pickup = data['pickup'] == true;

    final List<LotItem> items = (data['items'] as List?)?.cast<LotItem>() ?? [];

    final transaction = ScrapTransaction(
      lotId: _generateLotId(),
      recyclerName: recyclerName,
      offerPrice: offerPrice,
      items: items,
      pickup: pickup,
      createdAt: DateTime.now(),
      status: 'स्वीकृत',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('लेन-देन'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                child: Column(
                  children: [
                    _buildSuccessIcon(),

                    const SizedBox(height: 20),

                    const Text(
                      'ऑफर स्वीकार हो गया!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      pickup
                          ? 'रीसाइक्लर आपकी सामग्री लेने आएगा'
                          : 'सामग्री रीसाइक्लिंग सुविधा पर जमा करें',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildLotIdCard(transaction),

                    const SizedBox(height: 16),

                    _buildSummaryCard(transaction),

                    const SizedBox(height: 16),

                    _buildStatusCard(pickup),
                  ],
                ),
              ),
            ),

            _buildBottomBar(context, transaction),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 76,
      height: 76,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEAF5EF),
      ),
      child: const Icon(Icons.check_circle_outline, size: 48),
    );
  }

  Widget _buildLotIdCard(ScrapTransaction transaction) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB9DCC9)),
      ),
      child: Column(
        children: [
          const Text('लॉट आईडी', style: TextStyle(fontSize: 13)),

          const SizedBox(height: 6),

          Text(
            transaction.lotId,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'इस आईडी से आप अपने लॉट को ट्रैक कर सकते हैं',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ScrapTransaction transaction) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'लेन-देन सारांश',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 16),

          _summaryRow('रीसाइक्लर', transaction.recyclerName),

          const SizedBox(height: 10),

          _summaryRow('सामग्री', '${transaction.items.length} प्रकार'),

          const SizedBox(height: 10),

          _summaryRow('कुल वजन', _formatWeight(transaction.totalWeightGrams)),

          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'स्वीकृत कीमत',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                '₹${transaction.offerPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(bool pickup) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pickup ? 'हस्तांतरण रीसाइक्लर के पिकअप पर पूरा होगा।' : 'हस्तांतरण सुविधा पर सामग्री सत्यापित होने के बाद पूरा होगा।',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ScrapTransaction transaction) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.08)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/recycler-dashboard',
                arguments: transaction,
              );
            },
            child: const Text('रीसाइक्लर की ओर देखें'),
          ),
        ),
      ),
    );
  }

  String _generateLotId() {
    final now = DateTime.now();

    return 'KC-${now.year.toString().substring(2)}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  String _formatWeight(double grams) {
    if (grams >= 1000) {
      final kg = grams / 1000;

      if (kg == kg.roundToDouble()) {
        return '${kg.toInt()} किलो';
      }

      return '${kg.toStringAsFixed(1)} किलो';
    }

    return '${grams.toStringAsFixed(0)} ग्राम';
  }
}
