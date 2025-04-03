import 'package:eleetdojo/widgets/go_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PreQuizPage extends StatefulWidget {
  final int questionId;

  const PreQuizPage({Key? key, required this.questionId}) : super(key: key);

  @override
  State<PreQuizPage> createState() => _PreQuizPageState();
}

class _PreQuizPageState extends State<PreQuizPage> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? questionData;

  @override
  void initState() {
    super.initState();
    loadQuestionData();
  }

  Future<void> loadQuestionData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final supabase = Supabase.instance.client;
      final response =
          await supabase
              .from('leetcode')
              .select()
              .eq('id', widget.questionId)
              .single();

      if (response['data'] == null || response['questions'] == null) {
        final functionResponse = await supabase.functions.invoke(
          'questions',
          body: {'questionId': widget.questionId},
        );

        if (functionResponse.status != 200) {
          throw 'Failed to generate question data';
        }

        // Fetch the updated data after generation
        final updatedResponse =
            await supabase
                .from('leetcode')
                .select()
                .eq('id', widget.questionId)
                .single();

        setState(() {
          questionData = updatedResponse;
          isLoading = false;
        });
      } else {
        setState(() {
          questionData = response;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              FutureBuilder(
                future: Future.delayed(const Duration(seconds: 3)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Generating new questions...'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(error!)),
      );
    }

    final data = questionData?['data'] as Map<String, dynamic>;
    final topics =
        (data['topicTags'] as List)
            .map((tag) => tag['name'] as String)
            .toList();

    return Scaffold(
      appBar: GoAppBar(name: 'Question ${widget.questionId}', route: null),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['title'],
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Chip(
                label: Text(
                  data['difficulty'],
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor:
                    data['difficulty'] == 'Hard'
                        ? Colors.red.shade100
                        : data['difficulty'] == 'Medium'
                        ? Colors.yellow.shade100
                        : Colors.green.shade100,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    topics
                        .map(
                          (topic) => Chip(
                            label: Text(
                              topic,
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.blue.shade100,
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Problem Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (data['content'] != null)
                        Html(
                          data: data['content'],
                          style: {
                            "*": Style(fontSize: FontSize.large),
                            "img": Style(width: Width(275.0)),
                          },
                        )
                      else
                        Text(
                          'This is a LeetCode premium question: Some data is unavailable, but the quiz was still generated with the data that is available. Feel free to attempt it!',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/quiz/${widget.questionId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Start Quiz',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 85),
            ],
          ),
        ),
      ),
    );
  }
}
