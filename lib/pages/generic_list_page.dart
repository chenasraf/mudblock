import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';

class GenericListPage<T> extends StatefulWidget with GameStoreMixin {
  const GenericListPage({
    super.key,
    required this.items,
    required this.title,
    required this.detailsPath,
    required this.save,
    required this.displayName,
    required this.searchTags,
    required this.itemBuilder,
    this.actions,
  });

  final List<T> items;
  final Widget title;
  final String detailsPath;
  final Future<void> Function(T updated) save;
  final Widget Function(BuildContext context, T item)
      itemBuilder;
  final String Function(T item) displayName;
  final List<String> Function(T item) searchTags;
  final List<Widget>? actions;

  @override
  State<GenericListPage<T>> createState() => _GenericListPageState<T>();
}

class _GenericListPageState<T> extends State<GenericListPage<T>>
    with GameStoreStateMixin {
  String _searchTerms = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        actions: widget.actions,
      ),
      body: GameStore.consumer(
        builder: (context, store, child) {
          final filteredItems = _search();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchTerms = value;
                    });
                  },
                ),
              ),
              ListView.builder(
                itemCount: filteredItems.length,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  final item = filteredItems[i];
                  return widget.itemBuilder(context, item);
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final item = await Navigator.pushNamed(context, widget.detailsPath);
          if (item != null) {
            await widget.save(item as T);
            setState(() {});
          }
        },
      ),
    );
  }

  List<T> _search() {
    return widget.items.where((item) {
      final tags = widget.searchTags(item);
      final displayName = widget.displayName(item).toLowerCase();
      return displayName.contains(_searchTerms.toLowerCase()) ||
          tags.any((tag) => tag.contains(_searchTerms.toLowerCase()));
    }).toList();
  }
}
