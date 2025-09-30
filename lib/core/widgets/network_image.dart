import 'package:waslny/core/exports.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'show_loading_indicator.dart';

// Amer
class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.image,
    this.isUser = false,
    this.height,
    this.width,
    this.fit,
    this.withLogo = false,
    this.borderRadius,
  });
  final String image;
  final bool isUser;

  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool withLogo;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: CachedNetworkImage(
          imageUrl: image,
          fit: fit ?? BoxFit.cover,
          height: height,
          width: width,
          placeholder: (context, url) => Center(
                child: CustomLoadingIndicator(
                  withLogo: withLogo,
                ),
              ),
          errorWidget: (context, url, error) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  isUser ? ImageAssets.userIcon : ImageAssets.appIcon,
                  height: height,
                  width: width,
                  fit: BoxFit.cover,
                ),
              )),
    );
  }
}
