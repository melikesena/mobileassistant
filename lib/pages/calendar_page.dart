import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now(); // Seçilen gün
  DateTime _focusedDay = DateTime.now(); // Takvimde odaklanılan gün

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Takvim"),
        backgroundColor: Colors.teal, // Uygulamanın temasına uygun
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1), // Takvimin başlangıç tarihi
              lastDay: DateTime.utc(2030, 12, 31), // Takvimin bitiş tarihi
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.teal, // Bugünün rengi
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.pink[200], // Seçilen günün rengi
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false, // Ay dışındaki günleri gizler
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // Ayarlama düğmesini gizler
                titleCentered: true, // Ay başlığını ortalar
              ),
            ),
            SizedBox(height: 20),
            if (_selectedDay != null)
              Text(
                "Seçilen Gün: ${_selectedDay.toLocal().toString().split(' ')[0]}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
