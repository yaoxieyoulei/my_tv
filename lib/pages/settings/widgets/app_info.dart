import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:my_tv/common/index.dart';

class SettingsAppInfo extends StatelessWidget {
  SettingsAppInfo({super.key});

  final updateStore = GetIt.I<UpdateStore>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '我的电视',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 60.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 20.w),
            Observer(
              builder: (_) => Text(
                'v${updateStore.currentVersion}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Text(
          'https://github.com/yaoxieyoulei/my_tv',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
            fontSize: 30.sp,
          ),
        ),
      ],
    );
  }
}
