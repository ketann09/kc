import 'package:flutter/material.dart';

class StateSelectionScreen extends StatelessWidget {
  final String role;

  const StateSelectionScreen({
    super.key,
    required this.role,
  });

  static const List<String> states = [
    'उत्तर प्रदेश',
    'दिल्ली',
    'हरियाणा',
    'राजस्थान',
    'महाराष्ट्र',
    'मध्य प्रदेश',
  ];

  void _selectState(BuildContext context, String state) {
    Navigator.pushNamed(
      context,
      '/city',
      arguments: {
        'role': role,
        'state': state,
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
                'राज्य चुनें',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191919),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'आप किस राज्य में हैं?',
                style: TextStyle(
                  fontSize: 19,
                  color: Color(0xFF666666),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView.separated(
                  itemCount: states.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final state = states[index];

                    return _SelectionTile(
                      title: state,
                      onTap: () => _selectState(context, state),
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

class _SelectionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.title,
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
                Icons.location_on_outlined,
                color: Color(0xFF147A65),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  title,
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