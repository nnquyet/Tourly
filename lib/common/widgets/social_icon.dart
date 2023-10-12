import 'package:flutter/material.dart';
import 'package:tourly/common/app_constants.dart';

class SocialIcon extends StatelessWidget {
  final String iconSrc;
  final void Function()? press;

  const SocialIcon({Key? key, required this.iconSrc, this.press}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: AppConst.kSubTextColor),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(30)),
          child: ClipOval(child: Image.asset(iconSrc, width: 25, height: 25))),
    );
  }
}
