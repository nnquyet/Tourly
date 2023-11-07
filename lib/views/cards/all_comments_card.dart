import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/models/comment_model.dart';
import 'package:tourly/views/cards/comment_card.dart';

class AllCommentsCard extends StatelessWidget {
  const AllCommentsCard({super.key, required this.commentList});

  final List<CommentModel> commentList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: commentList.length,
                    itemBuilder: (context, index) {
                      return CommentCard(commentList[index]);
                    },
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppConst.kTransparentGrayColor,
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(top: 50, left: 15),
              child: const Icon(
                Icons.arrow_back,
                size: AppConst.kFontSize,
                color: AppConst.kPrimaryLightColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
