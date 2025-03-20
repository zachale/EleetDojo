import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eleetdojo/widgets/app_bar.dart';

class LessonListPage extends StatelessWidget {
  final int nodeId;

  const LessonListPage({super.key, required this.nodeId});

  @override
  Widget build(BuildContext context) {
    final lessons = ['Lesson 1', 'Lesson 2', 'Lesson 3'];
    final quizzes = ['Quiz 1', 'Quiz 2', 'Quiz 3'];

    return Scaffold(
      appBar: GoAppBar(title: 'Lessons'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      lessons[index],
                      style: TextStyle(fontSize: 16.0),
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
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      quizzes[index],
                      style: TextStyle(fontSize: 16.0),
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
