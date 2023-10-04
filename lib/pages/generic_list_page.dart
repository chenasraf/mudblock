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
  });

  final List<T> items;
  final Widget title;
  final String detailsPath;
  final Future<void> Function(GameStore store, T updated) save;
  final Widget Function(BuildContext context, GameStore store, T item)
      itemBuilder;
  final String Function(T item) displayName;
  final List<String> Function(T item) searchTags;

  @override
  State<GenericListPage<T>> createState() => _GenericListPageState<T>();
}

class _GenericListPageState<T> extends State<GenericListPage<T>>
    with GameStoreStateMixin {
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = [...widget.items];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
      ),
      body: GameStore.consumer(
        builder: (context, store, child) {
          debugPrint('Generic list rebuild');
          return Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search',
                ),
                onChanged: (value) {
                  _search(value);
                },
              ),
              ListView.builder(
                itemCount: _filteredItems.length,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  final item = _filteredItems[i];
                  return widget.itemBuilder(context, store, item);
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
            widget.save(store, item as T);
          }
        },
      ),
    );
  }

  void _search(String value) {
    setState(() {
      _filteredItems = widget.items.where((item) {
        final tags = widget.searchTags(item);
        final displayName = widget.displayName(item);
        return displayName.contains(value) ||
            tags.any((tag) => tag.contains(value));
      }).toList();
    });
  }
}

