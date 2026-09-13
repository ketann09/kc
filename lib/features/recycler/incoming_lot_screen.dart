import 'package:flutter/material.dart';

import '../../models/transaction.dart';

class IncomingLotScreen extends StatelessWidget {
  const IncomingLotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! ScrapTransaction) {
      return const Scaffold(
        body: Center(
          child: Text('लॉट की जानकारी उपलब्ध नहीं है'),
        ),
      );
    }

    final transaction = args;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'लॉट विवरण',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _StatusBanner(),

                  const SizedBox(height: 20),

                  const Text(
                    'लॉट की सामग्री',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...transaction.items.map(
                    (item) => _MaterialCard(item: item),
                  ),

                  const SizedBox(height: 20),

                  _SummaryCard(transaction: transaction),

                  const SizedBox(height: 20),

                  _InfoCard(
                    icon: Icons.person_outline,
                    title: 'कलेक्टर',
                    value: transaction.collectorName,
                  ),

                  const SizedBox(height: 12),

                  _InfoCard(
                    icon: transaction.pickup
                        ? Icons.local_shipping_outlined
                        : Icons.storefront_outlined,
                    title: 'हैंडओवर',
                    value: transaction.pickup
                        ? 'पिकअप द्वारा'
                        : 'रीसाइक्लर केंद्र पर ड्रॉप-ऑफ',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/verify-weight',
                      arguments: transaction,
                    );
                  },
                  child: const Text(
                    'लॉट स्वीकार करें',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_outlined,
            color: primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'कलेक्टर ने यह लॉट आपके ऑफर के लिए भेजा है',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final dynamic item;

  const _MaterialCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final quantity = item.quantity as double;

    String quantityText;

    if (item.unit == 'ग्राम') {
      quantityText = '${quantity.toStringAsFixed(0)} ग्राम';
    } else if (item.unit == 'किलो') {
      quantityText = '${quantity.toStringAsFixed(0)} किलो';
    } else {
      quantityText = '${quantity.toStringAsFixed(0)} ${item.unit}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.recycling_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.material,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantityText · ${item.quality}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₹${item.estimatedPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ScrapTransaction transaction;

  const _SummaryCard({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'कुल वजन',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
              Text(
                _formatWeight(transaction.totalWeightGrams),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Divider(color: Colors.grey.shade200),

          const SizedBox(height: 14),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'स्वीकृत कीमत',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '₹${transaction.offerPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatWeight(double grams) {
    if (grams >= 1000) {
      final kg = grams / 1000;
      return '${kg.toStringAsFixed(kg % 1 == 0 ? 0 : 1)} किलो';
    }

    return '${grams.toStringAsFixed(0)} ग्राम';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}