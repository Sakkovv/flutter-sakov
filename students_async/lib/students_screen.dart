import 'dart:async';
import 'package:flutter/material.dart';
import 'api/fake_api.dart';
import 'widgets/student_views.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students; //null = еще не загружено
  Object? _error; //не null = ошибка
  final _api = FakeApi();

  @override
  void initState() {
    super.initState();

    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });

    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students (By Hand)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return ErrorView(onRetry: _load);
    }
    if (_students == null) {
      return const LoadingView();
    }
    if (_students!.isEmpty) {
      return const EmptyView();
    }
    return StudentList(_students!);
  }
}
