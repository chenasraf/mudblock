import 'package:flutter/material.dart';

import '../core/icon_list.g.dart';
import '../core/platform_utils.dart';

enum IconSelectorDisplay { grid, list }

class IconSelector extends StatelessWidget {
  const IconSelector({
    super.key,
    this.search = '',
    required this.onSelected,
    this.selectedIcon,
    this.display = IconSelectorDisplay.grid,
  });

  final void Function(IconData data, String name) onSelected;
  final String search;
  final IconSelectorDisplay display;
  final IconData? selectedIcon;

  @override
  Widget build(BuildContext context) {
    final sorted = iconList.entries.where(_filterIcons).toList();
    sorted.sort((a, b) => a.key.compareTo(b.key));
    return _buildContainer(
      context,
      display: display,
      children: sorted,
      builder:
          display == IconSelectorDisplay.grid ? _buildGridItem : _buildListItem,
    );
  }

  static Widget _buildContainer(
    BuildContext context, {
    required List<MapEntry<String, IconData>> children,
    required Widget Function(BuildContext context, MapEntry<String, IconData> e)
        builder,
    IconSelectorDisplay display = IconSelectorDisplay.grid,
  }) {
    final list = children.map((e) => builder(context, e)).toList();
    switch (display) {
      case IconSelectorDisplay.grid:
        return GridView.count(
          crossAxisCount: PlatformUtils.isDesktop ? 6 : 4,
          children: list,
        );
      case IconSelectorDisplay.list:
        return ListView(
          children: list,
        );
    }
  }

  Widget _buildListItem(BuildContext context, MapEntry<String, IconData> e) {
    return ListTile(
      leading: Icon(e.value),
      title: Text(e.key, overflow: TextOverflow.ellipsis),
      subtitle: Text(e.key),
      selected: selectedIcon != null && selectedIcon == e.value,
      onTap: () => onSelected(e.value, e.key),
    );
  }

  Widget _buildGridItem(BuildContext context, MapEntry<String, IconData> e) {
    final radius = BorderRadius.circular(16);
    return InkWell(
      onTap: () => onSelected(e.value, e.key),
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: selectedIcon != null && selectedIcon == e.value
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
        ),
        child: Tooltip(
          message: e.key,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(e.value),
                  Text(e.key,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _filterIcons(MapEntry<String, IconData> element) {
    var key = element.key.toLowerCase();
    // if (key.contains('_sharp') || key.contains('_outline') || key.contains('_rounded')) {
    //   // key = key.replaceAll('_sharp', '').replaceAll('_outline', '');
    //   return false;
    // }
    return search.isEmpty ||
        _cleanString(key).contains(_cleanString(search.toLowerCase()));
  }

  String _cleanString(String s) {
    return s.replaceAll('_', '').replaceAll('-', '');
  }
}

