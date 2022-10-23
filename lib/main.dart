import 'package:flutter/material.dart';
import 'dart:math';
import 'package:quiver/iterables.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }
}

class _body extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _bodyState();
  }
}

class _bodyState extends State<_body> {
  List<BoxInner> boxInners = [];
  FocusClass focusClass = FocusClass();
  bool isFinish = false;
  String? tapBoxIndex;

  @override
  void initState() {
    generateSudoku();
    super.initState();
  }

  void generateSudoku() {
    isFinish = false;
    focusClass = FocusClass();
    tapBoxIndex = null;
    generatePuzzle();
    checkFinish();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sudoku'),
        actions: [
          ElevatedButton(
              onPressed: () => generateSudoku(),
              child: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                child: GridView.builder(
                  itemCount: boxInners.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (buildContext, index) {
                    BoxInner boxInner = boxInners[index];
                    return Container(
                      color: Colors.red.shade100,
                      alignment: Alignment.center,
                      child: GridView.builder(
                        itemCount: boxInner.blokChars.length,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemBuilder: (buildContext, indexChar) {
                          BlokChar blokChar = boxInner.blokChars[indexChar];
                          Color color = Colors.white;
                          Color colorText = Colors.black;

                          if (isFinish) {
                            color = Colors.green;
                          } else if (blokChar.isFocus && blokChar.text != "") {
                            color = Colors.brown.shade100;
                          } else if (blokChar.isDefault) {
                            color = Colors.grey.shade400;
                          }

                          if (tapBoxIndex == "$index-$indexChar" && !isFinish) {
                            color = Colors.blue.shade100;
                          }

                          if (isFinish) {
                            colorText = Colors.white;
                          } else if (blokChar.isExist) {
                            colorText = Colors.red;
                          }

                          return Container(
                            color: color,
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: blokChar.isDefault
                                  ? null
                                  : () => setFocus(index, indexChar),
                              child: Text(
                                "${blokChar.text}",
                                style: TextStyle(color: colorText),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        child: GridView.builder(
                          itemCount: 9,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemBuilder: (buildContext, index) {
                            return ElevatedButton(
                              onPressed: () => setInput(index + 1),
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(color: Colors.black),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  generatePuzzle() {
    boxInners.clear();
    var sudokuGenerator = SudokuGenerator(emptySquares: 8); //54

    List<List<List<int>>> completes = partition(sudokuGenerator.newSudokuSolved,
            sqrt(sudokuGenerator.newSudoku.length).toInt())
        .toList();
    partition(sudokuGenerator.newSudoku,
            sqrt(sudokuGenerator.newSudoku.length).toInt())
        .toList()
        .asMap()
        .entries
        .forEach(
      (entry) {
        List<int> tempListCompletes =
            completes[entry.key].expand((element) => element).toList();
        List<int> tempList = entry.value.expand((element) => element).toList();

        tempList.asMap().entries.forEach((entryIn) {
          int index =
              entry.key * sqrt(sudokuGenerator.newSudoku.length).toInt() +
                  (entryIn.key % 9).toInt() ~/ 3;

          if (boxInners.where((element) => element.index == index).isEmpty) {
            boxInners.add(BoxInner(index, []));
          }

          BoxInner boxInner =
              boxInners.where((element) => element.index == index).first;

          boxInner.blokChars.add(BlokChar(
            entryIn.value == 0 ? "" : entryIn.value.toString(),
            index: boxInner.blokChars.length,
            isDefault: entryIn.value != 0,
            isCorrect: entryIn.value != 0,
            correctText: tempListCompletes[entryIn.key].toString(),
          ));
        });
      },
    );

  }

  setFocus(int index, int indexChar) {
    tapBoxIndex = "$index-$indexChar";
    focusClass.setData(index, indexChar);
    showFocusCenterLine();
    setState(() {});
  }

  void showFocusCenterLine() {
    int rowNoBox = focusClass.indexBox! ~/ 3;
    int colNoBox = focusClass.indexBox! % 3;

    for (var element in boxInners) {
      element.clearFocus();
    }

    boxInners.where((element) => element.index ~/ 3 == rowNoBox).forEach(
        (e) => e.setFocus(focusClass.indexChar!, Direction.Horizontal));

    boxInners
        .where((element) => element.index % 3 == colNoBox)
        .forEach((e) => e.setFocus(focusClass.indexChar!, Direction.Vertical));
  }

  setInput(int? number) {

    if (focusClass.indexBox == null) return;
    if (boxInners[focusClass.indexBox!].blokChars[focusClass.indexChar!].text ==
            number.toString() ||
        number == null) {
      for (var element in boxInners) {
        element.clearFocus();
        element.clearExist();
      }
      boxInners[focusClass.indexBox!]
          .blokChars[focusClass.indexChar!]
          .setEmpty();
      tapBoxIndex = null;
      isFinish = false;
      showSameInputOnSameLine();
    } else {
      boxInners[focusClass.indexBox!]
          .blokChars[focusClass.indexChar!]
          .setText("$number");

      showSameInputOnSameLine();

      checkFinish();
    }

    setState(() {});
  }

  void showSameInputOnSameLine() {

    int rowNoBox = focusClass.indexBox! ~/ 3;
    int colNoBox = focusClass.indexBox! % 3;

    String textInput =
        boxInners[focusClass.indexBox!].blokChars[focusClass.indexChar!].text!;

    for (var element in boxInners) {
      element.clearExist();
    }

    boxInners.where((element) => element.index ~/ 3 == rowNoBox).forEach((e) =>
        e.setExistValue(focusClass.indexChar!, focusClass.indexBox!, textInput,
            Direction.Horizontal));

    boxInners.where((element) => element.index % 3 == colNoBox).forEach((e) =>
        e.setExistValue(focusClass.indexChar!, focusClass.indexBox!, textInput,
            Direction.Vertical));

    List<BlokChar> exists = boxInners
        .map((element) => element.blokChars)
        .expand((element) => element)
        .where((element) => element.isExist)
        .toList();

    if (exists.length == 1) exists[0].isExist = false;
  }

  void checkFinish() {
    int totalUnfinish = boxInners
        .map((e) => e.blokChars)
        .expand((element) => element)
        .where((element) => !element.isCorrect)
        .length;

    isFinish = totalUnfinish == 0;
  }
}

class BoxInner {
  late int index;
  List<BlokChar> blokChars = List<BlokChar>.from([]);

  BoxInner(this.index, this.blokChars);

  setFocus(int index, Direction direction) {
    List<BlokChar> temp;

    if (direction == Direction.Horizontal) {
      temp = blokChars
          .where((element) => element.index! ~/ 3 == index ~/ 3)
          .toList();
    } else {
      temp = blokChars
          .where((element) => element.index! % 3 == index % 3)
          .toList();
    }

    for (var element in temp) {
      element.isFocus = true;
    }
  }

  setExistValue(
      int index, int indexBox, String textInput, Direction direction) {
    List<BlokChar> temp;

    if (direction == Direction.Horizontal) {
      temp = blokChars
          .where((element) => element.index! ~/ 3 == index ~/ 3)
          .toList();
    } else {
      temp = blokChars
          .where((element) => element.index! % 3 == index % 3)
          .toList();
    }

    if (this.index == indexBox) {
      List<BlokChar> blokCharsBox =
          blokChars.where((element) => element.text == textInput).toList();

      if (blokCharsBox.length == 1 && temp.isEmpty) blokCharsBox.clear();

      temp.addAll(blokCharsBox);
    }

    temp.where((element) => element.text == textInput).forEach((element) {
      element.isExist = true;
    });
  }

  clearFocus() {
    for (var element in blokChars) {
      element.isFocus = false;
    }
  }

  clearExist() {
    for (var element in blokChars) {
      element.isExist = false;
    }
  }
}

enum Direction { Horizontal, Vertical }

class FocusClass {
  int? indexBox;
  int? indexChar;

  setData(int indexBox, int indexChar) {
    this.indexBox = indexBox;
    this.indexChar = indexChar;
  }

  focusOn(int indexBox, int indexChar) {
    return this.indexBox == indexBox && this.indexChar == indexChar;
  }
}

class BlokChar {
  String? text;
  String? correctText;
  int? index;
  bool isFocus = false;
  bool isCorrect;
  bool isDefault;
  bool isExist = false;

  BlokChar(
    this.text, {
    this.index,
    this.isDefault = false,
    this.correctText,
    this.isCorrect = false,
  });

  get isCorrectPos => correctText == text;
  setText(String text) {
    this.text = text;
    isCorrect = isCorrectPos;
  }

  setEmpty() {
    text = "";
    isCorrect = false;
  }
}
