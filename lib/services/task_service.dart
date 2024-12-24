import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Görev ekleme metodu
  Future<void> addTask(String taskName, DateTime dueDate, String tag, String? taskTime) async {
    try {
      await _firestore.collection("tasks").add({
        "name": taskName,                    // Görev adı
        "completed": false,                  // Görev tamamlanmamış
        "dueDate": dueDate.toIso8601String(),// Görev tarihi
        "tag": tag,                          // Etiket
        "taskTime": taskTime,                // Opsiyonel saat bilgisi
        "timestamp": FieldValue.serverTimestamp(), // Zaman damgası
      });

      print("Task added successfully: $taskName");
    } catch (e) {
      print("Error adding task: $e");
    }
  }

  // Görevleri çekmek için stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getTasks() {
    return _firestore
        .collection("tasks")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Görev tamamlama metodu
  Future<void> completeTask(String taskId, String taskName) async {
    try {
      DocumentSnapshot taskSnapshot = await _firestore.collection("tasks").doc(taskId).get();
      final taskData = taskSnapshot.data() as Map<String, dynamic>;
      final dueDate = taskData["dueDate"];
      final tag = taskData["tag"];
      final taskTime = taskData["taskTime"];  // Saat verisini de alıyoruz

      await _firestore.collection("tasks").doc(taskId).delete();
      await _firestore.collection("completed_tasks").add({
        "name": taskName,
        "dueDate": dueDate,
        "tag": tag,
        "taskTime": taskTime, // Saat bilgisi de ekleniyor
        "timestamp": FieldValue.serverTimestamp(),
      });
      print("Task completed successfully: $taskName");
    } catch (e) {
      print("Error completing task: $e");
    }
  }
}
