import 'package:flutter/material.dart';
import '../services/api_call.dart'; // Ensure this service is correctly implemented

class FlightSearchScreen extends StatefulWidget {
  final Function(dynamic) updateFlightData;
  final Function(int) changeTab;

  FlightSearchScreen({required this.updateFlightData, required this.changeTab});

  @override
  _FlightSearchScreenState createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 80.0), // Horizontal padding
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Flight Number',
              ),
              onChanged: (value) {
                setState(() {}); // Trigger UI update when text changes
              },
            ),
          ),
          SizedBox(height: 20), // Space above the button
          ElevatedButton(
            child: Text('Find Flight'),
            onPressed: _controller.text.isNotEmpty
                ? () async {
                    var flightNumber = _controller.text;
                    var flightData = await fetchFlightData(
                        flightNumber); // Fetch data using the API
                    widget.updateFlightData(
                        flightData); // Update the data in MyHomePage
                    widget.changeTab(1); // Switch to Rest Calculation tab
                  }
                : null, // Disable the button when text field is empty
          ),
        ],
      ),
    );
  }
}
