

import 'lot_item.dart';

class ScrapTransaction {
  final String lotId;
  final String recyclerName;
  final double offerPrice;
  final List<LotItem> items;
  final bool pickup;
  final DateTime createdAt;

  final String status;

  const ScrapTransaction({
    required this.lotId,
    required this.recyclerName,
    required this.offerPrice,
    required this.items,
    required this.pickup,
    required this.createdAt,
    required this.status,
  });

  ScrapTransaction copyWith({
    String? status,
  }) {
    return ScrapTransaction(
      lotId: lotId,
      recyclerName: recyclerName,
      offerPrice: offerPrice,
      items: items,
      pickup: pickup,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  double get totalWeightGrams {
    return items.fold(
      0,
      (sum, item) {
        if (item.unit == 'किलो') {
          return sum + item.quantity * 1000;
        }

        if (item.unit == 'ग्राम') {
          return sum + item.quantity;
        }

        return sum;
      },
    );
  }

  String get collectorName => 'कलेक्टर';

  @override
  String toString() {
    return 'ScrapTransaction('
        'lotId: $lotId, '
        'recycler: $recyclerName, '
        'price: $offerPrice, '
        'status: $status'
        ')';
  }
}