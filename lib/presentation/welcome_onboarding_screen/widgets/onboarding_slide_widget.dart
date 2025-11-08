import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingSlideWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String semanticLabel;

  const OnboardingSlideWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Section
          Container(
            width: 70.w,
            height: 35.h,
            margin: EdgeInsets.only(bottom: 4.h),
            child: CustomImageWidget(
  fit: BoxFit.contain,
  height: 35.h,
  imageUrl: imageUrl,
  semanticLabel: semanticLabel,
  width: 35.w,
),
          ),

          // Title Section
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.textDark,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 2.h),

          // Description Section
          Text(
            description,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.neutralGray,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
