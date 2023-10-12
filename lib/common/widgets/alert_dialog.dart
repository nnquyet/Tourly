import 'package:flutter/material.dart';

import '../app_constants.dart';

class AlertDialogCustom extends StatelessWidget {
  const AlertDialogCustom({super.key, required this.notification, this.onPress, this.children2});

  final String notification;
  final void Function()? onPress;
  final Widget? children2;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            height: 100,
            child: Center(
              child: Image.asset('assets/images/bot.png'),
            ),
          ),
          const SizedBox(height: 10),
          Text(notification, textAlign: TextAlign.center),
          if (children2 != null) const SizedBox(height: 30),
          if (children2 != null) children2!,
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConst.kPrimaryLightColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppConst.kButtonColor)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng dialog
                  },
                  child: const Text('Huỷ', style: TextStyle(fontSize: 16, color: AppConst.kButtonColor)),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConst.kButtonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: onPress,
                  child: const Text('Đồng ý', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        )
      ],
    );
  }
}
