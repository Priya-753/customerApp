import 'package:flutter/material.dart';

class GridViewItem extends StatelessWidget {
  final String title;
  final String text;
  final Function? onTapCallBack;
  final Color? color;

  const GridViewItem(
      {Key? key,
        required this.title,
        required this.text,
        this.onTapCallBack,
        this.color
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(title,
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center),
          Text(text,
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class CardGridView extends StatelessWidget {
  final List<GridViewItem> gridViewItems;
  final ScrollController? controller;

  const CardGridView({Key? key, required this.gridViewItems, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 8.0,
        children: List.generate(gridViewItems.length, (index) {
          return GestureDetector(
            onTap: ()
            {
              gridViewItems[index].onTapCallBack!();
            },
            child: Card(
              color: gridViewItems[index].color ?? Colors.grey,
                child: gridViewItems[index]),
          );
    }));
  }
}
