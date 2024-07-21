import 'package:book_list/firebase_options.dart';
import 'package:book_list/pages/book_list_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/add_book_page.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark),
        title: 'Book List App',
        routes: {
          '/': (context) => const HomePage(),
          'addBook': (context) => const AddBookPage(),
          '/bookListPage': (context) => const BookListPage(),
        });
  }
}
