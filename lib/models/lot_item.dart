class LotItem {
  final String material;
  final String unit;
  final double quantity;
  final String quality;
  final double rate;
  final String? imagePath;
  final double confidence;

  const LotItem({
    required this.material,
    required this.unit,
    required this.quantity,
    required this.quality,
    required this.rate,
    this.imagePath,
    this.confidence = 0,
  });

  double get estimatedPrice {
    return quantity * rate;
  }
}