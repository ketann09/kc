import 'package:flutter/material.dart';

class RecyclerLotDetailsPlaceholderScreen extends StatelessWidget {
  final String lotId;

  const RecyclerLotDetailsPlaceholderScreen({super.key, required this.lotId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'लॉट विवरण',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF5EF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Color(0xFF147A65),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'लॉट विवरण',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191919),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'लॉट आईडी: $lotId',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'लॉट विवरण स्क्रीन जल्द ही उपलब्ध होगी।',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
