import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlightInfoTabView(),
    );
  }
}

class FlightInfoTabView extends StatefulWidget {
  @override
  _FlightInfoTabViewState createState() => _FlightInfoTabViewState();
}

class _FlightInfoTabViewState extends State<FlightInfoTabView> {
  TextEditingController _flightNumberController = TextEditingController();
  TextEditingController _restTimeStartController = TextEditingController();
  TextEditingController _restTimeEndController = TextEditingController();
  TextEditingController _amountOfShiftsController = TextEditingController();
  TextEditingController _overlapController = TextEditingController();
  Map<String, dynamic> _apiResponse = {};

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Info App'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _flightNumberController,
              decoration: InputDecoration(labelText: 'Enter Flight Number'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _restTimeStartController,
              decoration:
                  InputDecoration(labelText: 'Start Rest Time (minutes)'),
            ),
            TextField(
              controller: _restTimeEndController,
              decoration: InputDecoration(
                  labelText: 'End Rest Time Before Landing (minutes)'),
            ),
            TextField(
              controller: _amountOfShiftsController,
              decoration: InputDecoration(labelText: 'Amount of Shifts'),
            ),
            TextField(
              controller: _overlapController,
              decoration: InputDecoration(labelText: 'Overlap (minutes)'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchFlightInfo,
              child: Text('Get Flight Info'),
            ),
            SizedBox(height: 16.0),
            _apiResponse.isEmpty
                ? Center(child: Text('No data available'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFullApiResponse(),
                      if (_apiResponse['status'] == 'en-route' ||
                          _apiResponse['status'] == 'scheduled')
                        _buildFlightTimeInformation(),
                    ],
                  ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _makeShiftPlan,
              child: Text('Make Shift Plan'),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchFlightInfo() async {
    final String flightNumber = _flightNumberController.text.trim();

    if (flightNumber.isNotEmpty) {
      final String apiKey = 'ae5dd420-49c7-4c0a-8512-f317e666207a';
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
    // Remove the UI elements for displaying flight information
    return Container();
  }

  Widget _buildFlightTimeInformation() {
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
        DateTime depActualUtc = DateTime.parse(_apiResponse['dep_actual_utc']);
        Duration utcToDepActualDifference = utcTime.difference(depActualUtc);
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
        DateTime arrActualUtc = DateTime.parse(_apiResponse['arr_actual_utc']);
        Duration utcToArrActualDifference = utcTime.difference(arrActualUtc);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.0),
        Text('Flight Time Information'),
        SizedBox(height: 16.0),
        Table(
          children: [
            _buildTableRow('Flight Number', _apiResponse['flight_iata'] ?? ''),
            _buildTableRow('Origin', _apiResponse['dep_iata'] ?? ''),
            _buildTableRow('Arrival', _apiResponse['arr_iata'] ?? ''),
            _buildTableRow('Airline', _apiResponse['airline_name'] ?? ''),
            _buildTableRow('Aircraft', _apiResponse['model'] ?? ''),
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
      ],
    );
  }

  void _makeShiftPlan() {
    int restTimeStart = int.tryParse(_restTimeStartController.text) ?? 0;
    int restTimeEnd = int.tryParse(_restTimeEndController.text) ?? 0;
    int amountOfShifts = int.tryParse(_amountOfShiftsController.text) ?? 0;
    int overlap = int.tryParse(_overlapController.text) ?? 0;

    // Check if the status is 'scheduled'
    if (_apiResponse['status'] == 'scheduled') {
      // Calculate the flight duration
      DateTime depTimeUtc = DateTime.parse(_apiResponse['dep_time_utc']);
      DateTime arrTimeUtc = DateTime.parse(_apiResponse['arr_time_utc']);
      int flightDuration = arrTimeUtc.difference(depTimeUtc).inMinutes;

      // Calculate the rest duration
      int restDuration = flightDuration - restTimeStart - restTimeEnd;

      // Calculate startResttimeInfo and endResttimeInfo
      DateTime startResttimeInfo =
          depTimeUtc.add(Duration(minutes: restTimeStart));
      DateTime endResttimeInfo =
          arrTimeUtc.subtract(Duration(minutes: restTimeEnd));

      // Calculate restTimeShiftplan and restTimePerShift
      int restTimeShiftplan = (restDuration / amountOfShifts).toInt() - overlap;
      int restTimePerShift = restDuration ~/ amountOfShifts - overlap;

      // Calculate start and end times for each shift
      List<String> shiftTimings = [];
      for (int shift = 1; shift <= amountOfShifts; shift++) {
        DateTime startShiftTime = startResttimeInfo
            .add(Duration(minutes: (shift - 1) * (restTimePerShift + overlap)));
        DateTime endShiftTime =
            startShiftTime.add(Duration(minutes: restTimePerShift));
        shiftTimings.add(
            'Shift $shift: ${_formatTime(startShiftTime)} - ${_formatTime(endShiftTime)}');
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Shift Plan Result'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Flight Duration: ${_formatDuration(Duration(minutes: flightDuration))}',
                ),
                Text(
                  'Rest Duration: ${_formatDuration(Duration(minutes: restDuration))}',
                ),
                Text(
                  'Start Resttime (UTC): ${startResttimeInfo.toLocal()}',
                ),
                Text(
                  'End Resttime (UTC): ${endResttimeInfo.toLocal()}',
                ),
                Text(
                  'Rest Time Shiftplan: ${_formatDuration(Duration(minutes: restTimeShiftplan))}',
                ),
                Text(
                  'Rest Time Per Shift: ${_formatDuration(Duration(minutes: restTimePerShift))}',
                ),
                SizedBox(height: 8.0),
                Text(
                  'Shift Timings:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...shiftTimings.map((timing) => Text(timing)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle cases where the status is not 'scheduled'
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Shift Plan Result'),
            content: Text(
              'Shift Plan is only applicable for flights with status "scheduled".',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(value,
              style: TextStyle(
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
