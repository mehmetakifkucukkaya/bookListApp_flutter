import 'package:flutter/material.dart';

class BookListCard extends StatelessWidget {
  final String bookName;
  final String genre;
  final String author;
  final int pages;
  final int rate;
  final int readingYear;
  final String image;
  final String language;

  const BookListCard({
    required this.bookName,
    required this.genre,
    required this.author,
    required this.pages,
    required this.image,
    required this.rate,
    required this.readingYear,
    required this.language,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Row(
        children: [
          Image.network(
            '$image',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  bookName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
                Text(
                  author,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: Colors.grey[600]),
                ),
                Text(
                  genre,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.grey[600]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    rate,
                    (index) => Icon(
                      Icons.star,
                      color: Colors.yellow[700],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
