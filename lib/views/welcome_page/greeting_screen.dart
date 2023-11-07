import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/views/welcome_page/welcome_page.dart';

final hello = [
  'Chào mừng bạn tới Tourly, một ứng dụng tuyệt vời để tìm kiếm thông tin du lịch',
  'Nếu bạn cần hỗ trợ bất kỳ điều gì, hãy mở Tourly',
  'Tourly sẽ luôn luôn hỗ trợ và khiến bạn trở lên vui vẻ'
];

final images = [
  'assets/images/introImage/intro1.png',
  'assets/images/introImage/intro2.png',
  'assets/images/introImage/intro3.png',
];

class Greeting extends StatefulWidget {
  const Greeting({super.key});

  @override
  State<StatefulWidget> createState() => _GreetingState();
}

class _GreetingState extends State<Greeting> {
  final box = GetStorage();
  // bool isVisible = true;
  final PageController controller = PageController();
  int numberOfPages = 3;
  int currentPage = 0;

  @override
  void initState() {
    // Future.delayed(const Duration(seconds: 2), () {
    //   setState(() {
    //     isVisible = false;
    //   });
    // });
    box.write('accessed_application', true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConst.kPrimaryLightColor,
      appBar: null,
      body:
          // Visibility(
          //   visible: isVisible,
          //   replacement:
          Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: numberOfPages,
            itemBuilder: (BuildContext context, int index) {
              return EachPage(hello[index], images[index]);
            },
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: Center(
                          child: (currentPage != numberOfPages - 1)
                              ? TextButton(
                                  onPressed: () {
                                    controller.jumpToPage(numberOfPages - 1);
                                  },
                                  child:
                                      const Text("Bỏ qua", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                      Flexible(child: Center(child: Indicator(controller: controller, pageCount: numberOfPages))),
                      Flexible(
                        child: Center(
                          child: (currentPage != numberOfPages - 1)
                              ? TextButton(
                                  onPressed: () {
                                    controller.jumpToPage(currentPage + 1);
                                  },
                                  child: const Text("Tiếp tục",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                )
                              : TextButton(
                                  onPressed: () {
                                    Get.off(() => Welcome());
                                  },
                                  child: const Text("Hoàn thành",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
      // child: Center(
      //   child: Image.asset(
      //     'assets/images/vietnam.jpeg',
      //     fit: BoxFit.fitWidth,
      //   ),
      // ),
      // ),
    );
  }
}

class EachPage extends StatelessWidget {
  final String message;
  final String image;

  const EachPage(this.message, this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppConst.kPrimaryLightColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Image.asset(
                image,
                height: size.height * 0.65,
                fit: BoxFit.fitHeight,
              ),
              SizedBox(height: size.height * 0.03),
              Text(
                message,
                style: AppConst.style(AppConst.kFontSize * 1.4, AppConst.kTextColor),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Indicator extends AnimatedWidget {
  final PageController controller;
  final int pageCount;

  const Indicator({super.key, required this.controller, required this.pageCount}) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            itemCount: pageCount,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return _createIndicator(index);
            },
          )
        ],
      ),
    );
  }

  Widget _createIndicator(index) {
    Color color = const Color.fromRGBO(1, 1, 1, 0.2);

    if (controller.page == index) {
      color = Colors.black;
    }

    return SizedBox(
      height: 25,
      width: 25,
      child: Center(
        child: AnimatedContainer(
          margin: const EdgeInsets.all(8),
          duration: const Duration(microseconds: 100),
          child: CircleAvatar(backgroundColor: color),
        ),
      ),
    );
  }
}
