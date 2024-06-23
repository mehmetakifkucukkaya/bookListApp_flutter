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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey,
        elevation: 2,
        iconSize: 28,
        //* selected item
        selectedIconTheme: const IconThemeData(size: 40),
        selectedItemColor: Colors.blueGrey,
        selectedFontSize: 16,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        //* unselected item
        unselectedIconTheme: const IconThemeData(color: Colors.white),
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Listelerim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Kitaplar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
