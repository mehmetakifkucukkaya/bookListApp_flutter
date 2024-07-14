import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'
    as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/constants.dart';

//TODO: Emulatörde çekien fotoğraf liste kısmında gözüküyor ancak gerçek cihazda gözükmüyor. "image" değeri boş olarak gidiyor
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
  String image = '';
  int pageCount = 0;
  int rate = 0;

  Future<void> addBook(
    String bookName,
    String author,
    String genre,
    int pages,
    String language,
    int readingYear,
    int rate,
    String imageUrl,
  ) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference booksRef = firestore.collection('books');

    try {
      // Kitabın adını (bookName) kullanarak bir ID oluşturabiliriz
      String idFromTitle = bookName
          .toLowerCase()
          .replaceAll(' ', '_'); // Örnek bir ID oluşturma yöntemi

      // Firestore'da belgeyi eklerken bu ID'yi belirtiyoruz
      await booksRef.doc(idFromTitle).set({
        'bookName': bookName,
        'author': author,
        'genre': genre,
        'pages': pages,
        'language': language,
        'readingYear': readingYear,
        'rate': rate,
        'image': imageUrl,
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

    var book = bookdata['items'][0]['volumeInfo'];

    setState(() {
      bookTitle = book['title'];
      bookAuthor = book['authors'][0];
      pageCount = book['pageCount'];

      bookNameController.text = bookTitle;
      authorController.text = bookAuthor;
      pagesController.text = pageCount.toString();
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      await uploadImage(File(image.path));
    }
  }

  Future<void> uploadImage(File file) async {
    try {
      firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('images')
          .child('book_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(file);

      // Resim yüklendikten sonra URL'sini alıyoruz
      String downloadUrl = await ref.getDownloadURL();

      setState(() {
        image = downloadUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resim yükleme hatası: $e'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
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
              const SizedBox(height: 30),
              Center(
                child: RatingBar.builder(
                  initialRating: 3,
                  minRating: 0,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 30,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      rate = rating.toInt();
                    });
                  },
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _pickImage,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      iconSize: 30,
                    ),
                    const Text(
                      "Kitap Kapak Resmi Ekle",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                        rate.toInt(),
                        image,
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
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
