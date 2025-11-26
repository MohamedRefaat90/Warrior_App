import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/flushbar.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/Auth/presentation/provider/verify_otp_provider.dart';
import 'package:Warrior/features/Auth/presentation/widgets/otp_fileds.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: context.screenPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ResponsiveUtils.maxContentWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Enter the OTP sent to your email",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: context.mediumSpacing),
                    Center(child: RoundedWithShadow(email: widget.email)),
                    SizedBox(height: context.mediumSpacing),
                    OtpTimerButton(
                      onPressed: () async {
                        await ref
                            .read(otpProvider.notifier)
                            .resendOTP(widget.email);
                      },
                      buttonType: ButtonType.text_button,
                      textColor: Colors.blue,
                      backgroundColor: Colors.blue,
                      text: const Text('Resend OTP'),
                      duration: 90,
                    ),
                    providerStates.isLoading
                        ? Lottie.asset(AppAssets.loader,
                            width: ResponsiveUtils.value<double>(
                              context,
                              mobile: 100,
                              tablet: 120,
                              desktop: 140,
                            ))
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual<ProviderStates>(otpProvider, (previous, current) {
      if (current.isSuccess) {
        context.goNamed(AppRouters.newPassword, extra: widget.email);
      } else if (current.errorMessage != null) {
        showErrorFlushbar(
          context,
          position: FlushbarPosition.BOTTOM,
          current.errorMessage!,
        );
      }
    });
  }
}
