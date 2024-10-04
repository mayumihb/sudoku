import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

class SudokuPage extends StatefulWidget {
  final int difficulty; // 0: Fácil, 1: Médio, 2: Difícil

  const SudokuPage({super.key, required this.difficulty});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  List<List<int>> sudokuGrid = List.generate(9, (i) => List.filled(9, 0));
  List<List<bool>> baseNumbers = List.generate(9, (i) => List.filled(9, true)); // Indica os números base
  int? selectedRow;
  int? selectedCol;
  Set<List<int>> invalidCells = {};
  Random random = Random();

  // Temporizador
  late Timer _timer;
  int _secondsElapsed = 0;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    generateSudoku();
    startTimer(); // Iniciar o temporizador
  }

  // Função para iniciar o temporizador
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused && mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Função para pausar e despausar o temporizador
  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  String getFormattedTime() {
    int minutes = _secondsElapsed ~/ 60;
    int seconds = _secondsElapsed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Função para verificar se o número está entre 1 e 9
  bool isValidNumber(int num) {
    return num >= 1 && num <= 9;
  }

  // Função para verificar se o Sudoku é válido
bool isValidSudoku(List<List<int>> grid) {
  invalidCells.clear();
  
  // Helper function to check if a number is valid in current position
  bool isValidMove(int row, int col, int num) {
    // Check row
    for (int x = 0; x < 9; x++) {
      if (x != col && grid[row][x] == num) {
        return false;
      }
    }
    
    // Check column
    for (int x = 0; x < 9; x++) {
      if (x != row && grid[x][col] == num) {
        return false;
      }
    }
    
    // Check 3x3 box
    int boxRow = row - (row % 3);
    int boxCol = col - (col % 3);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if ((boxRow + i != row || boxCol + j != col) && 
            grid[boxRow + i][boxCol + j] == num) {
          return false;
        }
      }
    }
    
    return true;
  }

  // Check each cell
  for (int row = 0; row < 9; row++) {
    for (int col = 0; col < 9; col++) {
      int currentNum = grid[row][col];
      
      // Skip empty cells
      if (currentNum == 0) continue;
      
      // Skip base numbers as they're assumed to be correct
      if (baseNumbers[row][col]) continue;
      
      // Verify if number is valid (1-9)
      if (currentNum < 1 || currentNum > 9) {
        invalidCells.add([row, col]);
        continue;
      }
      
      // Temporarily remove current number to check if it's valid in its position
      int temp = grid[row][col];
      grid[row][col] = 0;
      
      if (!isValidMove(row, col, temp)) {
        invalidCells.add([row, col]);
      }
      
      // Restore the number
      grid[row][col] = temp;
    }
  }
  
  return invalidCells.isEmpty;
}


// Função para verificar se o Sudoku foi completado
bool isSudokuComplete() {
  // First check if the grid is valid
  if (!isValidSudoku(sudokuGrid)) {
    return false;
  }
  
  // Then check if all cells are filled
  for (int row = 0; row < 9; row++) {
    for (int col = 0; col < 9; col++) {
      if (sudokuGrid[row][col] == 0) {
        return false;
      }
    }
  }
  
  return true;
}

  // Exibir o pop-up de parabéns
  void showCongratsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Parabéns!',
            textAlign: TextAlign.center,
          ),
          content: Text(
            getFormattedTime(),
            style: TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fechar o diálogo
                  Navigator.of(context).pop(); // Voltar para a tela anterior
                },
                child: const Text('NOVO JOGO'),
              ),
            ),
          ],
        );
      },
    );
  }

  // Função para verificar o Sudoku e exibir o diálogo
  void checkSudoku() {
    if (isSudokuComplete()) {
      _timer.cancel(); // Parar o temporizador
      Future.delayed(Duration.zero, () {
        showCongratsDialog(); // Exibir o pop-up se o Sudoku estiver correto
      });
    }
  }

  // Função para gerar o Sudoku conforme a dificuldade
  void generateSudoku() {
    // Gerar um grid completo
    fillSudokuGrid();
    
    // Remover células dependendo do nível de dificuldade
    int cellsToRemove = getCellsToRemove(widget.difficulty);

    // Remover células aleatórias
    removeRandomCells(cellsToRemove);
  }

  // Função para preencher a grid de forma completa (utilizando backtracking)
  bool fillSudokuGrid() {
    List<int> numbers = List.generate(9, (index) => index + 1)..shuffle(random);

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (sudokuGrid[row][col] == 0) {
          for (int number in numbers) {
            if (isSafe(row, col, number)) {
              sudokuGrid[row][col] = number;
              if (fillSudokuGrid()) {
                return true;
              }
              sudokuGrid[row][col] = 0; // Backtrack
            }
          }
          return false; // Nenhum número válido
        }
      }
    }
    return true; // Sudoku preenchido
  }

  // Verifica se o número pode ser colocado na célula
  bool isSafe(int row, int col, int num) {
    // Verifica a linha e a coluna
    for (int i = 0; i < 9; i++) {
      if (sudokuGrid[row][i] == num || sudokuGrid[i][col] == num) {
        return false;
      }
    }

    // Verifica o bloco 3x3
    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (sudokuGrid[startRow + i][startCol + j] == num) {
          return false;
        }
      }
    }

    return true;
  }

  // Determina quantas células remover com base na dificuldade
  int getCellsToRemove(int difficulty) {
    switch (difficulty) {
      case 0: // Fácil
        return 30; // Menos células removidas
      case 1: // Médio
        return 50; // Número médio de células removidas
      case 2: // Difícil
        return 70; // Mais células removidas
      default:
        return 30; // Padrão é fácil
    }
  }

  // Função para remover células aleatórias
  void removeRandomCells(int count) {
    int removed = 0;

    while (removed < count) {
      int row = random.nextInt(9);
      int col = random.nextInt(9);

      if (sudokuGrid[row][col] != 0) {
        baseNumbers[row][col] = false; // Marcar como número base
        sudokuGrid[row][col] = 0;
        removed++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sudoku - ${getDifficultyName(widget.difficulty)}',
          style: TextStyle(
            color: Colors.blueGrey
          ),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  getFormattedTime(), 
                  style: TextStyle(
                    fontSize: 25,
                    color: const Color.fromARGB(255, 55, 91, 109)
                  ),
                ),
                IconButton(
                  icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                  onPressed: togglePause,
                ),
              ],
            ),
            Expanded(
              flex: 6,
              child: buildSudokuGrid(),
            ),
            SizedBox(height: 10),
            if (!isPaused) // Impedir que o usuário interaja quando o jogo está pausado
              Expanded(
                flex: 2,
                child: buildNumberPad(),
              ),
              SizedBox(height: 5),
            // Expanded(
            //   flex: 2,
            //   child: buildNumberPad(),
            // ),
          ],
        ),
      ),
    );
  }

  // Retorna o nome da dificuldade
  String getDifficultyName(int difficulty) {
    switch (difficulty) {
      case 0:
        return 'Fácil';
      case 1:
        return 'Médio';
      case 2:
        return 'Difícil';
      default:
        return 'Fácil';
    }
  }

  Widget buildSudokuGrid() {
    double gridSize = MediaQuery.of(context).size.width * 0.9;
    double cellSize = gridSize / 9;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Colors.blueGrey,
          )
        ),
        width: gridSize,
        height: gridSize,
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            int row = index ~/ 9;
            int col = index % 9;
            bool isSelected = selectedRow == row && selectedCol == col;
            bool isInvalid = invalidCells.any((cell) => cell[0] == row && cell[1] == col); // Verifica se a célula está inválida
            bool isBaseNumber = baseNumbers[row][col]; // Verifica se é um número base

            return GestureDetector(
              onTap: () {
                if (!isBaseNumber) { // Permitir selecionar apenas números não-base
                  setState(() {
                    selectedRow = row;
                    selectedCol = col;
                    isValidSudoku(sudokuGrid);
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: row % 3 == 0 ? 3 : 1,
                      color: Colors.blueGrey,
                    ),
                    left: BorderSide(
                      width: col % 3 == 0 ? 3 : 1,
                      color: Colors.blueGrey,
                    ),
                    right: BorderSide(
                      width: (col + 1) % 3 == 0 ? 3 : 1,
                      color: Colors.blueGrey,
                    ),
                    bottom: BorderSide(
                      width: (row + 1) % 3 == 0 ? 3 : 1,
                      color: Colors.blueGrey,
                    ),
                  ),
                  color: isSelected
                      ? Colors.blue[100]
                      : isInvalid
                          ? Colors.red[200]
                          : Colors.white,
                ),
                child: Center(
                  child: Text(
                    sudokuGrid[row][col] == 0
                        ? ''
                        : sudokuGrid[row][col].toString(),
                    style: TextStyle(
                      fontSize: cellSize * 0.4,
                      fontWeight: isBaseNumber
                          ? FontWeight.bold // Números base em negrito
                          : FontWeight.normal, // Números inseridos pelo usuário normais
                      color: isBaseNumber ? Colors.blueGrey : Colors.blueAccent, // Azul para os números do usuário
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildNumberPad() {
    double padSize = MediaQuery.of(context).size.width * 0.6;
    double cellSize = padSize / 5;

    return Center(
      child: Container(
        width: padSize,
        height: padSize / 2.5,
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (selectedRow != null && selectedCol != null && !baseNumbers[selectedRow!][selectedCol!]) { // Permitir apenas nos não-base
                  setState(() {
                    sudokuGrid[selectedRow!][selectedCol!] = index; // Atualiza o valor da célula selecionada
                    isValidSudoku(sudokuGrid); // Verifica o Sudoku
                    checkSudoku();
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: index == 0
                      ? Image.asset(
                          'assets/images/borracha.png',
                          width: cellSize * 0.6,
                          height: cellSize * 0.6,
                        )
                      : Text(
                          index.toString(),
                          style: TextStyle(color: Colors.white, fontSize: cellSize * 0.4),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}