import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/widgets/app_image.dart';

class CarouselSliderImageCustom extends StatefulWidget {
  const CarouselSliderImageCustom({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<CarouselSliderImageCustom> createState() => _CarouselSliderImageCustomState();
}

class _CarouselSliderImageCustomState extends State<CarouselSliderImageCustom> {
  CarouselController controller = CarouselController();
  int initialPage = 0;
  late List<String> imagesUrlList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagesUrlList = widget.imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
            carouselController: controller,
            items: imagesUrlList.map((imageUrl) {
              return AppImage(imageUrl, double.infinity, Get.size.width * 0.7);
            }).toList(),
            options: CarouselOptions(
              height: Get.size.width * 0.7,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                setState(() {
                  initialPage = index;
                });
              },
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imagesUrlList.asMap().entries.map((imageUrl) {
            return InkWell(
              onTap: () {
                controller.jumpToPage(imageUrl.key);
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: initialPage == imageUrl.key ? AppConst.kPrimaryLightColor : Colors.grey.withOpacity(0.4),
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
