class Question {
  final String text;
  final List<String> options;
  final String correctAnswer;

  Question({required this.text, required this.options, required this.correctAnswer});

  factory Question.fromMap(Map<String, dynamic> map) {
    List<String> options = List<String>.from(map['incorrect_answers'] as List)
      ..add(map['correct_answer'].toString())
      ..shuffle();
    return Question(
      text: map['question'].toString(),
      options: options,
      correctAnswer: map['correct_answer'].toString(),
    );
  }
}
