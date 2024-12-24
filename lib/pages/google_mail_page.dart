import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GoogleMailIntegrationPage extends StatefulWidget {
  @override
  _GoogleMailIntegrationPageState createState() =>
      _GoogleMailIntegrationPageState();
}

class _GoogleMailIntegrationPageState
    extends State<GoogleMailIntegrationPage> {
  final _clientID =
      "447841275382-l0aan9ljg9gon6gjg4nrhglkmt166erg.apps.googleusercontent.com"; // Google Cloud'dan aldığınız istemci kimliği
  final _scopes = ['https://www.googleapis.com/auth/gmail.readonly'];

  gmail.GmailApi? _gmailApi;
  List<gmail.Message> _messages = [];

  Future<void> _authenticate() async {
    try {
      final clientId = ClientId(_clientID, null);

      // Kullanıcıyı kimlik doğrulama için tarayıcıya yönlendir
      await clientViaUserConsent(clientId, _scopes, _prompt)
          .then((AuthClient client) {
        setState(() {
          _gmailApi = gmail.GmailApi(client); // Doğru istemciyi kullan
        });
        _fetchMessages(); // Mesajları al
      });
    } catch (e) {
      print("Authentication failed: $e");
    }
  }

  void _prompt(String? url) async {
    if (url == null || url.isEmpty) {
      print("Authorization URL is empty");
      return;
    }

    final Uri uri = Uri.parse(url);

    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print("URL launched: $url");
    } else {
      print("Could not launch URL: $url");
    }
  }

  Future<void> _fetchMessages() async {
    if (_gmailApi == null) return;

    try {
      final messages = await _gmailApi!.users.messages.list(
        'me',
        q: "subject:'Microsoft Teams' OR 'teams.microsoft.com'", // Teams ile ilgili e-postaları filtrele
      );

      setState(() {
        _messages = messages.messages ?? [];
      });
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Mail Integration"),
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
            _messages.isEmpty
                ? Text("No relevant emails found.")
                : Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ListTile(
                    title: Text("Message ID: ${message.id}"),
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
