import 'package:eleetdojo/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:eleetdojo/main.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Question {
  final int id;
  final String slug;
  final String name;

  Question({
    required this.id,
    required this.slug,
    required this.name
  });

  String get url => 'https://leetcode.com/problems/$slug/';

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      slug: map['slug'],
      name: map['name']
    );
  }
}

class DojoPage extends StatefulWidget {
  final AuthService auth_service;

  const DojoPage({super.key, required this.auth_service});

  @override
  _DojoPageState createState() => _DojoPageState();
}

class _DojoPageState extends State<DojoPage> {
  List<Question> filteredData = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('leetcode')
          .select()
          .order('id', ascending: true);
      
      setState(() {
        filteredData = (response as List)
            .map((q) => Question.fromMap(q))
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading questions: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleSearch(String query) async {
    setState(() => searchQuery = query.trim().toLowerCase());
    
    try {
      if (searchQuery.isEmpty) {
        await _loadQuestions();
      } else {
        var filteredQuery = searchQuery.replaceAll(' ', '-').toLowerCase();
        debugPrint("Searching with: $filteredQuery");
        final response = await Supabase.instance.client
            .from('leetcode')
            .select()
            .ilike('slug', "%$filteredQuery%")
            .order('id', ascending: true);
        
        setState(() {
          filteredData = (response as List)
              .map((q) => Question.fromMap(q))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error searching questions: $e');
    }
  }

  void _getRandomQuestion() {
    if (filteredData.isEmpty) {
      debugPrint("No questions available for random selection.");
      return;
    }

    final random = Random();
    final randomQuestion = filteredData[random.nextInt(filteredData.length)];
    debugPrint("Random question: ${randomQuestion.name}");
    final currentLocation = GoRouterState.of(context).path;
    context.push(
      "/prequiz/${randomQuestion.id}",
      extra: {'returnPath': currentLocation},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Dojo'),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            color: backgroundColor,
            child: Column(
              children: [
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primary_color,
                          ),
                        )
                      : filteredData.isEmpty
                          ? const Center(
                              child: Text(
                                'No questions found',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) {
                                final question = filteredData[index];
                                return Card(
                                  color: backgroundColor,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: primary_color,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    title: Text(
                                      "${question.id} ${question.name}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primary_color,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                    ),
                                    onTap: () {
                                      debugPrint('Question tapped: ${question.id}');
                                      final currentLocation = GoRouterState.of(context).path;
                                      context.push(
                                        "/prequiz/${question.id}",
                                        extra: {'returnPath': currentLocation},
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: primary_color),
                      cursorColor: primary_color,
                      decoration: InputDecoration(
                        hintText: 'Search questions...',
                        hintStyle: TextStyle(color: primary_color),
                        // prefixIcon: Icon(Icons.search, color: primary_color),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: primary_color),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: primary_color,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primary_color),
                        ),
                      ),
                      onChanged: _handleSearch,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.shuffle, color: Colors.white),
                    onPressed: _getRandomQuestion,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
