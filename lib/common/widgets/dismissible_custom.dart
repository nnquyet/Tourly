import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';

class DismissibleCustom extends StatelessWidget {
  final Widget child;

  const DismissibleCustom(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.vertical,
      key: const Key('key'),
      onDismissed: (_) => Get.back(),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.close,
                        )),
                    const Spacer(),
                    const Text(
                      'Xem thêm',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: AppConst.kFontSize),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.close,
                          color: Colors.transparent,
                        )),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.black.withOpacity(0.15),
              ),
              SingleChildScrollView(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
