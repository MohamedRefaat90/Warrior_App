import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  final TextEditingController? textEditingController;
  final String? placeholderText;
  final void Function(String)? onChange;
  final String? Function(String?)? validator;
  final bool isPassword;
  bool isObscure;
  final bool isTextArea;
  CustomTextField(
      {this.textEditingController,
      super.key,
      this.isPassword = false,
      required this.isObscure,
      this.placeholderText,
      this.onChange,
      this.isTextArea = false,
      this.validator});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = context.responsiveBorderRadius;
    return TextFormField(
      controller: widget.textEditingController,
      validator: widget.validator,
      onChanged: widget.onChange,
      obscureText: widget.isObscure,
      maxLines: widget.isTextArea ? 4 : 1,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
          enabled: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: context.smallSpacing,
            horizontal: context.mediumSpacing,
          ),
          filled: true,
          hintText: widget.placeholderText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9694A3),
              ),
          fillColor: isDark ? AppColors.black : AppColors.white,
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: AppColors.darkOnSurfaceVariant, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: widget.isObscure
                      ? Icon(Icons.visibility)
                      : Icon(Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      widget.isObscure = !widget.isObscure;
                    });
                  },
                )
              : null),
    );
  }
}
