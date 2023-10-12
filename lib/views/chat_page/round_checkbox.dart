import 'package:flutter/material.dart';
import 'package:tourly/common/app_constants.dart';

class RoundCheckBox extends StatelessWidget {
  const RoundCheckBox({Key? key, required this.value}) : super(key: key);
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value ? Colors.blue : Colors.white,
          border: const Border.fromBorderSide(BorderSide(width: 1, color: AppConst.kPrimaryColor)),
        ),
        child: value
            ? const Icon(Icons.check, size: 18.0, color: Colors.white)
            : const Icon(Icons.check_box_outline_blank, size: 18.0, color: Colors.white),
      ),
    );
  }
}
