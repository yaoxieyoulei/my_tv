import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:my_tv/common/index.dart';

class PanelIptvList extends StatefulWidget {
  const PanelIptvList({super.key});

  @override
  State<PanelIptvList> createState() => _PanelIptvListState();
}

class _PanelIptvListState extends State<PanelIptvList> {
  final iptvStore = GetIt.I<IptvStore>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240.h,
      child: Observer(builder: (context) {
        return TwoDimensionListView(
          initialPosition: (row: iptvStore.currentIptv.groupIdx, col: iptvStore.currentIptv.idx),
          size: (rowHeight: 120.h, colWidth: 260.w),
          scrollOffset: (row: 0, col: -1),
          gap: (row: 20.h, col: 20.w),
          itemCount: (
            row: iptvStore.iptvGroupList.length,
            col: (row) => iptvStore.iptvGroupList[row].list.length,
          ),
          rowTopBuilder: (context, row) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              iptvStore.iptvGroupList[row].name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onSelect: (position) {
            iptvStore.currentIptv = iptvStore.iptvGroupList[position.row].list[position.col];
            Navigator.pop(context);
          },
          itemBuilder: (context, position, isSelected) {
            final iptv = iptvStore.iptvGroupList[position.row].list[position.col];

            return _buildIptvItem(iptv, isSelected);
          },
        );
      }),
    );
  }

  Widget _buildIptvItem(Iptv iptv, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).r,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.onBackground
            : Theme.of(context).colorScheme.background.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20).r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            iptv.name,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.background : Theme.of(context).colorScheme.onBackground,
              fontSize: 30.sp,
            ),
            maxLines: 1,
          ),
          Observer(
            builder: (_) => Text(
              iptvStore.getIptvProgrammes(iptv).current,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.background.withOpacity(0.8)
                    : Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                fontSize: 24.sp,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
