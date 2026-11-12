import 'package:flutter/material.dart';
import 'students_screen.dart';
import 'students_future_screen.dart';
import 'countdown_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Кнопка 1: By hand (Level 2)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentsScreen()),
                );
              },
              child: const Text('By hand'),
            ),
            const SizedBox(height: 16), // Небольшой отступ между кнопками
            // Кнопка 2: FutureBuilder (Level 3)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentsFutureScreen(),
                  ),
                );
              },
              child: const Text('FutureBuilder'),
            ),

            const SizedBox(height: 16),
            // Кнопка 3: Countdown (Level 4)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CountdownScreen()),
                );
              },
              child: const Text('Countdown'),
            ),
          ],
        ),
      ),
    );
  }
}
