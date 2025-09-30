import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MySvgWidget extends StatelessWidget {
  const MySvgWidget(
      {super.key,
      required this.path,
      this.imageColor,
      this.height,
      this.width});

  final String path;
  final Color? imageColor;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: imageColor == null
          ? SvgPicture.asset(path)
          : SvgPicture.asset(
              path,
              colorFilter: ColorFilter.mode(imageColor!, BlendMode.srcIn),
            ),
    );
  }
}
