import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Verify OTP'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const Text("Enter the OTP sent to your email"),
            20.verticalSpace,
            Center(
              child: Pinput(
                onCompleted: (pin) => print(pin),
                showCursor: true,
                closeKeyboardWhenCompleted: true,
                length: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
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
        ));
  }
}
