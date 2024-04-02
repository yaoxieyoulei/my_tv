import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_tv/common/index.dart';
import 'package:my_tv/pages/settings/widgets/app_info.dart';
import 'package:my_tv/pages/settings/widgets/settings.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final playerStore = GetIt.I<PlayerStore>();
  final iptvStore = GetIt.I<IPTVStore>();

  @override
  void initState() {
    super.initState();

    HttpServerUtil.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.5),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(40).r,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingsAppInfo(),
                        SizedBox(height: 40.h),
                        const SettingsMain(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
