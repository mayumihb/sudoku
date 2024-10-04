import 'package:flutter/material.dart';
import 'home.dart';

class DifficultySelectorPage extends StatefulWidget {
  const DifficultySelectorPage({super.key});

  @override
  State<DifficultySelectorPage> createState() => _DifficultySelectorPageState();
}

class _DifficultySelectorPageState extends State<DifficultySelectorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'SELECIONE UMA DIFICULDADE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                color: Colors.grey
              ),
            ),
            const SizedBox(height: 50),
            buildDifficultyButton('FÁCIL', 0, const Color.fromRGBO(175, 240, 164, 1.0), Color.fromRGBO(119, 163, 111, 1), context),
            const SizedBox(height: 20),
            buildDifficultyButton('MÉDIO', 1, Color.fromRGBO(255, 207, 158, 1.0), Color.fromRGBO(164, 132, 101, 1), context),
            const SizedBox(height: 20),
            buildDifficultyButton('DIFÍCIL', 2, Color.fromRGBO(249, 159, 158, 1.0), Color.fromRGBO(174, 109, 109, 1), context),
          ],
        ),
      ),
    );
  }

  Widget buildDifficultyButton(String label, int value, Color color, Color textColor, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SudokuPage(difficulty: value),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor), // Define a cor do texto aqui
      ),
    );
  }
}
