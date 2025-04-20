import 'package:Warrior/core/constants/colors.dart';
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
    return TextFormField(
      controller: widget.textEditingController,
      validator: widget.validator,
      onChanged: widget.onChange,
      obscureText: widget.isObscure,
      maxLines: widget.isTextArea ? 4 : 1,
      decoration: InputDecoration(
          enabled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          filled: true,
          hintText: widget.placeholderText,
          hintStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
          fillColor: AppColors.white,
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 10),
              borderRadius: BorderRadius.all(Radius.circular(15))),
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
