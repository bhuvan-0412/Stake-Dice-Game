import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const DiceGameApp());
}

class DiceGameApp extends StatelessWidget {
  const DiceGameApp({super.key}); // Use super.key here

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DiceGameHome(),
    );
  }
}

class DiceGameHome extends StatefulWidget {
  const DiceGameHome({super.key});

  @override
  DiceGameHomeState createState() => DiceGameHomeState();
}

class DiceGameHomeState extends State<DiceGameHome> {
  int walletBalance = 10;
  int wager = 0;
  String selectedGameType = '2 Alike';
  final TextEditingController wagerController = TextEditingController();

  void rollDice() {
    Random random = Random();
    List<int> diceResults = List.generate(4, (_) => random.nextInt(6) + 1);

    Map<int, int> countMap = {};
    for (var result in diceResults) {
      countMap[result] = (countMap[result] ?? 0) + 1;
    }

    bool win = false;
    int multiplier = 0;

    if (countMap.values.contains(4)) {
      multiplier = 4; // 4 Alike
    } else if (countMap.values.contains(3)) {
      multiplier = 3; // 3 Alike
    } else if (countMap.values.contains(2)) {
      multiplier = 2; // 2 Alike
    }

    if (multiplier > 0) {
      win = true;
      walletBalance += wager * multiplier;
    } else {
      win = false;
      walletBalance -= wager;
    }

    String resultMessage = 'Dice: ${diceResults.join(', ')}\n'
        '${win ? "You win!" : "You lose!"}';

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(resultMessage)));

    // Clear wager input
    wagerController.clear();
    wager = 0;
  }

  bool isWagerValid() {
    if (wager <= 0) return false;
    switch (selectedGameType) {
      case '2 Alike':
        return wager <= walletBalance / 2;
      case '3 Alike':
        return wager <= walletBalance / 3;
      case '4 Alike':
        return wager <= walletBalance / 4;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dice Game')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Wallet Balance: $walletBalance coins',
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            TextField(
              controller: wagerController,
              decoration: const InputDecoration(
                labelText: 'Enter wager',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                wager = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedGameType,
              items: <String>['2 Alike', '3 Alike', '4 Alike']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGameType = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isWagerValid()) {
                  rollDice();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid wager!')),
                  );
                }
              },
              child: const Text('Go'),
            ),
          ],
        ),
      ),
    );
  }
}
