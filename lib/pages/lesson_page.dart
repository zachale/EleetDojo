import 'package:eleetdojo/widgets/go_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class LessonPage extends StatelessWidget {
  final dynamic lessonData;
  const LessonPage({super.key, required this.lessonData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GoAppBar(name: lessonData['name']),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
              lessonData['name'],
              style: const TextStyle(fontSize: 24.0),
              ),
              const SizedBox(height: 16),
              Html(
                data: lessonData['content'],
                style: {
                  "*": Style(
                    fontSize: FontSize.large,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}