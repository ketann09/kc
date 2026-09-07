import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewScrapLotScreen extends StatefulWidget {
  const NewScrapLotScreen({super.key});

  @override
  State<NewScrapLotScreen> createState() => _NewScrapLotScreenState();
}

class _NewScrapLotScreenState extends State<NewScrapLotScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _image;
  String _selectedMaterial = 'पीसीबी';
  double _weight = 4;

  final Map<String, double> _rates = {
    'पीसीबी': 210,
    'बैटरी': 85,
    'केबल': 140,
  };

  double get _rate => _rates[_selectedMaterial] ?? 0;
  double get _estimatedPrice => _rate * _weight;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() {
        _image = File(picked.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('फोटो लेने में समस्या हुई'),
        ),
      );
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'फोटो जोड़ें',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('कैमरा'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('गैलरी'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeWeight(double amount) {
    setState(() {
      _weight += amount;

      if (_weight < 1) {
        _weight = 1;
      }

      if (_weight > 50) {
        _weight = 50;
      }
    });
  }

  void _setWeight(double weight) {
    setState(() {
      _weight = weight;
    });
  }

  void _continue() {
    Navigator.pushNamed(
      context,
      '/recyclers',
      arguments: {
        'material': _selectedMaterial,
        'weight': _weight,
        'price': _estimatedPrice,
        'image': _image,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'नया लॉट',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'फोटो लें और सामग्री चुनें',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'सही जानकारी से आपको उचित भाव मिलेगा',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 22),

              // PHOTO
              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  height: 210,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7F3),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFD4DDD6),
                    ),
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 34,
                                color: Color(0xFF176B45),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'फोटो लेने के लिए टैप करें',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'कैमरा या गैलरी से फोटो चुनें',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: Image.file(
                            _image!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // MATERIAL
              const Text(
                'सामग्री',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _MaterialChip(
                    label: 'पीसीबी',
                    icon: Icons.memory_outlined,
                    selected: _selectedMaterial == 'पीसीबी',
                    onTap: () {
                      setState(() {
                        _selectedMaterial = 'पीसीबी';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _MaterialChip(
                    label: 'बैटरी',
                    icon: Icons.battery_full_outlined,
                    selected: _selectedMaterial == 'बैटरी',
                    onTap: () {
                      setState(() {
                        _selectedMaterial = 'बैटरी';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _MaterialChip(
                    label: 'केबल',
                    icon: Icons.cable_outlined,
                    selected: _selectedMaterial == 'केबल',
                    onTap: () {
                      setState(() {
                        _selectedMaterial = 'केबल';
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // WEIGHT
              const Text(
                'वज़न',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  _WeightButton(
                    icon: Icons.remove,
                    onTap: () => _changeWeight(-1),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_weight.toStringAsFixed(0)} किलो',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  _WeightButton(
                    icon: Icons.add,
                    onTap: () => _changeWeight(1),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _QuickWeight(
                    label: '1 किलो',
                    onTap: () => _setWeight(1),
                  ),
                  const SizedBox(width: 8),
                  _QuickWeight(
                    label: '4 किलो',
                    onTap: () => _setWeight(4),
                  ),
                  const SizedBox(width: 8),
                  _QuickWeight(
                    label: '8 किलो',
                    onTap: () => _setWeight(8),
                  ),
                  const SizedBox(width: 8),
                  _QuickWeight(
                    label: '10+ किलो',
                    onTap: () => _setWeight(10),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // PRICE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5EF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'अनुमानित कीमत',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '₹${_estimatedPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF176B45),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'दर: ₹${_rate.toStringAsFixed(0)}/किलो',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              // CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  child: const Text(
                    'आगे बढ़ें',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MaterialChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE4F2EA)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF176B45)
                  : const Color(0xFFD9DED9),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? const Color(0xFF176B45)
                    : Colors.black54,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _WeightButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD9DED9),
            ),
          ),
          child: Icon(icon),
        ),
      ),
    );
  }
}

class _QuickWeight extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickWeight({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}