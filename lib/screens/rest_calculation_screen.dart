import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package
import '../dialogs/shift_plan_dialog.dart';

class RestCalculationScreen extends StatelessWidget {
  final dynamic flightData;
  final Function(Map<String, dynamic>) onShiftPlanCreated;

  RestCalculationScreen({
    required this.flightData,
    required this.onShiftPlanCreated,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? _parseUtcTime(String? utcString) {
      if (utcString == null) return null;
      return DateTime.tryParse(utcString);
    }

    String _formatDuration(Duration duration) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }

    // Function to format DateTime into HH:MM
    String _formatTime(DateTime? dateTime) {
      if (dateTime == null) return 'N/A';
      return DateFormat('HH:mm').format(dateTime);
    }

    var responseData = flightData['response'] ?? {};
    bool isEnRoute = responseData['status'] == 'en-route';
    String? calculatedDuration;
    if (isEnRoute) {
      DateTime? startTime = _parseUtcTime(responseData['utc']);
      DateTime? endTime = _parseUtcTime(responseData['arr_actual_utc']) ??
          _parseUtcTime(responseData['arr_estimated_utc']) ??
          _parseUtcTime(responseData['arr_time_utc']);

      if (startTime != null && endTime != null) {
        Duration duration = endTime.difference(startTime);
        calculatedDuration = _formatDuration(duration);
      }
    }

    var dataWidgets = <Widget>[
      ListTile(
        title: Text("Actual Time UTC"),
        subtitle: Text(_formatTime(_parseUtcTime(responseData['utc']))),
      ),
      ListTile(
        title: Text("Status"),
        subtitle: Text(responseData['status']?.toString() ?? 'N/A'),
      ),
      ListTile(
        title: Text("Flight IATA"),
        subtitle: Text(responseData['flight_iata']?.toString() ?? 'N/A'),
      ),
      ListTile(
        title: Text("Origin"),
        subtitle: Text(responseData['dep_iata']?.toString() ?? 'N/A'),
      ),
      ListTile(
        title: Text("Destination"),
        subtitle: Text(responseData['arr_iata']?.toString() ?? 'N/A'),
      ),
      ListTile(
        title: Text("Airline"),
        subtitle: Text(responseData['airline_name']?.toString() ?? 'N/A'),
      ),
      ListTile(
        title: Text("Calculated Duration"),
        subtitle: Text(calculatedDuration ?? 'N/A'),
      ),
    ];

    Widget buildShiftPlanButton() {
      return isEnRoute
          ? ElevatedButton(
              onPressed: () async {
                Map<String, dynamic>? shiftPlanData =
                    await showShiftPlanDialog(context);
                if (shiftPlanData != null) {
                  onShiftPlanCreated(shiftPlanData);
                }
              },
              child: Text('Make Shiftplan'),
            )
          : Tooltip(
              message: "Flight has to be en-route",
              child: ElevatedButton(
                onPressed: null,
                child: Text('Make Shiftplan'),
              ),
            );
    }

    dataWidgets.add(buildShiftPlanButton());

    return Scaffold(
      body: ListView(
        children: dataWidgets,
      ),
    );
  }
}
