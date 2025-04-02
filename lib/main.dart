import 'package:eleetdojo/pages/pre_quiz_page.dart';
import 'package:eleetdojo/pages/reset_password.dart';
import 'package:eleetdojo/pages/dojo_page.dart';
import 'package:eleetdojo/pages/error_page.dart';
import 'package:eleetdojo/pages/map_topic_page.dart';
import 'package:eleetdojo/auth_service.dart';
import 'package:eleetdojo/pages/login.dart';
import 'package:eleetdojo/pages/quiz_page.dart';
import 'package:eleetdojo/pages/sensei.dart';
import 'package:eleetdojo/pages/signup.dart';
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
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      // handle deeplinks explicitly
      final uri = state.uri.toString();

      if (uri.startsWith('eleetdojo://login-callback')) {
        debugPrint('Login callback deeplink');
        if (auth_service.getCurrentSession() != null) {
          return '/learning-map';
        }
      } else if (uri.startsWith('eleetdojo://reset-password-callback')) {
        return '/reset-password';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(path: '/', redirect: (_, __) => '/learning-map'),
          GoRoute(
            path: '/dojo',
            builder: (context, state) => DojoPage(auth_service: auth_service),
          ),
          GoRoute(path: '/sensei', builder: (context, state) => const Sensei()),
          GoRoute(
            path: '/login',
            builder: (context, state) {
              return LoginScreen(auth_service: auth_service);
            },
          ),
          GoRoute(
            path: '/signup',
            builder: (context, state) {
              return SignupScreen(auth_service: auth_service);
            },
          ),
          GoRoute(
            path: '/reset-password',
            builder: (context, state) {
              return ForgotPassword(auth_service: auth_service);
            },
          ),
          GoRoute(
            path: '/learning-map',
            builder: (context, state) {
              return FutureBuilder(
                future: supabase
                    .from('topics')
                    .select()
                    .order("id", ascending: true),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return ErrorPage(
                      message: 'Error loading topics: ${snapshot.error}',
                    );
                  }

                  final mapData = snapshot.data as List;
                  return LessonMapPage(mapData: mapData);
                },
              );
            },
          ),
          GoRoute(
            path: '/learning-map/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return FutureBuilder(
                future: Future(() async {
                  // First, fetch the topic from topics table
                  final topic =
                      await supabase
                          .from('topics')
                          .select()
                          .eq('id', id)
                          .single();

                  // Extract lesson IDs from the topic
                  final lessonIds = List<dynamic>.from(topic['lessons'] ?? []);
                  print(lessonIds);

                  // Fetch all lessons using the lesson IDs
                  List lessons = [];
                  if (lessonIds.isNotEmpty) {
                    lessons = await supabase
                        .from('lessons')
                        .select()
                        .inFilter('id', lessonIds)
                        .order('id', ascending: true);
                  }

                  return {
                    'name': topic['name'],
                    'lessons': lessons,
                    'quizzes': [],
                  };
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return ErrorPage(
                      message: 'Error loading topic: ${snapshot.error}',
                    );
                  }

                  final topicData = snapshot.data as Map<String, dynamic>;
                  return LessonMapTopicPage(topicData: topicData);
                },
              );
            },
          ),
          GoRoute(
            path: '/lesson/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return FutureBuilder(
                future: supabase.from('lessons').select().eq('id', id).single(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return ErrorPage(
                      message: 'Error loading lesson: ${snapshot.error}',
                    );
                  }

                  if (snapshot.data == null) {
                    return ErrorPage(message: 'Lesson not found');
                  }

                  final lessonData = snapshot.data as Map<String, dynamic>;
                  return LessonPage(lessonData: lessonData);
                },
              );
            },
          ),
          GoRoute(
            path: '/quiz/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return QuizPage(quizId: id);
            },
          ),
          GoRoute(
            path: '/prequiz/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return PreQuizPage(questionId: id);
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
        textTheme: Theme.of(
          context,
        ).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
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
        GoRouter.of(context).routeInformationProvider.value.uri.path;
    debugPrint('Current path: $currentPath');
    return Scaffold(
      body: Stack(
        children: [
          child,
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
