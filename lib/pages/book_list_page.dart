import 'package:flutter/material.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      backgroundColor: Colors.orange[400],
                      foregroundColor: Colors.grey[700]),
                  child: const Icon(Icons.search),
                ),
                const Text(
                  "Okuduğum Kitaplar",
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Colors.orange[400],
                      foregroundColor: Colors.grey[700]),
                  child: const Text('Kitap Ekle'),
                ),
              ],
            ),
            const Divider()
            //* KİTAP LİSTESİ

          ],
        ),
      ),
    );
  }
}
