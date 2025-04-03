import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  List<Map<String, dynamic>> quizQuestions = [];
  String quizName = '';
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadQuizQuestions();
  }

  Future<void> loadQuizQuestions() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final supabase = Supabase.instance.client;

      // Fetch questions from edge function
      final response = await supabase.functions.invoke(
        'questions',
        body: {'questionId': widget.quizId},
      );

      if (response.status != 200) {
        throw Exception('Failed to load questions');
      }

      final data = response.data;
      if (data == null || data['questions'] == null) {
        throw Exception('No questions found');
      }

      setState(() {
        quizQuestions = List<Map<String, dynamic>>.from(data['questions']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
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
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(''),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loadQuizQuestions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions available')),
      );
    }

    final currentQuestion = quizQuestions[currentQuestionIndex];
    final options = List<String>.from(
      currentQuestion['answers'].map((a) => a['label']),
    );
    final correctAnswerIndex = currentQuestion['answer'] as int;
    final correctAnswer = options[correctAnswerIndex - 1];
    final letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final correctAnswerLetter = letters[correctAnswerIndex - 1];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with back button and progress bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value:
                            (currentQuestionIndex + 1) / quizQuestions.length,
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
                  final letter = letters[index];
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
                          Text(
                            '$letter. ',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                        'The correct answer is $correctAnswerLetter.',
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
                            GoRouter.of(context).push(
                              '/sensei_help',
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
              const SizedBox(height: 75),
            ],
          ),
        ),
      ),
    );
  }
}
