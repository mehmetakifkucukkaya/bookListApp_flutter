import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/constants.dart';

class BookDetailPage extends StatelessWidget {
  final List<DocumentSnapshot> books;
  final int initialIndex;

  const BookDetailPage({
    Key? key,
    required this.books,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        title: const Text('Kitap Detayı'),
      ),
      body: PageView.builder(
        itemCount: books.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) => _buildBookDetail(books[index].id),
      ),
    );
  }

  Widget _buildBookDetail(String bookId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('books').doc(bookId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Kitap bulunamadı.'));
        }

        final book = snapshot.data!.data() as Map<String, dynamic>;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (book['image'] != null && book['image'].isNotEmpty)
                  _buildBookImage(book['image']),
                const SizedBox(height: 16),
                _buildBookInfo(book),
                const SizedBox(height: 16),
                _buildBookDetails(book),
                const SizedBox(height: 16),
                _buildRatingBar(book['rate'].toDouble()),
                const Divider(),
                const SizedBox(height: 12),
                _buildSummarySection(context, book['summary'], bookId),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookImage(String imageUrl) {
    return Center(
      child: FadeIn(
        duration: const Duration(seconds: 1),
        child: Image.network(
          imageUrl,
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
    );
  }

  Widget _buildBookInfo(Map<String, dynamic> book) {
    return Column(
      children: [
        _buildDetailText(book['bookName'], 22, FontWeight.bold, 500),
        _buildDetailText(book['genre'], 20, FontWeight.w500, 600),
        _buildDetailText(book['author'], 18, FontWeight.w400, 700),
      ],
    );
  }

  Widget _buildBookDetails(Map<String, dynamic> book) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildHighlightedText('${book['language']}', 800),
        _buildHighlightedText('${book['readingYear']}', 900),
        _buildHighlightedText('${book['pages']} Sayfa', 1000),
      ],
    );
  }

  Widget _buildRatingBar(double rating) {
    return Center(
      child: FadeInUp(
        duration: const Duration(milliseconds: 1100),
        child: RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          itemCount: 5,
          itemSize: 30,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (rating) {
            print(rating);
          },
          ignoreGestures: true,
        ),
      ),
    );
  }

  // ... Diğer yardımcı metotlar (örneğin _buildDetailText, _buildHighlightedText, _buildSummarySection) aynı kalabilir.

  // ... _showSummaryDialog ve _updateBookSummary metotları da aynı kalabilir.
}

  Widget _buildDetailText(String? text, double fontSize,
      FontWeight fontWeight, int durationMs) {
    return Center(
      child: FadeInUp(
        duration: Duration(milliseconds: durationMs),
        child: Text(
          text ?? 'Bilgi bulunmuyor.',
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, int durationMs) {
    return FadeInUp(
      duration: Duration(milliseconds: durationMs),
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

  Widget _buildSummarySection(
      BuildContext context, String? summary, String bookId) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kitap Özeti',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            summary == null || summary.isEmpty
                ? GestureDetector(
                    onTap: () => _showSummaryDialog(context, bookId),
                    child: const Text(
                      'Özet bulunmuyor. Özet eklemek için tıklayın.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  )
                : Text(
                    summary,
                    style:
                        const TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ],
        ),
      ),
    );
  }

  void _showSummaryDialog(BuildContext context, String bookId) {
    final TextEditingController summaryController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Özet Ekle'),
          content: TextField(
            controller: summaryController,
            decoration: const InputDecoration(
              hintText: 'Özetinizi buraya girin',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                final summary = summaryController.text.trim();
                if (summary.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Özet boş olamaz!'),
                      backgroundColor: Color.fromARGB(255, 238, 33, 18),
                    ),
                  );
                  return;
                }

                await _updateBookSummary(bookId, summary);
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBookSummary(String bookId, String summary) async {
    final bookRef =
        FirebaseFirestore.instance.collection('books').doc(bookId);

    try {
      await bookRef.update({'summary': summary});
      print('Özet güncellendi.');
    } catch (e) {
      print('Özet güncellenirken bir hata oluştu: $e');
    }
  }

