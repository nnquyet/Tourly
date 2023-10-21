import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tourly/common/app_constants.dart';

class AppImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double circular;

  const AppImage(this.url, this.width, this.height, {super.key, this.circular = 0});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      width: width,
      height: height,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(circular)),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => const CupertinoActivityIndicator(),
      errorWidget: (context, url, error) => AppImage(
        AppConst.defaultUrlAddress,
        width,
        height,
        circular: width * 0.04,
      ),
      imageUrl: url,
    );
  }
}
