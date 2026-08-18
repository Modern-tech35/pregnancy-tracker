import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'article_detail_page.dart';
import 'app_drawer.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  List articles = [];
  bool loading = true;

  final url =
      "https://res.cloudinary.com/dptxm0zv0/raw/upload/v1764879045/articles.json_oi3zjo.json";

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    Map<String, dynamic>? data;

    // تحميل المقالات من الملف المرفق أولاً (بدون إنترنت)
    try {
      final localJson =
          await rootBundle.loadString('assets/data/articles.json');
      data = json.decode(localJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Error loading local articles: $e");
    }

    // إذا فشل التحميل المحلي، استخدم الرابط البعيد
    if (data == null) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          data = json.decode(response.body) as Map<String, dynamic>;
        }
      } catch (e) {
        debugPrint("Error loading remote articles: $e");
      }
    }

    if (!mounted) return;
    setState(() {
      articles = data?[context.locale.languageCode] ?? []; // ar / en / fr
      loading = false;
    });
  }

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
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text('tips'.tr()),
        centerTitle: true,
        elevation: 0,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : articles.isEmpty
              ? Center(
                  child: Text(
                    'no_data'.tr(),
                    style: const TextStyle(fontSize: 18),
                  ),
                )

              : Padding(
                  padding: EdgeInsets.all(width * 0.04),
                  child: ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (_, i) {
                      final article = articles[i];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ArticleDetailPage(article: article),
                            ),
                          );
                        },
                        child: Card(
                          color:
                              isDark ? Colors.grey[800] : Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.only(bottom: height * 0.02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (article['image'] != null &&
                                  article['image'] != "")
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: _articleImage(
                                    article['image'],
                                    width: double.infinity,
                                    height: height * 0.22,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                              Padding(
                                padding: EdgeInsets.all(width * 0.04),
                                child: Text(
                                  article['title'] ?? '',
                                  style: TextStyle(
                                    fontSize: width * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
