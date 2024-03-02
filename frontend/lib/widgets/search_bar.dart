import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  var onTap;
  var onSubmitted;

  SearchBarWidget({Key? key, var onTap, FocusNode? focusNode, var onSubmitted})
      : focusNode = focusNode ?? FocusNode(),
        onTap = onTap ?? (() {}),
        onSubmitted = onSubmitted ?? ((_) {}),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _searchController,
      focusNode: focusNode,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: 'Search for music, artists, playlists...',
        // hintText: 'Search for music, artists, playlists...',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => _searchController.clear(),
        ),
      ),
    );
  }
}
