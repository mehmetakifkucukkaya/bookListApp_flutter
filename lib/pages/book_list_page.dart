import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../constants/constants.dart';
import '../widgets/booklist_card.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  List<DocumentSnapshot> books = [];

  void _deleteBook(String bookId, String bookName, int index) {
    setState(() {
      books.removeAt(index);
    });

    FirebaseFirestore.instance.collection('books').doc(bookId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$bookName silindi'),
      ),
    );
  }

  void _showUpdateDialog(
      String bookId, Map<String, dynamic> book, int index) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController bookNameController =
        TextEditingController(text: book['bookName']);
    final TextEditingController genreController =
        TextEditingController(text: book['genre']);
    final TextEditingController authorController =
        TextEditingController(text: book['author']);
    final TextEditingController pagesController =
        TextEditingController(text: book['pages'].toString());
    final TextEditingController readingYearController =
        TextEditingController(text: book['readingYear'].toString());
    final TextEditingController languageController =
        TextEditingController(text: book['language']);
    double rate =
        book['rate']?.toDouble() ?? 0; // Rating için bir değişken

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kitap Güncelle'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: bookNameController,
                    decoration:
                        const InputDecoration(labelText: 'Kitap Adı'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen kitap adını girin';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: genreController,
                    decoration: const InputDecoration(labelText: 'Tür'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen türü girin';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: authorController,
                    decoration: const InputDecoration(labelText: 'Yazar'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen yazarı girin';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: pagesController,
                    decoration:
                        const InputDecoration(labelText: 'Sayfa Sayısı'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen sayfa sayısını girin';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Lütfen geçerli bir sayı girin';
                      }
                      return null;
                    },
                  ),
                  // RatingBar ekleniyor
                  Center(
                    child: RatingBar.builder(
                      initialRating: rate,
                      minRating: 0,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemSize: 30,
                      itemPadding:
                          const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (newRate) {
                        setState(() {
                          rate = newRate;
                        });
                      },
                    ),
                  ),
                  TextFormField(
                    controller: readingYearController,
                    decoration:
                        const InputDecoration(labelText: 'Okuma Yılı'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen okuma yılını girin';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Lütfen geçerli bir yıl girin';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: languageController,
                    decoration: const InputDecoration(labelText: 'Dil'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen dili girin';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  FirebaseFirestore.instance
                      .collection('books')
                      .doc(bookId)
                      .update({
                    'bookName': bookNameController.text,
                    'genre': genreController.text,
                    'author': authorController.text,
                    'pages': int.parse(pagesController.text),
                    'rate': rate.toInt(), // Güncellenmiş rate kullanılıyor
                    'readingYear': int.parse(readingYearController.text),
                    'language': languageController.text,
                  }).then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kitap güncellendi')),
                    );
                  });
                }
              },
              child: const Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  void _updateBook(String bookId, Map<String, dynamic> book, int index) {
    _showUpdateDialog(bookId, book, index);
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

          //*  KİTAP LİSTESİ

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

                books = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final bookDoc = books[index];
                    final book = bookDoc.data() as Map<String, dynamic>;

                    return Dismissible(
                      key: Key(bookDoc.id),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          _deleteBook(bookDoc.id, book['bookName'], index);
                        } else if (direction ==
                            DismissDirection.startToEnd) {
                          _updateBook(bookDoc.id, book, index);
                        }
                      },
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child:
                            const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: BookListCard(
                        bookName: book['bookName'] ?? 'Unknown',
                        genre: book['genre'] ?? 'Unknown',
                        author: book['author'] ?? 'Unknown',
                        pages: book['pages'] ?? 0,
                        image: book['image'] ?? '',
                        rate: book['rate'] ?? 4,
                        readingYear: book['readingYear'] ?? 0,
                        language: book['language'] ?? 'Unknown',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
