import 'package:eleetdojo/auth_service.dart';
import 'package:eleetdojo/pages/dojo_page.dart';
import 'package:flutter/material.dart';
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
      home: DojoPage(auth_service: auth_service),
    );
  }
}
