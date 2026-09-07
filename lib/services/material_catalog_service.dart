class MaterialInfo {
  final String name;
  final String unit;
  final double rate;

  const MaterialInfo({
    required this.name,
    required this.unit,
    required this.rate,
  });
}

abstract class MaterialCatalogService {
  MaterialInfo getMaterial(String material);
}

class LocalMaterialCatalogService implements MaterialCatalogService {
  static const Map<String, MaterialInfo> _materials = {
    'पीसीबी': MaterialInfo(
      name: 'पीसीबी',
      unit: 'ग्राम',
      rate: 0.21,
    ),
    'बैटरी': MaterialInfo(
      name: 'बैटरी',
      unit: 'किलो',
      rate: 85,
    ),
    'केबल': MaterialInfo(
      name: 'केबल',
      unit: 'ग्राम',
      rate: 0.14,
    ),
    'सीआरटी पैनल': MaterialInfo(
      name: 'सीआरटी पैनल',
      unit: 'पीस',
      rate: 35,
    ),
    'एलसीडी पैनल': MaterialInfo(
      name: 'एलसीडी पैनल',
      unit: 'पीस',
      rate: 120,
    ),
  };

  @override
  MaterialInfo getMaterial(String material) {
    return _materials[material] ??
        const MaterialInfo(
          name: 'अन्य',
          unit: 'पीस',
          rate: 0,
        );
  }
}