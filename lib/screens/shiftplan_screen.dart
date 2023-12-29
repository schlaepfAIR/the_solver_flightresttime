import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package
import '../services/shiftplancalculator.dart';

class ShiftplanScreen extends StatelessWidget {
  final dynamic flightData;
  final Map<String, dynamic> shiftPlanData;

  ShiftplanScreen({
    required this.shiftPlanData,
    required this.flightData,
  });

  @override
  Widget build(BuildContext context) {
    // Function to format DateTime into HH:MM
    String _formatTime(DateTime? dateTime) {
      if (dateTime == null) return 'N/A';
      return DateFormat('HH:mm').format(dateTime);
    }

    // Function to format Duration
    String _formatDuration(Duration duration) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }

    // Extracting data and using ShiftPlanCalculator for calculations
    var responseData = flightData['response'] ?? {};
    DateTime? startTime = ShiftPlanCalculator.parseUtcTime(responseData['utc']);
    DateTime? endTime = ShiftPlanCalculator.parseUtcTime(
            responseData['arr_actual_utc']) ??
        ShiftPlanCalculator.parseUtcTime(responseData['arr_estimated_utc']) ??
        ShiftPlanCalculator.parseUtcTime(responseData['arr_time_utc']);

    Duration nettoShiftDuration =
        ShiftPlanCalculator.calculateNettoShiftDuration(startTime, endTime,
            shiftPlanData['startRestPeriod'], shiftPlanData['endRestPeriod']);
    String nettoShiftTime = _formatDuration(nettoShiftDuration);

    List<Widget> buildShiftSchedule() {
      List<Widget> shiftWidgets = [];
      Duration shiftDurationWithoutOverlap =
          nettoShiftDuration ~/ shiftPlanData['numberOfShifts'];
      Duration overlapDuration =
          Duration(minutes: shiftPlanData['overlapMinutes']);

      DateTime? currentShiftStart =
          startTime?.add(Duration(minutes: shiftPlanData['startRestPeriod']));
      DateTime? endRestPeriod = endTime?.subtract(
          Duration(minutes: shiftPlanData['endRestPeriod']));

      for (int i = 0; i < shiftPlanData['numberOfShifts']; i++) {
        if (currentShiftStart != null && endRestPeriod != null) {
          DateTime shiftEnd =
              currentShiftStart.add(shiftDurationWithoutOverlap);

          // Ensure shift end does not exceed 'End of Rest Period'
          if (shiftEnd.isAfter(endRestPeriod)) {
            shiftEnd = endRestPeriod;
          }

          shiftWidgets.add(Text(
              'Shift ${i + 1}: ${_formatTime(currentShiftStart)} - ${_formatTime(shiftEnd)}'));

          // Prepare the start of the next shift
          currentShiftStart = shiftEnd.add(overlapDuration);

          // Break the loop if the next shift start exceeds 'End of Rest Period'
          if (currentShiftStart.isAfter(endRestPeriod)) {
            break;
          }
        }
      }
      return shiftWidgets;
    }

    Widget sectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
    }

    Widget flightInformationSection() {
      return Card(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Flight IATA'),
              subtitle:
                  Text('${responseData['flight_iata']?.toString() ?? 'N/A'}'),
            ),
            ListTile(
              title: Text('Origin'),
              subtitle:
                  Text('${responseData['dep_iata']?.toString() ?? 'N/A'}'),
            ),
            ListTile(
              title: Text('Destination'),
              subtitle:
                  Text('${responseData['arr_iata']?.toString() ?? 'N/A'}'),
            ),
            ListTile(
              title: Text('Airline'),
              subtitle:
                  Text('${responseData['airline_name']?.toString() ?? 'N/A'}'),
            ),
            ListTile(
              title: Text('Status'),
              subtitle: Text('${responseData['status']?.toString() ?? 'N/A'}'),
            ),
          ],
        ),
      );
    }

    Widget timeInformationSection() {
      return Card(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Actual Time'),
              subtitle: Text(_formatTime(startTime)),
            ),
            ListTile(
              title: Text('Start of Rest Period'),
              subtitle: Text(_formatTime(startTime
                  ?.add(Duration(minutes: shiftPlanData['startRestPeriod'])))),
            ),
            ListTile(
              title: Text('End of Rest Period'),
              subtitle: Text(_formatTime(endTime?.subtract(
                  Duration(minutes: shiftPlanData['endRestPeriod'])))),
            ),
            ListTile(
              title: Text('Netto Shift Time'),
              subtitle: Text(nettoShiftTime),
            ),
          ],
        ),
      );
    }

    Widget shiftPlanSection() {
      return Card(
        child: Column(
          children: [
            ...buildShiftSchedule()
                .map((shift) => ListTile(title: shift))
                .toList(),
          ],
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            sectionTitle('Shift Plan'),
            shiftPlanSection(),
            sectionTitle('Time Information'),
            timeInformationSection(),
            sectionTitle('Flight Information'),
            flightInformationSection(),
          ],
        ),
      ),
    );
  }
}
