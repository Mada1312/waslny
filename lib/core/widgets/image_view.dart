import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:photo_view/photo_view.dart';

import '../../../core/utils/app_colors.dart';
import '../utils/assets_manager.dart';

class ImageViewScreen extends StatelessWidget {
  const ImageViewScreen(
      {required this.image,
      this.isAsset = false,
      this.isFile = false,
      super.key});
  final String? image;
  final bool? isAsset;
  final bool? isFile;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: const Key('New Key'),
        direction: DismissDirection.down,
        onDismissed: (_) => Navigator.pop(context),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (result == RoutePopDisposition.doNotPop) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
              appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.primary,
                        )),
                  ]),
              body: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                child: (isFile == true && image != null)
                    ? PhotoView(
                        imageProvider: FileImage(File(image!)),
                        backgroundDecoration: const BoxDecoration(),
                        // enableRotation: true,
                        minScale: PhotoViewComputedScale.contained * 0.8,
                        maxScale: PhotoViewComputedScale.covered * 1.8,
                        initialScale: PhotoViewComputedScale.contained,
                        basePosition: Alignment.center,
                      )
                    : (image == null || (isAsset == true))
                        ? PhotoView(
                            imageProvider: const AssetImage(ImageAssets.logo),
                            backgroundDecoration: const BoxDecoration(),
                            // enableRotation: true,
                            minScale: PhotoViewComputedScale.contained * 0.8,
                            maxScale: PhotoViewComputedScale.covered * 1.8,
                            initialScale: PhotoViewComputedScale.contained,
                            basePosition: Alignment.center,
                          )
                        : PhotoView(
                            imageProvider: NetworkImage(image!),
                            backgroundDecoration: const BoxDecoration(),
                            // enableRotation: true,
                            minScale: PhotoViewComputedScale.contained * 0.8,
                            maxScale: PhotoViewComputedScale.covered * 1.8,
                            initialScale: PhotoViewComputedScale.contained,
                            basePosition: Alignment.center,
                          ),
              )),
        ));
  }
}
