import 'dart:developer';

import 'package:calc/db/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String answer = "";
  String input = "0";
  List<String> previousCalculations = [];
  bool switchValue = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadThemePreference();
    log(switchValue.toString());
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        input = "0";
        answer = "";
      } else if (value == "<") {
        input = input.length > 1 ? input.substring(0, input.length - 1) : "0";
      } else if (value == "=") {
        try {
          Parser p = Parser();
          Expression exp = p.parse(input.replaceAll('x', '*'));
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          answer = eval.toString();

          previousCalculations
              .add('$input = $answer'); // Add the new calculation

          input = answer;
        } catch (e) {
          answer = "Error";
        }
      } else if (value == "AC") {
        input = "0";
        answer = "";
      } else {
        if (input == "0") {
          input = value;
        } else {
          input += value;
        }
      }
    });
  }

  void _loadThemePreference() async {
    final dbHelper = DBHelper.instance;
    List<UiTheme> themeList = await dbHelper.getTheme();
    if (themeList.isNotEmpty) {
      setState(() {
        switchValue = themeList.last.switchValue;
      });
    }
  }

  void _toggleTheme(bool value) async {
    setState(() {
      switchValue = value;
    });
    final dbHelper = DBHelper.instance;
    await dbHelper.themeChange(UiTheme(switchValue: value));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: !switchValue ? ThemeMode.light : ThemeMode.dark,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: !switchValue
                ? const Color(0xfffafafa)
                : const Color(0xff1d1d1d),
            title: Text(
              "Calculator",
              style: GoogleFonts.manrope(
                textStyle: TextStyle(
                  color: !switchValue ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.1,
                ),
              ),
            ),
            toolbarHeight: 80,
            backgroundColor: !switchValue
                ? const Color(0xfffafafa)
                : const Color(0xff1d1d1d),
            actions: [
              IconButton(
                onPressed: () {
                  _toggleTheme(!switchValue);
                },
                icon: Icon(
                  !switchValue ? Icons.dark_mode_rounded : Icons.light_mode,
                ),
              )
            ],
          ),
          backgroundColor:
              !switchValue ? const Color(0xfffafafa) : const Color(0xff1d1d1d),
          body: Column(
            children: [
              //Display
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
                height: MediaQuery.of(context).size.height * 0.30 - 104,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: previousCalculations
                          .map((calc) => Text(
                                calc,
                                style: GoogleFonts.manrope(
                                  textStyle: TextStyle(
                                    color: !switchValue
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.white.withOpacity(0.3),
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 15, bottom: 15),
                height: MediaQuery.of(context).size.height * 0.1,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    input,
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !switchValue ? Colors.black : Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.1,
                      ),
                    ),
                  ),
                ),
              ),

              //Buttons
              Container(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: !switchValue ? const Color(0xfff2f3f7) : Colors.black,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _button("C", Colors.black),
                        _button("%", Colors.black),
                        _button("/", Colors.black),
                        _button("<", Colors.black),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _button("7", Colors.black),
                        _button("8", Colors.black),
                        _button("9", Colors.black),
                        _button("x", Colors.black),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _button("4", Colors.black),
                        _button("5", Colors.black),
                        _button("6", Colors.black),
                        _button("+", Colors.black),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _button("1", Colors.black),
                        _button("2", Colors.black),
                        _button("3", Colors.black),
                        _button("-", Colors.black),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _button("0", Colors.black),
                        _button(".", Colors.black),
                        _button("=", Colors.black),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(String value, Color? color) {
    return GestureDetector(
      onTap: () {
        _onButtonPressed(value);
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: value == "0"
            ? MediaQuery.of(context).size.width / 2 - 30
            : MediaQuery.of(context).size.width / 4 - 30,
        height: MediaQuery.of(context).size.width / 5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value == "x" ||
                  value == "+" ||
                  value == "=" ||
                  value == "-" ||
                  value == "<" ||
                  value == "C" ||
                  value == "%" ||
                  value == "/"
              ? !switchValue
                  ? const Color(0xffdce5f5)
                  : const Color.fromARGB(255, 173, 181, 193)
              : !switchValue
                  ? const Color(0xfffafafa)
                  : const Color(0xff1d1d1d),
        ),
        child: Center(
          child: Text(
            value,
            style: GoogleFonts.epilogue(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: !switchValue ? color : Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.08,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
