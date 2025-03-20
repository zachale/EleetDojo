import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Mock data
final mockQuizzes = [
  {
    'id': 1,
    'name': 'Array Basics Quiz',
    'questionIds': [1, 2],
  },
  {
    'id': 2,
    'name': 'Array Advanced Quiz',
    'questionIds': [2],
  },
];

final mockQuestions = [
  {
    'question': 'What is an array?',
    'options': ['A', 'B', 'C'],
    'answer': 'A',
    'id': 1,
  },
  {
    'question': 'How do you reverse an array?',
    'options': ['A', 'B', 'C'],
    'answer': 'B',
    'id': 2,
  },
];

class QuizPage extends StatefulWidget {
  final int quizId;

  const QuizPage({Key? key, required this.quizId}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  bool questionAnswered = false;
  String? selectedAnswer;
  late List<Map<String, dynamic>> quizQuestions;
  late String quizName;

  @override
  void initState() {
    super.initState();
    loadQuizQuestions();
  }

  void loadQuizQuestions() {
    final quiz = mockQuizzes.firstWhere(
      (q) => q['id'] == widget.quizId,
      orElse: () => {'id': -1, 'name': 'Quiz Not Found', 'questionIds': []},
    );

    quizName = quiz['name'] as String;
    final questionIds = quiz['questionIds'] as List;

    quizQuestions =
        questionIds
            .map(
              (id) => mockQuestions.firstWhere(
                (q) => q['id'] == id,
                orElse: () => {'id': -1},
              ),
            )
            .where((q) => q['id'] != -1)
            .toList()
            .cast<Map<String, dynamic>>();
  }

  void checkAnswer(String answer) {
    if (questionAnswered) return;

    setState(() {
      selectedAnswer = answer;
      questionAnswered = true;
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < quizQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        questionAnswered = false;
        selectedAnswer = null;
      });
    } else {
      GoRouter.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(quizName)),
        body: const Center(child: Text('Quiz not found or has no questions')),
      );
    }

    final currentQuestion = quizQuestions[currentQuestionIndex];
    final options = currentQuestion['options'] as List;
    final correctAnswer = currentQuestion['answer'] as String;

    print(questionAnswered);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and progress bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / quizQuestions.length,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${currentQuestionIndex + 1}/${quizQuestions.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Question
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                currentQuestion['question'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Options
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = selectedAnswer == option;
                final isCorrect = option == correctAnswer;

                Color buttonColor = Colors.grey.shade200;
                Widget? trailingIcon;

                if (questionAnswered && isSelected) {
                  buttonColor =
                      isCorrect ? Colors.green.shade100 : Colors.red.shade100;
                  trailingIcon = Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.all(16.0),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    onPressed:
                        questionAnswered ? null : () => checkAnswer(option),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Feedback and navigation buttons right after answers
            if (questionAnswered)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'The correct answer is $correctAnswer.',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: const LinearGradient(
                          colors: [Colors.teal, Colors.blue, Colors.purple],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          GoRouter.of(context).go(
                            '/sensei/example',
                            extra: {
                              'question': currentQuestion['question'],
                              'answer': correctAnswer,
                              'selectedAnswer': selectedAnswer,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Explain My Answer',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            ImageIcon(
                              const AssetImage('assets/sensei.png'),
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(
                        currentQuestionIndex < quizQuestions.length - 1
                            ? 'Continue'
                            : 'Finish Quiz',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

            // Spacer to push content up
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
