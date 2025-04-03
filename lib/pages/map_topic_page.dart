import 'package:eleetdojo/widgets/go_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonMapTopicPage extends StatelessWidget {
  final dynamic topicData;
  const LessonMapTopicPage({super.key, required this.topicData});

  @override
  Widget build(BuildContext context) {
    final lessons = topicData['lessons'];
    final quizzes = topicData['quizzes'];

    return Scaffold(
      appBar: GoAppBar(name: topicData['name']),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 116.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lessons',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => context.push('/lesson/${lessons[index]['id']}'),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        lessons[index]['name'],
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Quizzes',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => context.push('/prequiz/${quizzes[index]['id']}'),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        quizzes[index]['name'],
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
