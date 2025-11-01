import 'dart:io';

import '../exports.dart';

class CustomLoadingIndicator extends StatefulWidget {
  const CustomLoadingIndicator({super.key, this.withLogo = true, this.color});
  final bool withLogo;
  final Color? color;

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.withLogo
        ? Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _controller,
                child: Image.asset(
                  ImageAssets.loaderIcon,
                  height: 50.h,
                  width: 50.h,
                  color: widget.color,
                ),
              ),
              /*Platform.isIOS
                  ? SizedBox(
                      height: 55.h,
                      width: 55.h,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    )
                  : SizedBox(
                      height: 55.h,
                      width: 55.h,
                      child: CircularProgressIndicator(
                        color: AppColors.secondPrimary,
                        strokeWidth: 3,
                      ),
                    ),
              */
              // Image.asset(
              //   ImageAssets.loaderIcon,
              //   height: 50.h,
              //   width: 50.h,
              // ),
            ],
          )
        : Platform.isIOS
        ? CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)
        : CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3);
  }
}
