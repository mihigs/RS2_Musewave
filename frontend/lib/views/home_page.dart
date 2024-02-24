import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
   Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(10, 35, 10, 0), // left, top, right, bottom
            child: SearchBar(
              key: null,
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // number of items in a row
              ),
              itemCount: 20, // Replace with your actual item count
              itemBuilder: (context, index) {
                return Card( // wrapping each item in a Card for better visual separation
                  child: Center(
                    child: Text('Item ${index + 1}'), // Replace with your actual data
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationMenu(),
    );
  }
}
