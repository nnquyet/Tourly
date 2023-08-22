import 'package:flutter/material.dart';
import 'package:tourly/common/app_constants.dart';

class TextFieldContainer extends StatelessWidget {
  final String title;
  final String hintText;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final Color? iconColor;
  final void Function()? onClickIcon;
  final bool? obscureText;
  final TextEditingController controller;
  final FormFieldValidator? validator;
  final TextInputType? keyboardType;
  final String? suffixText;

  const TextFieldContainer(
      {Key? key,
      required this.hintText,
      required this.onChanged,
      this.icon,
      this.iconColor,
      this.onClickIcon,
      this.obscureText,
      required this.controller,
      this.validator,
      required this.title,
      this.keyboardType,
      this.suffixText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.9,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText ?? false,
        onChanged: onChanged,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: AppConst.kFontSize, color: AppConst.kSubTextColor),
          labelText: title,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(10),
          suffixText: suffixText,
          suffixStyle: TextStyle(color: Colors.red),
          suffixIcon: GestureDetector(onTap: onClickIcon, child: Icon(icon, color: iconColor)),
        ),
        style: const TextStyle(fontSize: AppConst.kFontSize, color: AppConst.kTextColor),
        validator: validator,
      ),
    );
  }
}
