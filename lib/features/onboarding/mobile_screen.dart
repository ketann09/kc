import 'package:flutter/material.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({super.key});

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  final TextEditingController _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _getOtp() {
    final mobile = _mobileController.text.trim();

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया 10 अंकों का मोबाइल नंबर दर्ज करें'),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/otp',
      arguments: mobile,
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

              // Greeting
              const Text(
                'नमस्ते!',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191919),
                  height: 1.05,
                ),
              ),

              const SizedBox(height: 38),

              // Heading
              const Text(
                'अपना खाता बनाएं',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191919),
                  height: 1.15,
                ),
              ),

              const Spacer(),

              const Text(
                'अपना मोबाइल नंबर दर्ज करें',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202020),
                ),
              ),

              const SizedBox(height: 22),

              // Mobile number field
              Container(
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 25),

                    const Icon(
                      Icons.phone_android_outlined,
                      color: Color(0xFF087F68),
                      size: 25,
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'दर्ज करें',
                          hintStyle: TextStyle(
                            color: Color(0xFF858585),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    ),

                    const SizedBox(width: 45),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // OTP button
              SizedBox(
                width: double.infinity,
                height: 68,
                child: ElevatedButton.icon(
                  onPressed: _getOtp,
                  icon: const Icon(
                    Icons.phone_android_outlined,
                    size: 23,
                  ),
                  label: const Text(
                    'OTP प्राप्त करें',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF147A65),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}