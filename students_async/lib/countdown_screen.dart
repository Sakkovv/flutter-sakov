import 'dart:async';
import 'package:flutter/material.dart';
import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();

    _sub = countdown(10).listen((i) {
      setState(() => _left = i);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StreamBuilder<int>(
              stream: countdown(10),
              builder: (context, snapshot) {
                final val = snapshot.data ?? 10;
                return Text(
                  'StreamBuilder: $val',
                  style: Theme.of(context).textTheme.displayLarge,
                );
              },
            ),
            Text(
              'Listen: $_left',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ],
        ),
      ),
    );
  }
}
