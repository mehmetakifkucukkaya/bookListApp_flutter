import 'package:flutter/material.dart';

class BookListCard extends StatelessWidget {
  const BookListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Row(
        children: [
          Image.network(
            'https://www.iskultur.com.tr/webp/2019/08/serguzest-2.jpg',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Kitap İsmi",
                  style: TextStyle( 
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
                Text(
                  "Yazar",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: Colors.grey[600]),
                ),
                Text(
                  "Tür",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.grey[600]),
                ),
                Icon(Icons.star, color: Colors.yellow[700]),
              ],
            ),
          )
        ],
      ),
    );
  }
}
