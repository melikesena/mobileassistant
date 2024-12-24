import 'package:flutter/material.dart';

class TaskDetailsPage extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onComplete;

  TaskDetailsPage({required this.task, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Görev Detayları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Görev Adı: ${task['name']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Tarih: ${task['date']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onComplete();
                Navigator.pop(context);
              },
              child: Text('Görevi Tamamla'),
            ),
          ],
        ),
      ),
    );
  }
}
