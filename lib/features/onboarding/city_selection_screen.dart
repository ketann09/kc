import 'package:flutter/material.dart';

class CitySelectionScreen extends StatelessWidget {
  final String role;
  final String state;

  const CitySelectionScreen({
    super.key,
    required this.role,
    required this.state,
  });

  List<String> get cities {
    switch (state) {
      case 'उत्तर प्रदेश':
        return [
          'गाज़ियाबाद',
          'नोएडा',
          'लखनऊ',
          'कानपुर',
          'आगरा',
          'वाराणसी',
        ];

      case 'दिल्ली':
        return [
          'नई दिल्ली',
          'उत्तर दिल्ली',
          'दक्षिण दिल्ली',
          'पूर्वी दिल्ली',
        ];

      case 'हरियाणा':
        return [
          'गुरुग्राम',
          'फरीदाबाद',
          'पानीपत',
          'रोहतक',
        ];

      case 'राजस्थान':
        return [
          'जयपुर',
          'जोधपुर',
          'उदयपुर',
          'कोटा',
        ];

      case 'महाराष्ट्र':
        return [
          'मुंबई',
          'पुणे',
          'नागपुर',
          'नासिक',
        ];

      default:
        return [
          'भोपाल',
          'इंदौर',
          'ग्वालियर',
          'जबलपुर',
        ];
    }
  }

  void _selectCity(BuildContext context, String city) {
    Navigator.pushNamed(
      context,
      role == 'collector'
          ? '/collector-dashboard'
          : '/recycler-dashboard',
      arguments: {
        'role': role,
        'state': state,
        'city': city,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 31),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),

              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),

              const SizedBox(height: 20),

              const Text(
                'शहर चुनें',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191919),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '$state में अपना शहर चुनें',
                style: const TextStyle(
                  fontSize: 19,
                  color: Color(0xFF666666),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final city = cities[index];

                    return _CityTile(
                      city: city,
                      onTap: () => _selectCity(context, city),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  final String city;
  final VoidCallback onTap;

  const _CityTile({
    required this.city,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFD8D8D8),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_city_outlined,
                color: Color(0xFF147A65),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  city,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202020),
                  ),
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Color(0xFF777777),
              ),
            ],
          ),
        ),
      ),
    );
  }
}