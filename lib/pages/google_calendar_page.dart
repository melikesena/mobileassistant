import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:googleapis_auth/auth_io.dart'; // clientViaUserConsent için gerekli


class GoogleCalendarIntegrationPage extends StatefulWidget {
  @override
  _GoogleCalendarIntegrationPageState createState() =>
      _GoogleCalendarIntegrationPageState();
}

class _GoogleCalendarIntegrationPageState
    extends State<GoogleCalendarIntegrationPage> {
  final _clientID = "***.apps.googleusercontent.com"; // Google Cloud'dan aldığınız istemci kimliği
  final _clientSecret = "***"; // Google Cloud'dan aldığınız istemci gizli anahtarı

  late AuthClient _authClient;
  List<calendar.Event> _events = []; // Etkinlikleri tutmak için bir liste

  // Kullanıcıyı yetkilendirmek için OAuth işlemi
  Future<void> _authenticate() async {
    try {
      final identifier = ClientId(_clientID, _clientSecret);
      final scopes = [calendar.CalendarApi.calendarScope];

      // Kullanıcıdan yetki istemek için tarayıcıda oturum aç
      await clientViaUserConsent(identifier, scopes, _prompt)
          .then((AuthClient client) {
        setState(() {
          _authClient = client;
        });
        _fetchEvents();
      });
    } catch (e) {
      print("Authentication failed: $e");
    }
  }

  void _prompt(String? url) async {
    if (url == null || url.isEmpty) {
      print("URL is null or empty");
      return;
    }

    final Uri uri = Uri.parse(url); // URL'yi Uri nesnesine dönüştürün
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print("URL launched: $url");
    } else {
      print("Could not launch URL: $url");
    }
  }

  // Google Takvimi'nden etkinlikleri almak
  Future<void> _fetchEvents() async {
    try {
      final calendarApi = calendar.CalendarApi(_authClient);
      final events = await calendarApi.events.list("primary"); // "primary" ana takvimi temsil eder

      setState(() {
        _events = events.items ?? []; // Etkinlikleri al ve listeye aktar
      });
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  // Widget'ı build etmek için
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Calendar Integration"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _authenticate,
              child: Text("Authenticate with Google"),
            ),
            SizedBox(height: 20),
            _events.isEmpty
                ? Text("No events found.")
                : Expanded(
              child: ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return ListTile(
                    title: Text(event.summary ?? "No title"),
                    subtitle: Text(
                        "Start: ${event.start?.dateTime?.toLocal()}"), // Tarihi yerel saate dönüştür
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
