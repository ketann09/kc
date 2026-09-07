import 'package:flutter/material.dart';

class CollectorDashboardScreen extends StatelessWidget {
  const CollectorDashboardScreen({super.key});

  static const List<_ScrapRate> rates = [
    _ScrapRate(
      name: 'पीसीबी',
      subtitle: 'प्रति किलोग्राम',
      price: 210,
      icon: Icons.memory_rounded,
    ),
    _ScrapRate(
      name: 'बैटरी',
      subtitle: 'प्रति किलोग्राम',
      price: 85,
      icon: Icons.battery_full_rounded,
    ),
    _ScrapRate(
      name: 'केबल',
      subtitle: 'प्रति किलोग्राम',
      price: 140,
      icon: Icons.cable_rounded,
    ),
    _ScrapRate(
      name: 'मिश्रित प्लास्टिक',
      subtitle: 'प्रति किलोग्राम',
      price: 22,
      icon: Icons.recycling_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  _BackButton(
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(width: 16),

                  const Expanded(
                    child: Text(
                      'आज का भाव',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF191919),
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('आज के भाव अपडेट किए गए हैं'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.volume_up_outlined,
                      color: Color(0xFF147A65),
                      size: 23,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Padding(
                padding: EdgeInsets.only(left: 56),
                child: Text(
                  'आपके पास कबाड़ का भाव, आज के लिए',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF777777),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: rates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _RateCard(rate: rates[index]);
                  },
                ),
              ),

              // New lot CTA
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/new-lot',
                    );
                  },
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 22,
                  ),
                  label: const Text(
                    'नया लॉट बनाएँ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF147A65),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  final _ScrapRate rate;

  const _RateCard({
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F5),
        border: Border.all(
          color: const Color(0xFFE1E1DC),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE2F2EB),
              shape: BoxShape.circle,
            ),
            child: Icon(
              rate.icon,
              size: 21,
              color: const Color(0xFF147A65),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rate.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rate.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₹${rate.price}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF222222),
            ),
          ),

          const SizedBox(width: 6),

          const Text(
            '/kg',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF222222),
            width: 1.5,
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          size: 22,
        ),
      ),
    );
  }
}

class _ScrapRate {
  final String name;
  final String subtitle;
  final int price;
  final IconData icon;

  const _ScrapRate({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.icon,
  });
}