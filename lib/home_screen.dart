import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background SVG
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/icons/bg.svg',
              fit: BoxFit.fill,
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Spacer(flex: 1) ,
                Text(
                  'Welcome to Quiz App!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                 Text("Enter your information below"),
                  Spacer(),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController, // Assign the controller here
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF1C2341),
                    hintText: "Full Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                Spacer(),
                SizedBox(height: 15),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    String userName = _nameController.text;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(userName: userName),
                      ),
                    );
                  },
                  child: Text('Start Quiz'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.blue[700]),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
