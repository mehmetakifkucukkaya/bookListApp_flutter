import 'package:dio/dio.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/constants.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final TextEditingController bookNameController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController pagesController = TextEditingController();
  final TextEditingController readingYearController =
      TextEditingController();

  String languageDropdownValue = 'Türkçe';

  String isbn = '';
  String bookTitle = '';
  String bookAuthor = '';
  int pageCount = 0;

  void addBook(String bookName, String author, String genre, int pages,
      String language, int readingYear) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference booksRef = firestore.collection('books');

    try {
      await booksRef.add({
        'bookName': bookName,
        'author': author,
        'genre': genre,
        'pages': pages,
        'language': language,
        'readingYear': readingYear,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kitap başarıyla eklendi.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kitap eklenirken hata oluştu: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ISBN ile Barkod Okuma
  Future<void> scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Geri Dön', true, ScanMode.BARCODE);
      debugPrint(barcodeScanRes);
      setState(() {
        isbn = barcodeScanRes;
      });

      getBookDataWithISBN();
    } on PlatformException catch (e) {
      setState(() {
        isbn = 'Barkod okuma işlemi başarısız oldu: $e';
      });
    }
  }

  void getBookDataWithISBN() async {
    await dotenv.load(fileName: ".env");
    var apiKey = dotenv.env['BOOKS_API_KEY'];
    Dio dio = Dio();

    Response response = await dio.get(
        "https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&printType=books&key=$apiKey");
    var bookdata = response.data;

    print(bookdata);

    var book = bookdata['items'][0]['volumeInfo'];

    setState(() {
      bookTitle = book['title'];
      bookAuthor = book['authors'][0];
      pageCount = book['pageCount'];

      //* Eğer ISBN ile kitap bilgileri alınmışsa, bu bilgileri textfieldara yazdırıyoruz

      bookNameController.text = bookTitle;
      authorController.text = bookAuthor;
      pagesController.text = pageCount.toString();
    });

    print("Kitap Adı: $bookTitle");
    print("Yazar: $bookAuthor");
    print("Sayfa Sayısı: $pageCount");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitap Ekle'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: bookNameController,
                decoration: const InputDecoration(
                  labelText: 'Kitap Adı',
                  hintText: 'Kitabın adını girin',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: 'Yazar',
                  hintText: 'Kitabın yazarını girin',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: genreController,
                decoration: const InputDecoration(
                  labelText: 'Tür',
                  hintText: 'Kitabın türünü girin',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: pagesController,
                decoration: const InputDecoration(
                  labelText: 'Sayfa Sayısı',
                  hintText: 'Kitabın sayfa sayısını girin',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: languageDropdownValue,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      languageDropdownValue = newValue;
                    });
                  }
                },
                items: <String>['Türkçe', 'İngilizce']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Dil',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: readingYearController,
                decoration: const InputDecoration(
                  labelText: 'Okuduğum Yıl',
                  hintText: 'Kitabı okuduğunuz yılı girin',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      addBook(
                        bookNameController.text,
                        authorController.text,
                        genreController.text,
                        int.tryParse(pagesController.text) ?? 0,
                        languageDropdownValue,
                        int.tryParse(readingYearController.text) ?? 0,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: MyColors.buttonColor,
                      foregroundColor: Colors.grey[900],
                    ),
                    child: const Text(
                      'Kaydet',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: scanBarcode,
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: MyColors.buttonColor,
                      foregroundColor: Colors.grey[900],
                    ),
                    child: const Text(
                      "ISBN Okut",
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  Text("Result: $isbn\n")
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
