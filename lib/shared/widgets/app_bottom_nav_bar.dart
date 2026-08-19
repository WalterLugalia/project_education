import 'package:flutter/material.dart';
import 'package:project_education/core/config/theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  static const _labels = ['Home', 'Discover', 'Bookmarks', 'Downloads', 'Profile'];
  static const _icons = [
    Icons.home_outlined,
    Icons.explore_outlined,
    Icons.bookmark_border,
    Icons.download_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_labels.length, (index) {
            final isActive = index == currentIndex;
            final color = isActive ? AppColors.primaryColor : AppColors.textBodyColor;
            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icons[index], color: color, size: 22),
                  const SizedBox(height: 4),
                  Text(_labels[index], style: TextStyle(color: color, fontSize: 11)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}