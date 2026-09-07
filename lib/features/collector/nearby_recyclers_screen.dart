import 'package:flutter/material.dart';

import '../../models/lot_item.dart';

class NearbyRecyclersScreen extends StatelessWidget {
  const NearbyRecyclersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    

    final Map data = args is Map ? args : {};

    final List<LotItem> items =
        (data['items'] as List?)?.cast<LotItem>() ?? [];

    final double totalPrice =
        (data['totalPrice'] as num?)?.toDouble() ?? 0;

    final double totalWeightGrams =
        (data['totalWeightGrams'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('पास के रीसाइक्लर'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'पास के रीसाइक्लर',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _subtitle(items, totalWeightGrams),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildLotSummary(
                      items,
                      totalPrice,
                      totalWeightGrams,
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'उपलब्ध विकल्प',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildRecyclerCard(
                      context: context,
                      name: 'ग्रीन रीसायकल',
                      distance: '1.2 किमी दूर',
                      price: _offerPrice(
                        totalPrice,
                        1.02,
                      ),
                      subtitle: 'अधिकृत सुविधा · पिकअप',
                      authorized: true,
                      pickup: true,
                      items: items,
                    ),

                    const SizedBox(height: 12),

                    _buildRecyclerCard(
                      context: context,
                      name: 'सिटी ई-वेस्ट',
                      distance: '3.4 किमी दूर',
                      price: _offerPrice(
                        totalPrice,
                        0.95,
                      ),
                      subtitle: 'अधिकृत सुविधा · ड्रॉप-ऑफ',
                      authorized: true,
                      pickup: false,
                      items: items,
                    ),

                    const SizedBox(height: 12),

                    _buildRecyclerCard(
                      context: context,
                      name: 'लोकल स्क्रैप',
                      distance: '0.8 किमी दूर',
                      price: null,
                      subtitle: 'अनधिकृत · सावधानी से चुनें',
                      authorized: false,
                      pickup: true,
                      items: items,
                    ),
                  ],
                ),
              ),
            ),

            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  String _subtitle(
    List<LotItem> items,
    double totalWeightGrams,
  ) {
    if (items.isEmpty) {
      return 'आपके लॉट के लिए विकल्प';
    }

    if (items.length == 1) {
      final item = items.first;

      return '${_formatQuantity(item.quantity)} ${item.unit} ${item.material} के लिए विकल्प';
    }

    return '${items.length} सामग्री वाले लॉट के लिए विकल्प';
  }

  Widget _buildLotSummary(
    List<LotItem> items,
    double totalPrice,
    double totalWeightGrams,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB9DCC9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'आपका लॉट',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₹${totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${item.material} · ${_formatQuantity(item.quantity)} ${item.unit}',
                    ),
                  ),
                  Text(
                    '₹${item.estimatedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (totalWeightGrams > 0) ...[
            const SizedBox(height: 5),
            Text(
              'कुल वजन: ${_formatWeight(totalWeightGrams)}',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecyclerCard({
    required BuildContext context,
    required String name,
    required String distance,
    required double? price,
    required String subtitle,
    required bool authorized,
    required bool pickup,
    required List<LotItem> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: authorized
                      ? const Color(0xFFEAF5EF)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.recycling,
                  color: authorized
                      ? const Color(0xFF176B45)
                      : Colors.grey.shade600,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              if (authorized)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'अधिकृत',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          if (price != null)
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'अनुमानित ऑफर',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

          if (price == null)
            Text(
              'कीमत की पुष्टि रीसाइक्लर से करें',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/accept-offer',
                  arguments: {
                    'recyclerName': name,
                    'offerPrice': price ?? 0,
                    'items': items,
                    'pickup': pickup,
                  },
                );
              },
              child: Text(
                pickup
                    ? 'पिकअप चुनें'
                    : 'ड्रॉप-ऑफ चुनें',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: const SafeArea(
        top: false,
        child: Text(
          'अधिकृत रीसाइक्लर को प्राथमिकता दें',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  double _offerPrice(
    double basePrice,
    double multiplier,
  ) {
    return basePrice * multiplier;
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
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