import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _selectRole(BuildContext context, String role) {
    Navigator.pushNamed(
      context,
      '/state',
      arguments: role,
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
              const SizedBox(height: 58),

              const Text(
                'आप कौन हैं?',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191919),
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'अपना रोल चुनें',
                style: TextStyle(
                  fontSize: 19,
                  color: Color(0xFF666666),
                ),
              ),

              const Spacer(),

              _RoleCard(
                icon: Icons.recycling,
                title: 'मैं कलेक्टर हूँ',
                subtitle: 'कबाड़ इकट्ठा करता हूँ',
                onTap: () => _selectRole(context, 'collector'),
              ),

              const SizedBox(height: 20),

              _RoleCard(
                icon: Icons.factory_outlined,
                title: 'मैं रीसाइक्लर हूँ',
                subtitle: 'कबाड़ खरीदता हूँ',
                onTap: () => _selectRole(context, 'recycler'),
              ),

              const Spacer(),

              const Center(
                child: Text(
                  'आप बाद में अपना रोल बदल सकते हैं',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF888888),
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 25,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF6FBF8),
            border: Border.all(
              color: const Color(0xFFD6E7DF),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F1E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: const Color(0xFF147A65),
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF191919),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 19,
                color: Color(0xFF147A65),
              ),
            ],
          ),
        ),
      ),
    );
  }
}