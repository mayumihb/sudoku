import 'package:flutter/material.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  List<List<int>> sudokuGrid = List.generate(9, (i) => List.filled(9, 0));
  int? selectedRow;
  int? selectedCol;

  // Armazena as coordenadas das células que estão com números inválidos
  Set<List<int>> invalidCells = {};

  bool isValidSudoku(List<List<int>> grid) {
    invalidCells.clear(); // Limpar a lista de células inválidas

    // Verificar linhas
    for (int row = 0; row < 9; row++) {
      Set<int> seen = {};
      for (int col = 0; col < 9; col++) {
        int num = grid[row][col];
        if (num != 0) {
          if (seen.contains(num)) {
            invalidCells.add([row, col]); // Adicionar célula inválida
          }
          seen.add(num);
        }
      }
    }

    // Verificar colunas
    for (int col = 0; col < 9; col++) {
      Set<int> seen = {};
      for (int row = 0; row < 9; row++) {
        int num = grid[row][col];
        if (num != 0) {
          if (seen.contains(num)) {
            invalidCells.add([row, col]); // Adicionar célula inválida
          }
          seen.add(num);
        }
      }
    }

    // Verificar blocos 3x3
    for (int blockRow = 0; blockRow < 9; blockRow += 3) {
      for (int blockCol = 0; blockCol < 9; blockCol += 3) {
        Set<int> seen = {};
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            int num = grid[blockRow + row][blockCol + col];
            if (num != 0) {
              if (seen.contains(num)) {
                invalidCells.add([blockRow + row, blockCol + col]); // Adicionar célula inválida
              }
              seen.add(num);
            }
          }
        }
      }
    }

    return invalidCells.isEmpty; // Retorna verdadeiro se não houver células inválidas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sudoku'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 6,
              child: buildSudokuGrid(),
            ),
            SizedBox(height: 20),
            Expanded(
              flex: 2,
              child: buildNumberPad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSudokuGrid() {
    double gridSize = MediaQuery.of(context).size.width * 0.9;
    double cellSize = gridSize / 9;

    return Center(
      child: Container(
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

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedRow = row;
                  selectedCol = col;
                });
              },
              child: Container(
                margin: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: isInvalid ? Colors.red[300] : (isSelected ? Colors.blue[100] : Colors.white), // Vermelho para inválidas
                ),
                child: Center(
                  child: Text(
                    sudokuGrid[row][col] != 0 ? sudokuGrid[row][col].toString() : '',
                    style: TextStyle(fontSize: cellSize * 0.4),
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
          itemCount: 10, // Os números de 0 a 9
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (selectedRow != null && selectedCol != null) {
                  setState(() {
                    sudokuGrid[selectedRow!][selectedCol!] = index; // Atualiza o valor da célula selecionada
                    isValidSudoku(sudokuGrid); // Verifica se o Sudoku é válido e marca células inválidas
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
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
