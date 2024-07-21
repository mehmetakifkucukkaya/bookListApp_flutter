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
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

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

  void _updateBook(String bookId, Map<String, dynamic> book, int index) {
    _showUpdateDialog(bookId, book, index);
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
    double rate = book['rate']?.toDouble() ?? 0;

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
                  _buildTextField(bookNameController, 'Kitap Adı'),
                  _buildTextField(genreController, 'Tür'),
                  _buildTextField(authorController, 'Yazar'),
                  _buildNumberField(pagesController, 'Sayfa Sayısı'),
                  _buildRatingBar(rate, (newRate) {
                    setState(() {
                      rate = newRate;
                    });
                  }),
                  _buildNumberField(readingYearController, 'Okuma Yılı'),
                  _buildTextField(languageController, 'Dil'),
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
                    'rate': rate.toInt(),
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

  TextFormField _buildTextField(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen $labelText girin';
        }
        return null;
      },
    );
  }

  TextFormField _buildNumberField(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen $labelText girin';
        }
        if (int.tryParse(value) == null) {
          return 'Lütfen geçerli bir sayı girin';
        }
        return null;
      },
    );
  }

  Center _buildRatingBar(double rate, Function(double) onRatingUpdate) {
    return Center(
      child: RatingBar.builder(
        initialRating: rate,
        minRating: 0,
        direction: Axis.horizontal,
        itemCount: 5,
        itemSize: 30,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: onRatingUpdate,
      ),
    );
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
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Kitap Ara',
                      prefixIconColor: MyColors.buttonColor,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
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
                      foregroundColor: Colors.grey[900],
                    ),
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
                  return const Center(child: Text("Kitap yok"));
                }

                books = snapshot.data!.docs;

                // Filtreleme işlemi
                List<DocumentSnapshot> filteredBooks =
                    books.where((bookDoc) {
                  Map<String, dynamic> book =
                      bookDoc.data() as Map<String, dynamic>;
                  String bookName = book['bookName'].toLowerCase();
                  String author = book['author'].toLowerCase();
                  return bookName.contains(searchQuery) ||
                      author.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final bookDoc = filteredBooks[index];
                    final book = bookDoc.data() as Map<String, dynamic>;

                    return Dismissible(
                      key: UniqueKey(),
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
