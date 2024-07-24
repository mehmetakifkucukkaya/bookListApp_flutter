import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../constants/constants.dart';
import '../widgets/booklist_card.dart';
import 'book_detail_page.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  List<DocumentSnapshot> books = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Filtreleme için kullanılacak değişkenler
  String? filterGenre;
  int? filterReadingYear;

  final genres = BookVariables().genres;

  final years = BookVariables().years;

  void _deleteBook(String bookId, String bookName, int index) {
    FirebaseFirestore.instance
        .collection('books')
        .doc(bookId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$bookName silindi'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silme işlemi sırasında bir hata oluştu: $error'),
        ),
      );
    });
  }

  void _updateBook(String bookId, Map<String, dynamic> book, int index) {
    _showUpdateDialog(bookId, book, index);
  }

  void _showFilterDialog() {
    String? selectedGenre;
    int? selectedYear;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtreleme Seçenekleri'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Tür'),
                  value: selectedGenre,
                  items: genres.map((String genre) {
                    return DropdownMenuItem<String>(
                      value: genre,
                      child: Text(genre),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedGenre = newValue;
                    });
                  },
                ),
                DropdownButtonFormField<int>(
                  decoration:
                      const InputDecoration(labelText: 'Okuma Yılı'),
                  value: selectedYear,
                  items: years.map((int year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedYear = newValue;
                    });
                  },
                ),
              ],
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
                setState(() {
                  searchQuery = '';
                  filterGenre = selectedGenre?.toLowerCase();
                  filterReadingYear = selectedYear;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Filtrele'),
            ),
          ],
        );
      },
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
    final TextEditingController summaryController =
        TextEditingController(text: book['summary'] ?? '');
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
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tür'),
                    value: genreController.text,
                    items: genres.map((String genre) {
                      return DropdownMenuItem<String>(
                        value: genre,
                        child: Text(genre),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      genreController.text = newValue!;
                    },
                  ),
                  _buildTextField(authorController, 'Yazar'),
                  _buildNumberField(pagesController, 'Sayfa Sayısı'),
                  _buildRatingBar(rate, (newRate) {
                    setState(() {
                      rate = newRate;
                    });
                  }),
                  DropdownButtonFormField<int>(
                    decoration:
                        const InputDecoration(labelText: 'Okuma Yılı'),
                    value: int.tryParse(readingYearController.text),
                    items: years.map((int year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      readingYearController.text = newValue.toString();
                    },
                  ),
                  _buildTextField(languageController, 'Dil'),
                  _buildTextField(summaryController, 'Özet'),
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
                    'summary': summaryController.text,
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

  void _resetFilters() {
    setState(() {
      searchQuery = '';
      filterGenre = null;
      filterReadingYear = null;
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      elevation: const WidgetStatePropertyAll(5),
                      hintText: "Kitap ara",
                      leading: const Icon(Icons.search),
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                          filterGenre =
                              null; // Arama yapılırken tür filtresini sıfırla
                          filterReadingYear =
                              null; // Arama yapılırken yıl filtresini sıfırla
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterDialog,
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed:
                        _resetFilters, // Filtreleri sıfırlamak için düğme
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
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
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
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
                    String genre = book['genre'].toLowerCase();
                    int readingYear = book['readingYear'] ?? 0;

                    bool matchesSearchQuery =
                        bookName.contains(searchQuery) ||
                            author.contains(searchQuery);
                    bool matchesGenreFilter = filterGenre == null ||
                        filterGenre!.isEmpty ||
                        genre.contains(filterGenre!);
                    bool matchesReadingYearFilter =
                        filterReadingYear == null ||
                            filterReadingYear == readingYear;

                    return matchesSearchQuery &&
                        matchesGenreFilter &&
                        matchesReadingYearFilter;
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final bookDoc = filteredBooks[index];
                      final book = bookDoc.data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailPage(
                                books: filteredBooks,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Kitabı Sil"),
                                    content: Text(
                                        "${book['bookName']} kitabını silmek istediğinize emin misiniz?"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text("İptal"),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Sil"),
                                        onPressed: () {
                                          _deleteBook(bookDoc.id,
                                              book['bookName'], index);
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              _updateBook(bookDoc.id, book, index);
                              return false; // Silme işlemi yapılmasın
                            }
                            return false;
                          },
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.edit,
                                color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete,
                                color: Colors.white),
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
