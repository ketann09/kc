import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/lot_item.dart';
import '../../services/classification_service.dart';
import '../../services/material_catalog_service.dart';

class NewScrapLotScreen extends StatefulWidget {
  const NewScrapLotScreen({super.key});

  @override
  State<NewScrapLotScreen> createState() => _NewScrapLotScreenState();
}

class _NewScrapLotScreenState extends State<NewScrapLotScreen> {
  final ImagePicker _picker = ImagePicker();
  final ClassificationService _classificationService =
      MockClassificationService();
  final MaterialCatalogService _catalogService =
      LocalMaterialCatalogService();

  final List<LotItem> _items = [];

  File? _image;
  ClassificationResult? _classification;
  MaterialInfo? _materialInfo;

  bool _isAnalyzing = false;

  late TextEditingController _quantityController;

  String _quality = 'अच्छा';

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '100');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo == null) return;

    setState(() {
      _image = File(photo.path);
      _classification = null;
      _materialInfo = null;
      _isAnalyzing = true;
    });

    try {
      final result = await _classificationService.classify(
        File(photo.path),
      );

      final materialInfo = _catalogService.getMaterial(result.material);

      setState(() {
        _classification = result;
        _materialInfo = materialInfo;
        _isAnalyzing = false;

        // Set a sensible default quantity based on unit.
        _quantityController.text =
            materialInfo.unit == 'ग्राम' ? '100' : '1';
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('सामग्री पहचानने में समस्या हुई'),
        ),
      );
    }
  }

  void _changeQuantity(double change) {
    final current =
        double.tryParse(_quantityController.text.trim()) ?? 0;

    final newValue = current + change;

    if (newValue <= 0) return;

    setState(() {
      _quantityController.text = _formatQuantity(newValue);
    });
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  void _addToLot() {
    if (_classification == null || _materialInfo == null) return;

    final quantity =
        double.tryParse(_quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया सही मात्रा दर्ज करें'),
        ),
      );
      return;
    }

    final item = LotItem(
      material: _materialInfo!.name,
      unit: _materialInfo!.unit,
      quantity: quantity,
      quality: _quality,
      rate: _materialInfo!.rate,
      imagePath: _image?.path,
      confidence: _classification!.confidence,
    );

    setState(() {
      _items.add(item);

      // Reset current scan so another item can be added.
      _image = null;
      _classification = null;
      _materialInfo = null;
      _quantityController.text = '100';
      _quality = 'अच्छा';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('सामग्री लॉट में जोड़ दी गई'),
      ),
    );
  }

  double get _totalPrice {
    return _items.fold(
      0,
      (sum, item) => sum + item.estimatedPrice,
    );
  }

  double get _totalWeightGrams {
    return _items.fold(
      0,
      (sum, item) {
        if (item.unit == 'किलो') {
          return sum + (item.quantity * 1000);
        }

        if (item.unit == 'ग्राम') {
          return sum + item.quantity;
        }

        return sum;
      },
    );
  }

  void _proceed() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('पहले कम से कम एक सामग्री लॉट में जोड़ें'),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/recyclers',
      arguments: {
        'items': _items,
        'totalPrice': _totalPrice,
        'totalWeightGrams': _totalWeightGrams,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('नया लॉट'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'फोटो लें और सामग्री चुनें',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'सामग्री की फोटो लेकर AI से पहचान करवाएँ',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildPhotoSection(),

                    if (_isAnalyzing) ...[
                      const SizedBox(height: 20),
                      _buildAnalyzingCard(),
                    ],

                    if (_classification != null &&
                        _materialInfo != null) ...[
                      const SizedBox(height: 20),
                      _buildClassificationResult(),
                    ],

                    if (_items.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildLotItems(),
                    ],
                  ],
                ),
              ),
            ),

            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    if (_image == null) {
      return Container(
        width: double.infinity,
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          color: Colors.grey.shade50,
        ),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: _takePhoto,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('फोटो लें'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 16,
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.file(
        _image!,
        width: double.infinity,
        height: 260,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildAnalyzingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'AI सामग्री की पहचान कर रहा है...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationResult() {
    final material = _materialInfo!;
    final confidence =
        (_classification!.confidence * 100).round();

    final quantity =
        double.tryParse(_quantityController.text) ?? 0;

    final estimatedPrice = quantity * material.rate;

    final quantityStep = material.unit == 'ग्राम' ? 10.0 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5EF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFB9DCC9),
            ),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 25,
                child: Icon(Icons.check),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI ने पहचान लिया',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      material.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'विश्वास: $confidence%',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'मात्रा',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            _quantityButton(
              icon: Icons.remove,
              onPressed: () => _changeQuantity(-quantityStep),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  suffixText: material.unit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            _quantityButton(
              icon: Icons.add,
              onPressed: () => _changeQuantity(quantityStep),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 8,
          children: [
            _quickQuantity('1', material.unit),
            _quickQuantity(
              material.unit == 'ग्राम' ? '100' : '4',
              material.unit,
            ),
            _quickQuantity(
              material.unit == 'ग्राम' ? '500' : '8',
              material.unit,
            ),
          ],
        ),

        const SizedBox(height: 20),

        const Text(
          'गुणवत्ता',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: _quality,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'नया जैसा',
              child: Text('नया जैसा'),
            ),
            DropdownMenuItem(
              value: 'बहुत अच्छा',
              child: Text('बहुत अच्छा'),
            ),
            DropdownMenuItem(
              value: 'अच्छा',
              child: Text('अच्छा'),
            ),
            DropdownMenuItem(
              value: 'खराब',
              child: Text('खराब'),
            ),
            DropdownMenuItem(
              value: 'पता नहीं',
              child: Text('पता नहीं'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _quality = value;
            });
          },
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'अनुमानित कीमत',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₹${estimatedPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _addToLot,
            child: const Text('लॉट में जोड़ें'),
          ),
        ),
      ],
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }

  Widget _quickQuantity(String value, String unit) {
    return ActionChip(
      label: Text('$value $unit'),
      onPressed: () {
        setState(() {
          _quantityController.text = value;
        });
      },
    );
  }

  Widget _buildLotItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'आपका लॉट',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        ..._items.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final item = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                          '${_formatQuantity(item.quantity)} ${item.unit} · ${item.quality}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '₹${item.estimatedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        OutlinedButton.icon(
          onPressed: _takePhoto,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('एक और सामग्री स्कैन करें'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _items.isEmpty ? null : _proceed,
          child: Text(
            _items.isEmpty
                ? 'आगे बढ़ें'
                : 'आगे बढ़ें · ₹${_totalPrice.toStringAsFixed(0)}',
          ),
        ),
      ),
    );
  }
}