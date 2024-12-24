import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore için gerekli import

class CompletedTasksPage extends StatelessWidget {
  const CompletedTasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Firestore'dan tamamlanmış görevleri çekmek için StreamBuilder kullanıyoruz
    return Scaffold(
      appBar: AppBar(
        title: Text('Tamamlanmış Görevler'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('completed_tasks') // Tamamlanmış görevler koleksiyonu
            .orderBy('timestamp', descending: true) // En son tamamlananları önce göster
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Henüz tamamlanmış bir görev yok.'));
          }

          final completedTasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
              final taskName = task['name'] ?? 'Görev adı belirtilmemiş';
              final timestamp = task['timestamp'] as Timestamp?;

              // Zamanı okunabilir bir formata dönüştür
              final completedDate = timestamp != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                  timestamp.millisecondsSinceEpoch)
                  : null;

              return ListTile(
                title: Text(taskName),
                subtitle: Text(
                  completedDate != null
                      ? 'Tamamlandı: ${completedDate.toLocal()}'
                      : 'Tamamlanma tarihi belirtilmemiş',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
