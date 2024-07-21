import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class ScoreScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String userName;

  ScoreScreen({
    required this.score,
    required this.totalQuestions,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background SVG
          SvgPicture.asset(
            'assets/icons/bg.svg',
            fit: BoxFit.cover,
          ),
          // Centered Column
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Quiz Result Text
                Text(
                  'Quiz Result',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                // Trophy Image
                SvgPicture.asset(
                  'assets/icons/trophy.svg',
                  height: 90,
                ),
                SizedBox(height: 20),
                if (score >= 8)
                  Text(
                    'Congratulations, $userName!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                if (score < 8)
                  Text(
                    'Better luck next time, $userName!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),  
               
               
                SizedBox(height: 20),
                Text(
                  'Your Score: $score / $totalQuestions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
               
                
              ],
            ),
          ),
        ],
      ),
    );
  }


}
