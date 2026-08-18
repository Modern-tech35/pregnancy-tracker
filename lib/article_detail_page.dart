import 'package:flutter/material.dart';


class ArticleDetailPage extends StatelessWidget {
  final Map article;
  const ArticleDetailPage({super.key, required this.article});

  Widget _articleImage(String image,
      {required double width, required double height, required BoxFit fit}) {
    final isLocal = image.startsWith('assets/');
    return isLocal
        ? Image.asset(image, width: width, height: height, fit: fit)
        : Image.network(image, width: width, height: height, fit: fit);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(article['title'] ?? ''),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _articleImage(
                  article['image'],
                  width: double.infinity,
                  height: height * 0.3,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              article['content'] ?? '',
              style: TextStyle(
                fontSize: width * 0.04,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
