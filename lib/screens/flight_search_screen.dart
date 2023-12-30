// Import statements for using Flutter material components and API service.
import 'package:flutter/material.dart';
import '../services/api_call.dart';

// FlightSearchScreen class - a StatefulWidget for searching flights.
class FlightSearchScreen extends StatefulWidget {
  // Declaration of function types for updating flight data and changing tabs.
  final Function(dynamic) updateFlightData;
  final Function(int) changeTab;

  // Constructor requiring functions to update flight data and change tabs.
  FlightSearchScreen({required this.updateFlightData, required this.changeTab});

  @override
  _FlightSearchScreenState createState() => _FlightSearchScreenState();
}

// _FlightSearchScreenState class - contains the state for FlightSearchScreen.
class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final TextEditingController _controller = TextEditingController(); // Text editing controller for the input field.

  @override
  Widget build(BuildContext context) {
    // Building the UI for flight search screen.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Aligning children to the center.
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 80.0), // Horizontal padding for better UI.
            child: TextField(
              controller: _controller, // Using the controller for text field.
              decoration: InputDecoration(
                labelText: 'Enter Flight Number', // Label text for the input field.
              ),
              onChanged: (value) {
                setState(() {}); // Trigger UI update when text in the field changes.
              },
            ),
          ),
          SizedBox(height: 20), // Adding space above the button.
          ElevatedButton(
            child: Text('Find Flight'), // Text for the button.
            onPressed: _controller.text.isNotEmpty
                ? () async {
                    var flightNumber = _controller.text; // Getting text from the controller.
                    var flightData = await fetchFlightData(
                        flightNumber); // Fetching flight data using the API with the entered flight number.
                    widget.updateFlightData(
                        flightData); // Updating flight data in MyHomePage.
                    widget.changeTab(1); // Switching to the Rest Calculation tab.
                  }
                : null, // Disabling the button when the text field is empty.
          ),
        ],
      ),
    );
  }
}
