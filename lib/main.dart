import 'package:eleetdojo/pages/error_page.dart';
import 'package:eleetdojo/pages/map_topic_page.dart';
import 'package:eleetdojo/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'mock_data.dart'; // Import mock data
import 'pages/map_page.dart';
import 'pages/lesson_page.dart';
import 'package:eleetdojo/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final background_color = Color(0xFF021526);
const primary_color = Color(0xFF6EA6DA);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final supabase = Supabase.instance.client;
  final auth_service = AuthService(supabase: supabase);

  runApp(MyApp(auth_service: auth_service, supabase: supabase));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/learning-map',
    routes: [
      GoRoute(
        path: '/learning-map',
        builder: (context, state) {
          final mapData = mockLearningMap;
          return LessonMapPage(mapData: mapData);
        },
      ),
      GoRoute(
        path: '/learning-map/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final topicData = mockTopics.firstWhere(
            (node) => node['id'] == id,
            orElse: () => <String, Object>{},
          );

          if (topicData.isEmpty) {
            return ErrorPage(message: 'Topic not found');
          }

          return LessonMapTopicPage(topicData: topicData);
        },
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final lessonData = mockLessons.firstWhere(
            (lesson) => lesson['id'] == id,
            orElse: () => <String, Object>{},
          );

          if (lessonData.isEmpty) {
            return ErrorPage(message: 'Lesson not found');
          }

          return LessonPage(lessonData: lessonData);
        },
      ),
      GoRoute(
        path: '/quiz/:id',
        builder: (context, state) {
          return ErrorPage(message: 'Quiz not found');
        },
      ),
    ],
  );
  final AuthService auth_service;
  final SupabaseClient supabase;

  const MyApp({super.key, required this.auth_service, required this.supabase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eLeetDojo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(auth_service: auth_service),
    );
  }
}
