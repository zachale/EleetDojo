import 'package:eleetdojo/pages/dojo_page.dart';
import 'package:eleetdojo/pages/error_page.dart';
import 'package:eleetdojo/pages/map_topic_page.dart';
import 'package:eleetdojo/auth_service.dart';
import 'package:eleetdojo/pages/login.dart';
import 'package:eleetdojo/pages/sensei.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'mock_data.dart'; // Import mock data
import 'pages/map_page.dart';
import 'pages/lesson_page.dart';
import 'package:eleetdojo/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'components/app_navigation_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final backgroundColor = Color(0xFF021526);
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
  final AuthService auth_service;
  final SupabaseClient supabase;
  MyApp({super.key, required this.auth_service, required this.supabase});

  late final GoRouter router = GoRouter(
    initialLocation: '/learning-map',
    redirect: (BuildContext context, GoRouterState state) {
      // Since loggedIn is hardcoded to true, this condition is never reached
      final loggedIn = Supabase.instance.client.auth.currentSession != null ||
          true; // hardcode skip login
      if (!loggedIn) {
        return '/login';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            redirect: (_, __) => '/lessons',
          ),
          GoRoute(
            path: '/dojo',
            builder: (context, state) => const DojoPage(),
          ),
          GoRoute(
            path: '/sensei',
            builder: (context, state) => const SenseiPage(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) {
              return LoginScreen(auth_service: auth_service);
            },
          ),
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
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'eLeetDojo',
      routerConfig: router,
      theme: ThemeData(
        primaryColor: primary_color,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
        colorScheme: ColorScheme.dark(
          primary: primary_color,
          surface: backgroundColor,
        ),
      ),
    );
  }
}

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentPath =
        GoRouter.of(context).routeInformationProvider.value.uri.toFilePath();
    debugPrint('Current path: $currentPath');
    final hideNavBar = ['/login', '/signup', '/quiz'].contains(currentPath);

    return Scaffold(
      body: Stack(
        children: [
          child,
          if (!hideNavBar)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppNavigationBar(currentPath: currentPath),
            ),
        ],
      ),
    );
  }
}
