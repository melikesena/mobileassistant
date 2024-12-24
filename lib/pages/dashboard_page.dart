import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'completed_tasks_page.dart';
import 'profile_page.dart';
import 'google_calendar_page.dart';
import 'package:untitled3/services/task_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'google_mail_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TaskService _taskService = TaskService();

  // Yeni görev eklemek için metod
  void _addTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController taskNameController = TextEditingController();
        DateTime selectedDate = DateTime.now();
        TimeOfDay? selectedTime;
        String? selectedTag; // Seçilen etiket
        bool isTimeSelected = false; // Saat seçimi aktif mi?

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Yeni Görev Oluştur'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Görev adı
                  TextField(
                    controller: taskNameController,
                    decoration: InputDecoration(labelText: 'Görev Adı'),
                  ),
                  SizedBox(height: 10),

                  // Etiket seçimi
                  GestureDetector(
                    onTap: () async {
                      String? newTag = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            title: Text("Etiket Seçin"),
                            children: [
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, 'Personal'),
                                child: Text('Personal'),
                              ),
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, 'Study'),
                                child: Text('Study'),
                              ),
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, 'Work'),
                                child: Text('Work'),
                              ),
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, 'Other'),
                                child: Text('Other'),
                              ),
                            ],
                          );
                        },
                      );
                      if (newTag != null) {
                        setState(() => selectedTag = newTag);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedTag ?? "Etiket Seç",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Tarih seçimi
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() => selectedDate = pickedDate);
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 10),
                        Text("Tarih: ${selectedDate.toLocal()}".split(' ')[0]),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  // "Saat Ekle" checkbox'u
                  CheckboxListTile(
                    title: Text("Saat Ekle"),
                    value: isTimeSelected,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool? value) {
                      setState(() {
                        isTimeSelected = value ?? false;
                        if (!isTimeSelected) selectedTime = null; // Saat seçimini sıfırla
                      });
                    },
                  ),

                  SizedBox(height: 10),

                  // Saat ekleme butonu (saat ekle seçiliyse görünür)
                  if (isTimeSelected)
                    TextButton(
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() => selectedTime = pickedTime);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.access_time),
                          SizedBox(width: 10),
                          Text(
                            selectedTime != null
                                ? "Saat: ${selectedTime!.format(context)}"
                                : "Saat Seç",
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (taskNameController.text.isNotEmpty && selectedTag != null) {
                      await _taskService.addTask(
                        taskNameController.text, // Görev adı
                        selectedDate,            // Tarih
                        selectedTag!,            // Etiket
                        selectedTime != null ? selectedTime!.format(context) : null, // Saat (varsa)
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Ekle'),
                ),
              ],
            );
          },
        );
      },
    );
  }






  // Görevi tamamlanmış olarak işaretleme metodu
  Future<void> _completeTask(String taskId, String taskName) async {
    try {
      await _taskService.completeTask(taskId, taskName);
    } catch (e) {
      print("Error completing task: $e");
    }
  }

  // Çıkış yapma fonksiyonu
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("Dashboard"),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Profil menüsünü aç
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Profil Menüsü"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text("Profilim"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            title: Text("Tamamlanmış Görevler"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompletedTasksPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/profile.jpg"), // Profil resmi
                backgroundColor: Colors.grey[300], // Yedek renk
              ),
            ),
          ),
        ],
      ),
// Drawer menüsüne Google Mail ekleyin
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text(
                "Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.mail),
              title: Text("Google Mail"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoogleMailIntegrationPage(), // Google Mail sayfasına yönlendir
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text("Google Calendar"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoogleCalendarIntegrationPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Ayarlar"),
              onTap: () {
                // Ayarlar sayfasına yönlendirme
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Çıkış Yap"),
              onTap: _signOut,
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: _taskService.getTasks(), // TaskService'den stream alınıyor
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text("Henüz bir görev eklenmedi."),
              );
            }

            final tasks = snapshot.data!.docs;

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final taskName = task["name"] ?? "Görev adı belirtilmemiş";
                return ListTile(
                  title: Text(taskName),
                  trailing: IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () {
                      _completeTask(task.id, taskName); // Görev tamamla
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
      ),
    );
  }
}