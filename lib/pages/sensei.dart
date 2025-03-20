import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//void main() => runApp(const Sensei());
class Sensei extends StatelessWidget {
  const Sensei({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Sensei', style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: const learningFromSenseiScreen(),
      ),
    );
  }
}

// class to show messages between user and chatbot
class learningFromSenseiScreen extends StatefulWidget {
  const learningFromSenseiScreen({super.key});

  @override
  State<learningFromSenseiScreen> createState() => _learningFromSenseiScreen();
}

class _learningFromSenseiScreen extends State<learningFromSenseiScreen> {
  final List<Map<String, String>> _userSenseiConversation = [];
  final TextEditingController _controller = TextEditingController();

  Future<void> getSensei(String userQuestion) async {
    const geminiAPIKey = 'AIzaSyCSnm9UUWxvbdcYQ2COU-ctEkvnJMDdrbw';
    const geminiUrlPath =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiAPIKey';
    // Sensei context:
    //{
    //question: string
    //answer: string
    //user_chose: string
    // }

    // answer the user question based off the problem: question, the answer: answer, and the user choice: userChoice

    setState(() {
      // add context section after userquestoin "text" paramter
      _userSenseiConversation.add({"role": "user", "text": userQuestion});
    });

    final SenseiResponse = await http.post(
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
            ],
          },
        ],
      }),
    );

    if (SenseiResponse.statusCode == 200) {
      final SenseiAnswer = jsonDecode(SenseiResponse.body);
      setState(() {
        _userSenseiConversation.add({
          "role": "gemini",
          // extract response, if response is null, send default message
          "text":
              SenseiAnswer['candidates']?[0]['content']?['parts']?[0]['text'] ??
              'Something Went on, please try again later',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            // displaying number of messages
            itemCount: _userSenseiConversation.length,
            itemBuilder: (context, index) {
              final userSenseiConversation = _userSenseiConversation[index];

              final lastMessageSentUser =
                  userSenseiConversation["role"] == "user";

              // each container represents each message, from user or gemini/Sensei response
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6.5),
                padding: const EdgeInsets.all(20.0),
                color:
                    lastMessageSentUser == true
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : const Color.fromARGB(255, 76, 122, 160),
                child: Text(
                  userSenseiConversation["text"] ?? '',
                  style: TextStyle(
                    color:
                        lastMessageSentUser == true
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 100,
            left: 20,
            right: 20,
          ), // Added padding here
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
                    getSensei(_controller.text);
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
