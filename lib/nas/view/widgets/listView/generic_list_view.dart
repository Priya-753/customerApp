import 'package:flutter/material.dart';

class ListViewLineItem extends StatelessWidget {
  final String leftTop;
  final String? leftBottom;
  final String? rightTop;
  final String? rightBottom;
  final Icon? icon;
  final Function? onTapCallBack;
  final Color? backgroundColor;

  const ListViewLineItem(
      {Key? key,
      required this.leftTop,
      this.leftBottom,
      this.rightTop,
      this.rightBottom,
      this.icon,
      this.onTapCallBack,
      this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        color: backgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          children: [
            icon ?? Container(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(leftTop,
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.start),
                  leftBottom == null
                      ? const Text('')
                      : Text(leftBottom!,
                          style: Theme.of(context).textTheme.caption,
                          textAlign: TextAlign.start),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                rightTop == null
                    ? const Text('')
                    : Text(rightTop!,
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.start),
                rightBottom == null
                    ? const Text('')
                    : Text(rightBottom!,
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.start),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GenericListView extends StatelessWidget {
  final List<ListViewLineItem> listViewLineItems;
  final ScrollController? controller;

  const GenericListView({Key? key, required this.listViewLineItems, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        controller: controller,
        padding: const EdgeInsets.all(8),
        itemCount: listViewLineItems.length,
        itemBuilder: (BuildContext context, int index) {
          return listViewLineItems[index].onTapCallBack != null ? GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: ()
            {
              listViewLineItems[index].onTapCallBack!();
            },
            child: Container(color: Colors.white38, child: listViewLineItems[index]),
          ) : Container(child: listViewLineItems[index]);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider());
  }
}
