import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting.
import '../dialogs/shift_plan_dialog.dart';

class RestCalculationScreen extends StatelessWidget {
  final dynamic flightData; // Flight data received from previous screen.
  final Function(Map<String, dynamic>) onShiftPlanCreated; // Function to handle shift plan creation.

  RestCalculationScreen({
    required this.flightData,
    required this.onShiftPlanCreated,
  });

  Widget _statusLabel(String? status) {
    Color color;
    switch (status) {
      case 'landed':
        color = Colors.yellow;
        break;
      case 'scheduled':
        color = Colors.blue;
        break;
      case 'en-route':
        color = Colors.green;
        break;
      default:
        color = Colors.grey; // Default color for other statuses or null
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: color,
      child: Text(
        status?.toUpperCase() ?? 'N/A',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  DateTime? _parseUtcTime(String? utcString) {
    if (utcString == null) return null;
    return DateTime.tryParse(utcString);
  }

  String _formatDuration(Duration duration) {
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('HH:mm').format(dateTime);
  }

  TableRow _buildTableRow(String label, Widget value) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: value,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var responseData = flightData['response'] ?? {};

    DateTime? departureTime = _parseUtcTime(responseData['dep_actual_utc']) ??
                              _parseUtcTime(responseData['dep_estimated_utc']) ??
                              _parseUtcTime(responseData['dep_time_utc']);

    DateTime? arrivalTime = _parseUtcTime(responseData['arr_actual_utc']) ??
                            _parseUtcTime(responseData['arr_estimated_utc']) ??
                            _parseUtcTime(responseData['arr_time_utc']);

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

    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.yellow,
            padding: EdgeInsets.all(10),
            child: Text(
              "The actual version displays all times in UTC",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: [
              _buildTableRow("Actual Time UTC", Text(_formatTime(departureTime))),
              _buildTableRow("Status", _statusLabel(responseData['status']?.toString())),
              _buildTableRow("Flight IATA", Text(responseData['flight_iata']?.toString() ?? 'N/A')),
              _buildTableRow("Origin", Text(responseData['dep_iata']?.toString() ?? 'N/A')),
              _buildTableRow("Destination", Text(responseData['arr_iata']?.toString() ?? 'N/A')),
              _buildTableRow("Airline", Text(responseData['airline_name']?.toString() ?? 'N/A')),
              _buildTableRow("Departure Time", Text(_formatTime(departureTime))),
              _buildTableRow("Arrival Time", Text(_formatTime(arrivalTime))),
              _buildTableRow("Calculated Duration", Text(calculatedDuration ?? 'N/A')),
            ],
          ),
          isEnRoute ? ElevatedButton(
            onPressed: () async {
              Map<String, dynamic>? shiftPlanData =
                  await showShiftPlanDialog(context);
              if (shiftPlanData != null) {
                onShiftPlanCreated(shiftPlanData);
              }
            },
            child: Text('Make Shiftplan'),
          ) : Tooltip(
            message: "Flight has to be en-route",
            child: ElevatedButton(
              onPressed: null,
              child: Text('Make Shiftplan'),
            ),
          ),
        ],
      ),
    );
  }
}
