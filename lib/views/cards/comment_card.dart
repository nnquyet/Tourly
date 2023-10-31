import 'package:flutter/material.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/common/widgets/app_image.dart';
import 'package:tourly/common/widgets/dismissible_custom.dart';
import 'package:tourly/models/comment_model.dart';

class CommentCard extends StatelessWidget {
  final CommentModel commentModel;

  const CommentCard(this.commentModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      padding: const EdgeInsets.all(4),
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
            InkWell(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Colors.black,
                  width: 1, // Underline thickness
                ))),
                child: GestureDetector(
                  onTap: () {
                    showGeneralDialog(
                      barrierLabel: "Label",
                      barrierDismissible: false,
                      barrierColor: Colors.black.withOpacity(0.5),
                      transitionDuration: const Duration(milliseconds: 400),
                      context: context,
                      pageBuilder: (context, anim1, anim2) {
                        return DismissibleCustom(Column(
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
                                '${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}${commentModel.comment}',
                                style: const TextStyle(fontSize: AppConst.kFontSize),
                              ),
                            ),
                          ],
                        ));
                      },
                      transitionBuilder: (context, anim1, anim2, child) {
                        return SlideTransition(
                          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
                          child: child,
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Xem thêm',
                    style: TextStyle(
                      fontSize: AppConst.kFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
