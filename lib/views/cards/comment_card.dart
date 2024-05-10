import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/widgets/app_image.dart';
import 'package:tourly/models/comment_model.dart';

class CommentCard extends StatelessWidget {
  final CommentModel commentModel;

  const CommentCard(this.commentModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      padding: const EdgeInsets.all(4),
      constraints: BoxConstraints(minHeight: 220),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(16.0), border: Border.all(color: AppConst.kGrayColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: AppImage(commentModel.imagePath, 50, 50, circular: 25),
            title: Text(
              commentModel.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: AppConst.kFontSize),
            ),
            subtitle: Text(commentModel.time),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              commentModel.comment,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: AppConst.kFontSize),
            ),
          ),
          if (commentModel.comment.length > 160)
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: Get.height * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: AppImage(commentModel.imagePath, 50, 50, circular: 25),
                            title: Text(
                              commentModel.fullName,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: AppConst.kFontSize),
                            ),
                            subtitle: Text(commentModel.time),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                              child: Text(
                                commentModel.comment,
                                style: const TextStyle(fontSize: AppConst.kFontSize),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 1, // Underline thickness
                    ),
                  ),
                ),
                child: const Text(
                  'Xem thêm',
                  style: TextStyle(
                    fontSize: AppConst.kFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
