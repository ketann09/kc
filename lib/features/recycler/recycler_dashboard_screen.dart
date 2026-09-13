import 'package:flutter/material.dart';

import '../../models/transaction.dart';

class RecyclerDashboardScreen extends StatelessWidget {
  const RecyclerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    ScrapTransaction? transaction;

    if (args is ScrapTransaction) {
      transaction = args;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'नए लॉट अनुरोध',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: transaction == null
            ? _buildEmptyState()
            : _buildTransactionList(context, transaction),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    ScrapTransaction transaction,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Text(
          'आपके पास आने वाले कलेक्टर के लॉट',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 20),

        _LotCard(
          transaction: transaction,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/incoming-lot',
              arguments: transaction,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'अभी कोई नया लॉट नहीं है',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'नए लॉट अनुरोध यहाँ दिखाई देंगे।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  final ScrapTransaction transaction;
  final VoidCallback onTap;

  const _LotCard({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final materialNames = transaction.items
        .map((item) => item.material)
        .join(' · ');

    final weight = transaction.totalWeightGrams;

    final weightText = weight >= 1000
        ? '${(weight / 1000).toStringAsFixed(weight % 1000 == 0 ? 0 : 1)} किलो'
        : '${weight.toStringAsFixed(0)} ग्राम';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      materialNames,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₹${transaction.offerPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                '$weightText · कलेक्टर द्वारा भेजा गया',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Icon(
                    transaction.pickup
                        ? Icons.local_shipping_outlined
                        : Icons.storefront_outlined,
                    size: 18,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    transaction.pickup
                        ? 'पिकअप अनुरोध'
                        : 'ड्रॉप-ऑफ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}