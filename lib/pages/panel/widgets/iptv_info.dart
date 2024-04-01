import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:my_tv/common/index.dart';

class PanelIPTVInfo extends StatelessWidget {
  PanelIPTVInfo({super.key});

  final iptvStore = GetIt.I<IPTVStore>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          iptvStore.currentIPTV.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 80.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '正在播放：无节目',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
            fontSize: 36.sp,
          ),
        ),
      ],
    );
  }
}
