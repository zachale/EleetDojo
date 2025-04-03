import 'package:eleetdojo/widgets/go_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class LessonPage extends StatelessWidget {
  final dynamic lessonData;
  const LessonPage({super.key, required this.lessonData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GoAppBar(name: '', route: null),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Html(data: lessonData['content']),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
