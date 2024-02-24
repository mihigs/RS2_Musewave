import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search',
          hintText: 'Enter search term',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        onChanged: (value) {
          // Perform the search operation
        },
      ),
    );
  }
}
