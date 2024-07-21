import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'question.dart';
import 'score_screen.dart';

class QuizScreen extends StatefulWidget {
  final String userName;

  QuizScreen({required this.userName});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questions;
  int _secondsRemaining = 60;
  late Timer _timer;
  int _currentQuestionIndex = 0;
  List<String?> _selectedOptions = [];
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  void _startQuiz() {
    _questions = _fetchQuestions();
    _startTimer();
  }

  Future<List<Question>> _fetchQuestions() async {
    final response = await http.get(Uri.parse(
        'https://opentdb.com/api.php?amount=10&category=27&difficulty=easy&type=multiple'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('results')) {
        List<dynamic> results = data['results'];
        List<Question> questions = [];
        for (var item in results) {
          questions.add(Question.fromMap(item));
        }
        _selectedOptions = List.generate(questions.length, (_) => null);
        return questions;
      } else {
        throw Exception('Invalid API response: results key not found');
      }
    } else {
      throw Exception('Failed to load questions');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          _navigateToNextQuestion();
        }
      });
    });
  }

  void _navigateToNextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _selectedOptions.length - 1) {
        _currentQuestionIndex++;
        _secondsRemaining = 60; // Reset timer for the next question
      } else {
        _timer.cancel();
        _navigateToScoreScreen();
      }
    });
    if (_currentQuestionIndex < _selectedOptions.length) {
      _startTimer(); // Start timer for the next question
    }
  }

  void _navigateToScoreScreen() async {
    _score = await _calculateScore();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreScreen(
          score: _score,
          userName: widget.userName,
          totalQuestions: _selectedOptions.length,
        ),
      ),
    );
  }

  Future<int> _calculateScore() async {
    final questions = await _questions;
    int score = 0;
    for (int i = 0; i < _selectedOptions.length; i++) {
      if (_selectedOptions[i] == questions[i].correctAnswer) {
        score++;
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            'assets/icons/bg.svg',
            fit: BoxFit.cover,
          ),
          FutureBuilder<List<Question>>(
            future: _questions,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<Question> questions = snapshot.data ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(padding: const EdgeInsets.symmetric(vertical: 16)),
                          Text(
                            'Question ${_currentQuestionIndex + 1}/${questions.length}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 4,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                          SizedBox(height: 20),
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xFF3F4768), width: 3),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                  
                                  ),
                                ),
                              ),
                              LinearProgressIndicator(
                                value: _secondsRemaining / 60,
                                minHeight: 30,
                                backgroundColor: Colors.transparent,
                                    borderRadius: BorderRadius.circular(50),
                                 valueColor: AlwaysStoppedAnimation<Color>(
        _secondsRemaining <= 10 ? Colors.red : Color.fromARGB(255, 63, 177, 234),
                                 )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _parseHtmlString(
                                  questions[_currentQuestionIndex].text),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            ...questions[_currentQuestionIndex]
                                .options
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              String option = entry.value;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedOptions[_currentQuestionIndex] =
                                        option;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: _getOptionColor(
                                            questions[_currentQuestionIndex],
                                            index)),
                                    borderRadius: BorderRadius.circular(15),
                                    color: _selectedOptions.isNotEmpty &&
                                            _selectedOptions[_currentQuestionIndex] ==
                                                option
                                        ? Colors.green
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${index + 1}. $option",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            color: Colors.white),
                                      ),
                                      if (_selectedOptions.isNotEmpty &&
                                          _selectedOptions[_currentQuestionIndex] ==
                                              option)
                                        Icon(Icons.check, color: Colors.white),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _navigateToHomeScreen,
                            child: Text('Quit Quiz'),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => Colors.blue[700]),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 20)),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _navigateToNextQuestion,
                            child: Text('Next'),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => Colors.blue[700]),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.symmetric(vertical: 15)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Color _getOptionColor(Question question, int index) {
    if (_selectedOptions.isNotEmpty &&
        _selectedOptions[_currentQuestionIndex] != null &&
        _selectedOptions[_currentQuestionIndex] == question.options[index]) {
      return question.options[index] == question.correctAnswer
          ? Colors.green
          : Colors.red;
    }
    return Colors.white;
  }

  String _parseHtmlString(String htmlString) {
    final text = htmlString.replaceAllMapped(RegExp(r'&#?\w+;'), (match) {
      final entity = match.group(0);
      if (entity!.startsWith('&') && entity.endsWith(';')) {
        return _parseHtmlEntity(entity);
      } else {
        return entity;
      }
    });
    return text;
  }

  String _parseHtmlEntity(String entity) {
    switch (entity) {
      case '&quot;':
        return '"';
      // Add more HTML entities as needed
      case '&#039;':
        return '"';
      default:
        return entity;
    }
  }

  void _navigateToHomeScreen() {
    Navigator.pop(context); // Go back to the home screen
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
