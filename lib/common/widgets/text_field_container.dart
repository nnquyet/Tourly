import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tourly/common/app_constants.dart';

class TextFieldContainerAuth extends StatelessWidget {
  final String title;
  final String hintText;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final Color? iconColor;
  final void Function()? onClickIcon;
  final bool? obscureText;
  final TextEditingController controller;
  final FormFieldValidator? validator;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? suffixText;

  const TextFieldContainerAuth(
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
      this.readOnly = false,
      this.keyboardType,
      this.suffixText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.9,
      child: TextFormField(
        readOnly: readOnly,
        controller: controller,
        obscureText: obscureText ?? false,
        onChanged: onChanged,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppConst.kButtonColor, width: 1.5)),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: AppConst.kFontSize, color: AppConst.kSubTextColor),
          labelText: title,
          labelStyle: const TextStyle(
            color: AppConst.kTextColor, // Đặt màu cho labelText ở đây
          ),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(10),
          suffixText: suffixText,
          suffixStyle: const TextStyle(color: Colors.red),
          suffixIcon: GestureDetector(onTap: onClickIcon, child: Icon(icon, color: iconColor)),
        ),
        style: const TextStyle(fontSize: AppConst.kFontSize, color: AppConst.kTextColor),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final String title;
  final String hintText;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final Color iconColor;
  final void Function()? onClickIcon;
  final bool obscureText;
  final TextEditingController controller;
  final FormFieldValidator? validator;
  final bool readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  TextFieldContainer(
      {Key? key,
      required this.hintText,
      required this.onChanged,
      required this.icon,
      required this.iconColor,
      this.onClickIcon,
      required this.obscureText,
      required this.controller,
      this.validator,
      required this.title,
      this.readOnly = false,
      this.keyboardType,
      this.inputFormatters})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
              offset: const Offset(0, 8),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )),
          TextFormField(
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(fontSize: 13),
              border: const UnderlineInputBorder(borderSide: BorderSide(width: 0.3)),
              focusedBorder:
                  const UnderlineInputBorder(borderSide: BorderSide(width: 1, color: AppConst.kPrimaryColor)),
              contentPadding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
              suffixIcon: GestureDetector(onTap: onClickIcon, child: Icon(icon, color: iconColor)),
            ),
            style: const TextStyle(),
            validator: validator,
          )
        ],
      ),
    );
  }
}

class TextFieldContainerSecond extends StatelessWidget {
  final String title;
  final String unit;
  final String hintText;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final Color iconColor;
  final void Function()? onClickIcon;
  final bool obscureText;
  final TextEditingController controller;
  final FormFieldValidator? validator;
  final bool readOnly;

  const TextFieldContainerSecond({
    Key? key,
    required this.hintText,
    required this.unit,
    required this.onChanged,
    required this.icon,
    required this.iconColor,
    this.onClickIcon,
    required this.obscureText,
    required this.controller,
    this.validator,
    required this.title,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
              offset: const Offset(0, 8),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly // Giới hạn chỉ cho phép nhập số
                  ],
                  readOnly: readOnly,
                  controller: controller,
                  obscureText: obscureText,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(fontSize: 13),
                    border: const UnderlineInputBorder(borderSide: BorderSide(width: 0.3)),
                    focusedBorder:
                        const UnderlineInputBorder(borderSide: BorderSide(width: 1, color: AppConst.kPrimaryColor)),
                    contentPadding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                    suffixIcon: GestureDetector(onTap: onClickIcon, child: Icon(icon, color: iconColor)),
                  ),
                  style: const TextStyle(),
                  validator: validator,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, 6),
                child: Text(
                  unit,
                  style: AppConst.style(16, AppConst.kTextColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
