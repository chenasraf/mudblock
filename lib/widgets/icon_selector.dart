import 'package:flutter/material.dart';

import '../core/icon_list.g.dart';

class IconSelector extends StatelessWidget {
  const IconSelector({
    super.key,
    this.search = '',
    required this.onSelected,
  });

  final ValueChanged<IconData> onSelected;
  final String search;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 6,
      children: iconList.entries
          .where(_filterIcons)
          .map((e) => _buildIcon(context, e))
          .toList(),
    );
  }

  Widget _buildIcon(BuildContext context, MapEntry<String, IconData> e) {
    return InkWell(
      onTap: () => onSelected(e.value),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(e.value),
          Text(e.key),
        ],
      ),
    );
  }

  bool _filterIcons(MapEntry<String, IconData> element) {
    var key = element.key.toLowerCase();
    // if (key.contains('_sharp') || key.contains('_outline') || key.contains('_rounded')) {
    //   // key = key.replaceAll('_sharp', '').replaceAll('_outline', '');
    //   return false;
    // }
    return search.isEmpty || key.contains(search.toLowerCase());
  }
}

