import 'package:waslny/core/exports.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarouselWithLineIndicator extends StatefulWidget {
  @override
  State<CarouselWithLineIndicator> createState() =>
      _CarouselWithLineIndicatorState();
}

class _CarouselWithLineIndicatorState extends State<CarouselWithLineIndicator> {
  int _current = 0;

  final List<Map<String, String>> items = [
    {'title': 'slider_title_1'.tr(), 'description': 'slider_desc_1'.tr()},
    {'title': 'slider_title_2'.tr(), 'description': 'slider_desc_2'.tr()},
    {'title': 'slider_title_3'.tr(), 'description': 'slider_desc_3'.tr()},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: items.length,
          itemBuilder: (context, index, realIdx) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        item['title'] ?? '',
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            color: AppColors.white,
                            fontSize: 20.sp,
                            fontFamily: AppStrings.fontFamily),
                      ),
                    ),
                    AutoSizeText(
                      item['description'] ?? '',
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          fontSize: 20.sp,
                          fontFamily: AppStrings.fontFamily),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: getHeightSize(context) / 5.5,
            viewportFraction: 1.0,
            autoPlay: true,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 4,
              width: 20.w,
              decoration: BoxDecoration(
                color: _current == index ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }
}
