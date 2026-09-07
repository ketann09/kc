import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;

  const OtpScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया 4 अंकों का OTP दर्ज करें'),
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, '/role');
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
                'OTP दर्ज करें',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191919),
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                '${widget.mobileNumber} पर भेजा गया OTP दर्ज करें',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF555555),
                  height: 1.4,
                ),
              ),

              const Spacer(),

              const Text(
                '4 अंकों का OTP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202020),
                ),
              ),

              const SizedBox(height: 22),

              Container(
                height: 74,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 12,
                  ),
                  decoration: const InputDecoration(
                    hintText: '• • • •',
                    hintStyle: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 24,
                      letterSpacing: 6,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 68,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF147A65),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Text(
                    'सत्यापित करें',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('OTP दोबारा भेज दिया गया है'),
                      ),
                    );
                  },
                  child: const Text(
                    'OTP दोबारा भेजें',
                    style: TextStyle(
                      color: Color(0xFF147A65),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}