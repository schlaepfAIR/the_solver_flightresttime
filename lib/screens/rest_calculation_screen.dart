// Import statements for using Flutter material components and formatting dates.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting.
import '../dialogs/shift_plan_dialog.dart';

// RestCalculationScreen class - a StatelessWidget for calculating rest times.
class RestCalculationScreen extends StatelessWidget {
  final dynamic flightData; // Flight data received from previous screen.
  final Function(Map<String, dynamic>) onShiftPlanCreated; // Function to handle shift plan creation.

  // Constructor for RestCalculationScreen with required parameters.
  RestCalculationScreen({
    required this.flightData,
    required this.onShiftPlanCreated,
  });

  @override
  Widget build(BuildContext context) {
    // Private function to parse UTC time string to DateTime.
    DateTime? _parseUtcTime(String? utcString) {
      if (utcString == null) return null;
      return DateTime.tryParse(utcString);
    }

    // Private function to format Duration into Hours and Minutes.
    String _formatDuration(Duration duration) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }

    // Private function to format DateTime into HH:MM format.
    String _formatTime(DateTime? dateTime) {
      if (dateTime == null) return 'N/A';
      return DateFormat('HH:mm').format(dateTime);
    }

    // Extracting response data from flightData.
    var responseData = flightData['response'] ?? {};
    bool isEnRoute = responseData['status'] == 'en-route'; // Check if the flight is en-route.
    String? calculatedDuration;
    if (isEnRoute) {
      // Calculating duration if the flight is en-route.
      DateTime? startTime = _parseUtcTime(responseData['utc']);
      DateTime? endTime = _parseUtcTime(responseData['arr_actual_utc']) ??
          _parseUtcTime(responseData['arr_estimated_utc']) ??
          _parseUtcTime(responseData['arr_time_utc']);

      if (startTime != null && endTime != null) {
        Duration duration = endTime.difference(startTime);
        calculatedDuration = _formatDuration(duration);
      }
    }

    // List of widgets displaying the flight data.
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

    // Function to build the shift plan button.
    Widget buildShiftPlanButton() {
      return isEnRoute
          ? ElevatedButton(
              onPressed: () async {
                Map<String, dynamic>? shiftPlanData =
                    await showShiftPlanDialog(context);
                if (shiftPlanData != null) {
                  onShiftPlanCreated(shiftPlanData); // Triggering shift plan creation callback.
                }
              },
              child: Text('Make Shiftplan'),
            )
          : Tooltip(
              message: "Flight has to be en-route",
              child: ElevatedButton(
                onPressed: null, // Disabled button when flight is not en-route.
                child: Text('Make Shiftplan'),
              ),
            );
    }

    // Adding the shift plan button to the list of widgets.
    dataWidgets.add(buildShiftPlanButton());

    // Returning a Scaffold with a ListView containing all data widgets.
    return Scaffold(
      body: ListView(
        children: dataWidgets,
      ),
    );
  }
}
