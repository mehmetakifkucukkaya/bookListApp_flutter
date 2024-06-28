import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../widgets/booklist_card.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Okuma Listesi"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: MyColors.buttonColor,
                      foregroundColor: Colors.grey[800],
                    ),
                    child: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "addBook");
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: MyColors.buttonColor,
                        foregroundColor: Colors.grey[900]),
                    child: const Text('Kitap Ekle'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No books available"));
                }

                final books = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return BookListCard(
                      bookName: book['bookName'] ?? 'Unknown',
                      genre: book['genre'] ?? 'Unknown',
                      author: book['author'] ?? 'Unknown',
                      pages: book['pages'] ?? 0,
                      image: book['image'] ?? '',
                      rate: book['rate'] ?? 4,
                      readingYear: book['readingYear'] ?? 0,
                      language: book['language'] ?? 'Unknown',
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
