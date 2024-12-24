import 'package:flutter/material.dart';
import 'pages/login_page.dart';  // LoginPage'in olduğu dosyayı içe aktarın
import 'pages/dashboard_page.dart'; // DashboardPage'in olduğu dosyayı içe aktarın
import 'package:firebase_core/firebase_core.dart';  // Firebase Core importu ekleyin
import 'package:untitled3/pages/google_calendar_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Flutter'ın başlatılmasını bekler.
  await Firebase.initializeApp();  // Firebase'i başlatıyoruz.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wellness To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: LoginPage(), // Ana sayfa olarak LoginPage tanımlandı.
    );
  }
}
