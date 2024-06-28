import 'package:cloud_firestore/cloud_firestore.dart'; // Correct import for Firebase Firestore
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../widgets/booklist_card.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  List<Map<String, dynamic>> books = [];

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  void fetchBooks() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference booksRef = firestore.collection('books');

    QuerySnapshot snapshot = await booksRef.get();
    setState(() {
      books = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

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
                    onPressed: () {},
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
            child: ListView.builder(
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
            ),
          )
        ],
      ),
    );
  }
}
