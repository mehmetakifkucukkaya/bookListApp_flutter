import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  static const List<Widget> pages = <Widget>[
    Icon(Icons.list_alt, size: 150),
    Icon(Icons.menu_book, size: 150),
    Icon(Icons.person, size: 150),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Book List App')),
      ),
      body: Center(child: pages.elementAt(selectedIndex)),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.grey,
        style: TabStyle.titled,
        items: const <TabItem>[
          TabItem(icon: Icons.list_alt, title: 'Listelerim'),
          TabItem(icon: Icons.menu_book, title: 'Kitaplar'),
          TabItem(icon: Icons.person, title: 'Profil'),
        ],
        initialActiveIndex: selectedIndex, //optional, default as 0
        onTap: onItemTapped,
      ),
    );
  }
}
