import 'package:flutter/material.dart';
import 'pages/lessons_list_page.dart';
import 'pages/lesson_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/quiz_page.dart';
import 'pages/dojo_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eLeetDojo',
      initialRoute: '/',
      routes: {
        '/': (context) => LessonsListPage(),
        '/lesson': (context) => LessonPage(),
        '/signin': (context) => SignInPage(),
        '/quiz': (context) => QuizPage(),
        '/dojo': (context) => DojoPage(),
      },
    );
  }
}
