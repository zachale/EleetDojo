import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


class Sensei extends StatelessWidget {
  final Map<String, dynamic>? extra;

  const Sensei({super.key, this.extra});

  @override
  Widget build(BuildContext context) {
    final extraData = GoRouterState.of(context).extra as Map<String, dynamic>?;
    
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Sensei', style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: () {
            if (extraData != null) {
              return IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              );
            }
            return null;
          }(),
    ),
        body: learningFromSenseiScreen(extraData: extraData),
      ),
    );
  }
}

class learningFromSenseiScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const learningFromSenseiScreen({super.key, this.extraData});

  @override
  State<learningFromSenseiScreen> createState() => _learningFromSenseiScreen();
}

class _learningFromSenseiScreen extends State<learningFromSenseiScreen> {
  final List<Map<String, String>> _userSenseiConversation = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

  // flutter mark down library that allows you to remove 
    if (widget.extraData != null) {
      final String question = widget.extraData?['question'] ?? 'No question provided';
      final String correctAnswer = widget.extraData?['answer'] ?? 'Unknown';
      final String userChoice = widget.extraData?['selectedAnswer'] ?? 'No choice made';
      final String leetcodeContent = widget.extraData?['leetcodeContent'] ?? '';

      
      getSensei("Help me understand this question.", correctAnswer, userChoice, question, leetcodeContent);
    }
  }

  Future<void> getSensei(String userQuestion, String correctAnswer, String userChoice, String ogQuestion, String leetcodeContent) async {
    const geminiAPIKey = 'AIzaSyCSnm9UUWxvbdcYQ2COU-ctEkvnJMDdrbw';
    const geminiUrlPath =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiAPIKey';

    setState(() {
      _userSenseiConversation.add({"role": "user", "text": userQuestion});
    });


    String contextText = "You are a chatbot called Sensei, your task is to help users with their questions.";
    if (ogQuestion != "No question provided")
    {
      contextText = "Your are a chatbot called Sensei that helps users understand why their quiz answer was wrong. Your will be given the main problem, the current problem question, the correct answer and the users answer. It is your job to help the user understand why they got the answer wrong. The follwing is the context. Main Problem: $leetcodeContent Question: $ogQuestion. The correct answer is: $correctAnswer. The user selected: $userChoice.";
    }
    

    final response = await http.post(
      Uri.parse(geminiUrlPath),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": userQuestion},
              // Adding context: question, correctAnswer, userChoice
              {"text": contextText},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _userSenseiConversation.add({
          "role": "gemini",
          "text": responseData['candidates']?[0]['content']?['parts']?[0]['text'] ?? 'Something went wrong, please try again later.',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String question = widget.extraData?['question'] ?? 'No question provided';
    final String correctAnswer = widget.extraData?['answer'] ?? 'Unknown';
    final String userChoice = widget.extraData?['selectedAnswer'] ?? 'No choice made';
    final String leetcodeContent = widget.extraData?['leetcodeData'] ?? '';

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _userSenseiConversation.length,
            itemBuilder: (context, index) {
              final message = _userSenseiConversation[index];
              final isUserMessage = message["role"] == "user";

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6.5),
                padding: const EdgeInsets.all(20.0),
                color: isUserMessage ? Colors.white : const Color.fromARGB(255, 76, 122, 160),
                child: MarkdownBody(
                  data: message["text"] ?? '',
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(color: isUserMessage ? Colors.black : Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Ask Sensei',
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    getSensei(_controller.text, correctAnswer, userChoice, question, leetcodeContent);
                    _controller.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
