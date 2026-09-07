import 'dart:io';

class ClassificationResult {
  final String material;
  final double confidence;

  const ClassificationResult({
    required this.material,
    required this.confidence,
  });
}

abstract class ClassificationService {
  Future<ClassificationResult> classify(File image);
}

/// Temporary implementation for the MVP.
/// This will be replaced by the actual ML model integration.
class MockClassificationService implements ClassificationService {
  @override
  Future<ClassificationResult> classify(File image) async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    return const ClassificationResult(
      material: 'पीसीबी',
      confidence: 0.94,
    );
  }
}