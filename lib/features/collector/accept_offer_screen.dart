import 'package:flutter/material.dart';

import '../../models/lot_item.dart';

class AcceptOfferScreen extends StatelessWidget {
  const AcceptOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    final Map data = args is Map ? args : {};

    final String recyclerName = data['recyclerName']?.toString() ?? 'रीसाइक्लर';

    final double offerPrice = (data['offerPrice'] as num?)?.toDouble() ?? 0;

    final bool pickup = data['pickup'] == true;

    final List<LotItem> items = (data['items'] as List?)?.cast<LotItem>() ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('ऑफर की पुष्टि')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ऑफर स्वीकार करें',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'लेन-देन की जानकारी जाँचकर पुष्टि करें',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildOfferCard(recyclerName, offerPrice),

                    const SizedBox(height: 20),

                    _buildLotCard(items),

                    const SizedBox(height: 20),

                    _buildHandoverCard(pickup),

                    const SizedBox(height: 20),

                    _buildTrustCard(),
                  ],
                ),
              ),
            ),

            _buildBottomBar(context, recyclerName, offerPrice, items, pickup),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(String recyclerName, double offerPrice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB9DCC9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 25, child: Icon(Icons.recycling)),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recyclerName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'अधिकृत रीसाइक्लर',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text('आपको मिलेगा', style: TextStyle(fontSize: 14)),

          const SizedBox(height: 4),

          Text(
            '₹${offerPrice.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildLotCard(List<LotItem> items) {
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
            'लॉट में शामिल सामग्री',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 14),

          if (items.isEmpty)
            Text(
              'सामग्री की जानकारी उपलब्ध नहीं है',
              style: TextStyle(color: Colors.grey.shade700),
            ),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 19),
                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      '${item.material} · ${_formatQuantity(item.quantity)} ${item.unit}',
                    ),
                  ),

                  Text(
                    '₹${item.estimatedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandoverCard(bool pickup) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            pickup ? Icons.local_shipping_outlined : Icons.storefront_outlined,
            size: 30,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pickup
                      ? 'पिकअप द्वारा हस्तांतरण'
                      : 'रीसाइक्लिंग सुविधा पर ड्रॉप-ऑफ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  pickup
                      ? 'रीसाइक्लर आपकी सामग्री लेने आएगा'
                      : 'आप सामग्री रीसाइक्लिंग सुविधा पर जमा करेंगे',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_outlined),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'पुष्टि के बाद इस लॉट का एक डिजिटल रिकॉर्ड बनाया जाएगा, जिससे लेन-देन को ट्रैक किया जा सकेगा।',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    String recyclerName,
    double offerPrice,
    List<LotItem> items,
    bool pickup,
  ) {
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
                '/transaction-created',
                arguments: {
                  'recyclerName': recyclerName,
                  'offerPrice': offerPrice,
                  'items': items,
                  'pickup': pickup,
                },
              );
            },
            child: const Text('ऑफर स्वीकार करें'),
          ),
        ),
      ),
    );
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}
