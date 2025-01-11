import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/flushbar.dart';
import 'package:Warrior/features/Auth/presentation/provider/verifyOTP_provider.dart';
import 'package:Warrior/features/Auth/presentation/widgets/otp_fileds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_timer_button/otp_timer_button.dart';

import '../../../../core/network/provider_states.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyOtpScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  @override
  Widget build(BuildContext context) {
    ProviderStates providerStates = ref.watch(otpProvider);
    return Scaffold(
        appBar: AppBar(title: const Text('Verify OTP'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const Text("Enter the OTP sent to your email"),
              20.verticalSpace,
              Center(child: RoundedWithShadow(email: widget.email)),
              20.verticalSpace,
              OtpTimerButton(
                onPressed: () async {
                  await ref.read(otpProvider.notifier).resendOTP(widget.email);
                },
                buttonType: ButtonType.text_button,
                textColor: Colors.blue,
                backgroundColor: Colors.blue,
                text: const Text('Resend OTP'),
                duration: 90,
              ),
              providerStates.isLoading
                  ? Lottie.asset(AppAssets.loader, width: 100.w)
                  : const SizedBox(),
            ],
          ),
        ));
  }

  @override
  void initState() {
    ref.listenManual<ProviderStates>(otpProvider, (previous, current) {
      if (current.isSuccess) {
        context.goNamed(AppRouters.newPassword, extra: widget.email);
      } else if (current.errorMessage != null) {
        flushBar(context,
            message: current.errorMessage!, color: AppColors.primaryColor!);
      }
    });
    super.initState();
  }
}
