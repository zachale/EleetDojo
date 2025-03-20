import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//void main() => runApp(const sensi());
class sensi extends StatelessWidget {
  const sensi({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 3, 15, 36),
        appBar: AppBar(title: const Text('eLeetDojo', style: TextStyle(color: Colors.white,fontSize: 30,)),backgroundColor: const Color.fromARGB(255, 3, 15, 36),), 
        
        body: const learningFromSensiScreen(),
      ),
    );
  }
}

// class to show messages between user and chatbot
class learningFromSensiScreen extends StatefulWidget {
  const learningFromSensiScreen({super.key});

  @override
  State<learningFromSensiScreen> createState() => _learningFromSensiScreen();
}

class _learningFromSensiScreen extends State<learningFromSensiScreen> {


  final List<Map<String, String>> _userSensiConversation = [];
  final TextEditingController _controller = TextEditingController();
  Future<void> getSensi(String userQuestion) async {

    const geminiAPIKey = 'AIzaSyCSnm9UUWxvbdcYQ2COU-ctEkvnJMDdrbw';
    const geminiUrlPath = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiAPIKey';


    // sensi context:
    //{
	    //question: string
	    //answer: string
	    //user_chose: string
    // }

    // answer the user question based off the problem: questoin, the answer: answer, and the user choice: userChoice


    setState(() {
      // add context section after userquestoin "text" paramter
      _userSensiConversation.add({"role": "user", "text": userQuestion});
    });

    
      final sensiResponse = await http.post(
        Uri.parse(geminiUrlPath),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {"parts": [{"text": userQuestion}]}
          ]
        }),
      );

      if (sensiResponse.statusCode == 200) {

        final sensiAnswer = jsonDecode(sensiResponse.body);
        setState(() {
          _userSensiConversation.add({
            "role": "gemini",
            // extract response, if reponse is null, send default message
            "text": sensiAnswer['candidates']?[0]['content']?['parts']?[0]['text'] ?? 'Something Went on, please try agian later'
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
          itemCount: _userSensiConversation.length,
          itemBuilder: (context, index) 
          {
            final userSensiConversation = _userSensiConversation[index];

            final lastMessageSentUser = userSensiConversation["role"] == "user";





            // each container represents each message, from user or gemini/sensi response
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6.5),
              padding: const EdgeInsets.all(20.0),
              color: lastMessageSentUser == true ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 76, 122, 160),
              child: Text(
                userSensiConversation["text"] ?? '',
                style: TextStyle(color: lastMessageSentUser == true ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 255, 255, 255)),
              ),
            );
          },
        ),
      ),





      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(hintText: 'Ask Sensi', hintStyle: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                getSensi(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    ],
  );
}

}

