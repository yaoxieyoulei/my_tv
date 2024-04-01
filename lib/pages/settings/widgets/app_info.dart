import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsAppInfo extends StatelessWidget {
  const SettingsAppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '我的电视',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 80.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'https://github.com/yaoxieyoulei/my_tv',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
            fontSize: 36.sp,
          ),
        ),
      ],
    );
  }
}
