import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/constants.dart';

class BookDetailPage extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        title: Text(book['bookName']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (book['image'] != null && book['image'].isNotEmpty)
                Center(
                  child: FadeIn(
                    duration: const Duration(seconds: 1),
                    child: Image.network(
                      book['image'],
                      height: 200,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 200,
                            height: 200,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              //* Kitap Bilgileri
              Center(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    '${book['bookName']}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Center(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    '${book['genre']}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Center(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: Text(
                    '${book['author']}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHighlightedText('${book['language']}',
                      duration: const Duration(milliseconds: 800)),
                  _buildHighlightedText('${book['readingYear']}',
                      duration: const Duration(milliseconds: 900)),
                  _buildHighlightedText('${book['pages']} Sayfa',
                      duration: const Duration(milliseconds: 1000)),
                ],
              ),

              const SizedBox(height: 16),

              Center(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 1100),
                  child: Column(
                    children: [
                      RatingBar.builder(
                        initialRating: book['rate'].toDouble(),
                        minRating: 1,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemSize: 30,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                        ignoreGestures:
                            true, // Kullanıcı değerlendirmeyi değiştiremesin
                      ),
                    ],
                  ),
                ),
              ),

              const Divider()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, {required Duration duration}) {
    return FadeInUp(
      duration: duration,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: MyColors.buttonColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
