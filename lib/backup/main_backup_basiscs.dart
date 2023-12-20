// this version includes basics, flight api request, response and dialog
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FlightInfoTabView(),
    );
  }
}

class FlightInfoTabView extends StatefulWidget {
  const FlightInfoTabView({super.key});

  @override
  _FlightInfoTabViewState createState() => _FlightInfoTabViewState();
}

class _FlightInfoTabViewState extends State<FlightInfoTabView> {
  final TextEditingController _flightNumberController = TextEditingController();
  Map<String, dynamic> _apiResponse = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Info App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _flightNumberController,
              decoration: const InputDecoration(labelText: 'Enter Flight Number'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchFlightInfo,
              child: const Text('Get Flight Info'),
            ),
            const SizedBox(height: 16.0),
            _apiResponse.isEmpty
                ? const Center(child: Text('No data available'))
                : _buildFullApiResponse(),
            const SizedBox(height: 16.0),
            if (_apiResponse['status'] == 'en-route' ||
                _apiResponse['status'] == 'scheduled')
              ElevatedButton(
                onPressed: _showFlightTimeInformation,
                child: const Text('Flight Time Information'),
              ),
          ],
        ),
      ),
    );
  }

  void _fetchFlightInfo() async {
    final String flightNumber = _flightNumberController.text.trim();

    if (flightNumber.isNotEmpty) {
      const String apiKey = 'ae5dd420-49c7-4c0a-8512-f317e666207a';
      final Uri url = Uri.parse(
        'https://airlabs.co/api/v9/flight?flight_iata=$flightNumber&api_key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          _apiResponse = data['response'];
        });
      } else {
        setState(() {
          _apiResponse = {};
        });
      }
    }
  }

  Widget _buildFullApiResponse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Flight Information'),
        const SizedBox(height: 16.0),
        Text('Flight IATA: ${_apiResponse['flight_iata'] ?? ''}'),
        Text('Status: ${_apiResponse['status'] ?? ''}'),
        Text('Departure IATA: ${_apiResponse['dep_iata'] ?? ''}'),
        Text('Arrival IATA: ${_apiResponse['arr_iata'] ?? ''}'),
      ],
    );
  }

  void _showFlightTimeInformation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Convert strings to DateTime objects
        DateTime utcTime = DateTime.parse(_apiResponse['utc']);
        DateTime depTimeUtc = DateTime.parse(_apiResponse['dep_time_utc']);
        DateTime arrTimeUtc = DateTime.parse(_apiResponse['arr_time_utc']);

        // Calculate time differences
        Duration utcToDepDifference = utcTime.difference(depTimeUtc);
        Duration utcToArrDifference = utcTime.difference(arrTimeUtc);
        Duration depToArrDifference = depTimeUtc.difference(arrTimeUtc);

        // Calculate duration from the 'duration' field
        Duration duration = Duration(minutes: _apiResponse['duration'] ?? 0);

        // 'Time Differences 2' section
        String timeDifference2Message = 'Time Differences 2:';
        if (_apiResponse['status'] == 'scheduled') {
          if (_apiResponse['dep_actual_utc'] != null) {
            // Your flight will depart in hh:mm (difference UTC / dep_actual_utc)
            DateTime depActualUtc =
                DateTime.parse(_apiResponse['dep_actual_utc']);
            Duration utcToDepActualDifference =
                utcTime.difference(depActualUtc);
            timeDifference2Message +=
                '\nYour flight will depart in ${_formatDuration(utcToDepActualDifference)} (difference UTC / dep_actual_utc)';
          } else if (_apiResponse['dep_estimated_utc'] != null) {
            // Your flight will depart in hh:mm (difference UTC / dep_estimated_utc)
            DateTime depEstimatedUtc =
                DateTime.parse(_apiResponse['dep_estimated_utc']);
            Duration utcToDepEstimatedDifference =
                utcTime.difference(depEstimatedUtc);
            timeDifference2Message +=
                '\nYour flight will depart in ${_formatDuration(utcToDepEstimatedDifference)} (difference UTC / dep_estimated_utc)';
          } else if (_apiResponse['dep_time_utc'] != null) {
            // Your flight will depart in hh:mm (difference UTC / depTimeUtc)
            DateTime depTimeUtc = DateTime.parse(_apiResponse['dep_time_utc']);
            Duration utcToDepDifference = utcTime.difference(depTimeUtc);
            timeDifference2Message +=
                '\nYour flight will depart in ${_formatDuration(utcToDepDifference)} (difference UTC / depTimeUtc)';
          }
        } else if (_apiResponse['status'] == 'en-route') {
          if (_apiResponse['arr_actual_utc'] != null) {
            // Your flight will arrive in hh:mm (difference UTC / arr_actual_utc)
            DateTime arrActualUtc =
                DateTime.parse(_apiResponse['arr_actual_utc']);
            Duration utcToArrActualDifference =
                utcTime.difference(arrActualUtc);
            timeDifference2Message +=
                '\nYour flight will arrive in ${_formatDuration(utcToArrActualDifference)} (difference UTC / arr_actual_utc)';
          } else if (_apiResponse['arr_estimated_utc'] != null) {
            // Your flight will arrive in hh:mm (difference UTC / arr_estimated_utc)
            DateTime arrEstimatedUtc =
                DateTime.parse(_apiResponse['arr_estimated_utc']);
            Duration utcToArrEstimatedDifference =
                utcTime.difference(arrEstimatedUtc);
            timeDifference2Message +=
                '\nYour flight will arrive in ${_formatDuration(utcToArrEstimatedDifference)} (difference UTC / arr_estimated_utc)';
          } else if (_apiResponse['arr_time_utc'] != null) {
            // Your flight will arrive in hh:mm (difference UTC / arrTimeUtc)
            DateTime arrTimeUtc = DateTime.parse(_apiResponse['arr_time_utc']);
            Duration utcToArrDifference = utcTime.difference(arrTimeUtc);
            timeDifference2Message +=
                '\nYour flight will arrive in ${_formatDuration(utcToArrDifference)} (difference UTC / arrTimeUtc)';
          }
        }

        return AlertDialog(
          title: const Text('Flight Time Information'),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Table(
              children: [
                _buildTableRow('Status', _apiResponse['status'] ?? ''),
                _buildTableRow('UTC', _apiResponse['utc'] ?? ''),
                _buildTableRow(
                    'Departure Time (UTC)', _apiResponse['dep_time_utc'] ?? ''),
                _buildTableRow('Departure Estimated Time (UTC)',
                    _apiResponse['dep_estimated_utc'] ?? ''),
                _buildTableRow('Departure Actual Time (UTC)',
                    _apiResponse['dep_actual_utc'] ?? ''),
                _buildTableRow(
                    'Arrival Time (UTC)', _apiResponse['arr_time_utc'] ?? ''),
                _buildTableRow('Arrival Estimated Time (UTC)',
                    _apiResponse['arr_estimated_utc'] ?? ''),
                _buildTableRow('Arrival Actual Time (UTC)',
                    _apiResponse['arr_actual_utc'] ?? ''),
                _buildTableRow('Duration', _formatDuration(duration)),
                _buildTableRow('Time Differences',
                    'UTC to Departure: ${_formatDuration(utcToDepDifference)}\nUTC to Arrival: ${_formatDuration(utcToArrDifference)}\nDeparture to Arrival: ${_formatDuration(depToArrDifference)}'),
                _buildTableRow('Time Differences 2', timeDifference2Message),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    return '${duration.inHours.abs()}h ${duration.inMinutes.remainder(60).abs()}m';
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(value,
              style: const TextStyle(
                fontSize: 10,
              )),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _flightNumberController.dispose();
    super.dispose();
  }
}
