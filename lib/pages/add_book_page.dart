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

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController bookNameController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController pagesController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController readingYearController =
      TextEditingController();

  String selectedGenre = BookVariables().genres[0];
  String languageDropdownValue = BookVariables().languages[0];
  String isbn = '';
  String imageUrl = '';
  int rate = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitap Ekle'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                  bookNameController, 'Kitap Adı', 'Kitabın adını girin'),
              const SizedBox(height: 20),
              _buildTextField(
                  authorController, 'Yazar', 'Kitabın yazarını girin'),
              const SizedBox(height: 20),
              _buildDropdown(),
              const SizedBox(height: 20),
              _buildTextField(
                pagesController,
                'Sayfa Sayısı',
                'Kitabın sayfa sayısını girin',
                isNumber: true,
              ),
              const SizedBox(height: 20),
              _buildLanguageDropdown(),
              const SizedBox(height: 20),
              _buildTextField(
                readingYearController,
                'Okuduğum Yıl',
                'Kitabı okuduğunuz yılı girin',
                isNumber: true,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                  summaryController, 'Özet', 'Kitap özetini girin'),
              const SizedBox(height: 30),
              _buildRatingBar(),
              const SizedBox(height: 15),
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(
      TextEditingController controller, String label, String hint,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly] // Sadece rakamlar
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label boş bırakılamaz';
        }
        if (isNumber && int.tryParse(value) == null) {
          return 'Geçerli bir sayı girin';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<String> _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGenre,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedGenre = newValue;
          });
        }
      },
      items: BookVariables()
          .genres
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: const InputDecoration(labelText: 'Tür'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Tür seçimi yapılmalıdır';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<String> _buildLanguageDropdown() {
    return DropdownButtonFormField<String>(
      value: languageDropdownValue,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            languageDropdownValue = newValue;
          });
        }
      },
      items: BookVariables()
          .languages
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: const InputDecoration(labelText: 'Dil'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Dil seçimi yapılmalıdır';
        }
        return null;
      },
    );
  }

  Center _buildRatingBar() {
    return Center(
      child: RatingBar.builder(
        initialRating: 3,
        minRating: 0,
        direction: Axis.horizontal,
        itemCount: 5,
        itemSize: 30,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) =>
            const Icon(Icons.star, color: Colors.amber),
        onRatingUpdate: (rating) {
          setState(() {
            rate = rating.toInt();
          });
        },
      ),
    );
  }

  GestureDetector _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Row(
        children: [
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            iconSize: 30,
          ),
          const Text("Kitap Kapak Resmi Ekle",
              style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Row _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              addBook();
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: MyColors.buttonColor,
            foregroundColor: Colors.grey[900],
          ),
          child: const Text('Kaydet',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: scanBarcode,
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: MyColors.buttonColor,
            foregroundColor: Colors.grey[900],
          ),
          child: const Text("ISBN Okut",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ],
    );
  }

  Future<void> addBook() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String idFromTitle =
          bookNameController.text.toLowerCase().replaceAll(' ', '_');

      await firestore.collection('books').doc(idFromTitle).set({
        'bookName': bookNameController.text,
        'author': authorController.text,
        'genre': selectedGenre,
        'pages': int.tryParse(pagesController.text) ?? 0,
        'language': languageDropdownValue,
        'readingYear': int.tryParse(readingYearController.text) ?? 0,
        'rate': rate,
        'image': imageUrl,
        'summary': summaryController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kitap başarıyla eklendi.'),
            duration: Duration(seconds: 2)),
      );

      Navigator.pushNamed(context, '/bookListPage');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Kitap eklenirken hata oluştu: $e'),
            duration: const Duration(seconds: 2)),
      );
    }
  }

  Future<void> scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Geri Dön', true, ScanMode.BARCODE);
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

  Future<void> getBookDataWithISBN() async {
    await dotenv.load(fileName: ".env");
    var apiKey = dotenv.env['BOOKS_API_KEY'];
    Dio dio = Dio();

    Response response = await dio.get(
        "https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&printType=books&key=$apiKey");
    var book = response.data['items'][0]['volumeInfo'];

    setState(() {
      bookNameController.text = book['title'];
      authorController.text = book['authors'][0];
      pagesController.text = book['pageCount'].toString();
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
      String downloadUrl = await ref.getDownloadURL();

      setState(() {
        imageUrl = downloadUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Resim yükleme hatası: $e'),
            duration: const Duration(seconds: 1)),
      );
    }
  }
}
