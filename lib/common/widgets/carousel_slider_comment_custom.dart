import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/models/comment_model.dart';
import 'package:tourly/views/cards/comment_card.dart';

class CarouselSliderCommentCustom extends StatefulWidget {
  const CarouselSliderCommentCustom({super.key, required this.commentList});

  final List<CommentModel> commentList;

  @override
  State<CarouselSliderCommentCustom> createState() => _CarouselSliderCommentCustomState();
}

class _CarouselSliderCommentCustomState extends State<CarouselSliderCommentCustom> {
  CarouselController controller = CarouselController();
  int initialPage = 0;
  late List<CommentModel> commentList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    commentList = widget.commentList;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
            carouselController: controller,
            items: commentList.take(5).map((comment) {
              return CommentCard(comment);
            }).toList(),
            options: CarouselOptions(
              height: 250,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 1,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  initialPage = index;
                });
              },
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: commentList.asMap().entries.take(5).map((comment) {
            return InkWell(
              onTap: () {
                controller.jumpToPage(comment.key);
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: initialPage == comment.key ? AppConst.kTextColor : Colors.grey.withOpacity(0.4),
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
