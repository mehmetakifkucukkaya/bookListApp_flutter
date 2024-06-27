import 'package:book_list/constants/constants.dart';
import 'package:flutter/material.dart';

import '../widgets/booklist_card.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Okuma Listesi"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: MyColors.buttonColor,
                    foregroundColor: Colors.grey[800],
                  ),
                  child: const Icon(Icons.search),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: MyColors.buttonColor,
                      foregroundColor: Colors.grey[900]),
                  child: const Text('Kitap Ekle'),
                ),
              ],
            ),
            const Divider(),
            //* KİTAP LİSTESİ
            const BookListCard(),
          ], 
        ),
      ),
    );
  }
}
