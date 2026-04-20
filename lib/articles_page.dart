import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'article_detail_page.dart';

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
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // كل JSON

        final lang = context.locale.languageCode; // ar / en / fr

        setState(() {
          articles = data[lang] ?? [];
          loading = false;
        });
      } else {
        throw Exception("Failed to load articles");
      }
    } catch (e) {
      print("Error loading articles: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
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
                                  child: Image.network(
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
