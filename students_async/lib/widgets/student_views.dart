import 'package:flutter/material.dart';
import '../api/fake_api.dart';

// Состояние 1: Ошибка
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Could not load students'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// Состояние 2: Загрузка
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading students...'),
        ],
      ),
    );
  }
}

// Состояние 3: Пусто
class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No students yet'));
  }
}

// Состояние 4: Данные
class StudentList extends StatelessWidget {
  const StudentList(this.students, {super.key, this.compact = false});
  final List<Student> students;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final s = students[index];
        // если gpa null, =  '—'
        return ListTile(
          dense: compact,
          title: Text(s.name),
          subtitle: Text(s.group),
          trailing: Text(s.gpa?.toString() ?? '—'),
        );
      },
    );
  }
}
