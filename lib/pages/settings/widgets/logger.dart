import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_tv/common/index.dart';
import 'package:talker_flutter/talker_flutter.dart';

class SettingsLogger extends StatelessWidget {
  SettingsLogger({super.key});

  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Center(
        child: SizedBox(
          width: 0.6.sw,
          child: EasyKeyboardListener(
            autofocus: true,
            focusNode: _focusNode,
            onKeyTap: {
              LogicalKeyboardKey.arrowUp: () {
                _scrollController.animateTo(
                  _scrollController.offset - 0.8.sh,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              LogicalKeyboardKey.arrowDown: () {
                _scrollController.animateTo(
                  _scrollController.offset + 0.8.sh,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            },
            child: TalkerBuilder(
              talker: LoggerUtil.logger,
              builder: (context, data) {
                data = data.reversed.toList();

                return ListView.separated(
                  controller: _scrollController,
                  itemBuilder: (context, index) => TalkerDataCard(
                    data: data[index],
                    color: const TalkerScreenTheme().logColors[TalkerLogType.fromKey(data[index].key ?? '')] ??
                        Colors.grey,
                  ),
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemCount: data.length,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
