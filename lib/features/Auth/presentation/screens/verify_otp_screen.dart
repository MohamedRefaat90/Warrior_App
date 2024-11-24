import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Auth/presentation/widgets/otp_fileds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otp_timer_button/otp_timer_button.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Verify OTP'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const Text("Enter the OTP sent to your email"),
              20.verticalSpace,
              const Center(child: RoundedWithShadow()),
              20.verticalSpace,
              OtpTimerButton(
                // controller: controller,
                onPressed: () {},
                buttonType: ButtonType.text_button,
                textColor: Colors.blue,
                backgroundColor: Colors.blue,
                text: const Text('Resend OTP'),
                duration: 60,
              ),
              15.verticalSpace,
              CustomBTN(
                  widget: const Text('Submit'),
                  padding: 15,
                  width: 150,
                  color: const Color(0xffb4182d),
                  press: () {})
            ],
          ),
        ));
  }
}
