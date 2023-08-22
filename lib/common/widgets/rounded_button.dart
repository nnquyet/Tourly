import 'package:flutter/material.dart';
import 'package:tourly/common/app_constants.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;

  const RoundedButton(
      {Key? key,
      required this.text,
      required this.press,
      this.color = AppConst.kButtonColor,
      this.textColor = AppConst.kPrimaryLightColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: Size.fromWidth(size.width * 0.9),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29),
            side: const BorderSide(color: AppConst.kButtonColor),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: AppConst.kFontSize, fontWeight: FontWeight.bold),
        ),
        onPressed: () => press(),
      ),
    );
  }
}
