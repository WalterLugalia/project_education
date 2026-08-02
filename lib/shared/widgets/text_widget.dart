import 'package:flutter/material.dart';
import 'package:project_education/core/config/theme/app_colors.dart';

Widget textHeadingWidget({
  required String text,
  TextAlign? textAlign,
}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 30,
      color: AppColors.textPrimaryColor,
      fontWeight: FontWeight.bold,
    ),
    textAlign: textAlign ?? TextAlign.start,
  );
}


Widget textSubHeadingWidget({
  required String text,
  TextAlign? textAlign,
}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 14,
      color: AppColors.textBodyColor,
      fontWeight: FontWeight.w500,
    ),
    textAlign: textAlign ?? TextAlign.start,
  );
}