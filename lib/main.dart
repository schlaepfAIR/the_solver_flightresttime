// Import statements for Flutter Material components and custom screens/widgets.
import 'package:flutter/material.dart';
import 'screens/flight_search_screen.dart';
import 'screens/rest_calculation_screen.dart';
import 'screens/shiftplan_screen.dart';
import 'widgets/splash_screen.dart';

// Main function which initializes the app.
void main() {
  runApp(MyApp());
}

// MyApp class, a StatelessWidget which sets up the main app structure.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Resttime Calculator', // App title.
      theme: ThemeData(
        primarySwatch: Colors.red, // Global theme for the app.
      ),
      home: SplashScreen(
          onInitializationComplete: () => MyHomePage()), // Initial screen of the app.
    );
  }
}

// MyHomePage class, a StatefulWidget, serves as the main screen of the app.
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// _MyHomePageState class, contains the state for MyHomePage.
class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0; // Index of the current tab.
  dynamic flightData; // Variable to store flight data.
  Map<String, dynamic> shiftPlanData = {}; // Variable to store shift plan data.

  // Function to update flight data.
  void updateFlightData(dynamic newFlightData) {
    setState(() {
      flightData = newFlightData;
    });
  }

  // Function to handle creation of a new shift plan.
  void handleShiftPlanCreated(Map<String, dynamic> data) {
    setState(() {
      shiftPlanData = data;
      _currentIndex = 2; // Switch to ShiftplanScreen upon creation.
    });
  }

  // Function to change the current tab.
  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Function to get the current screen based on the selected tab.
  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return FlightSearchScreen(
          updateFlightData: updateFlightData,
          changeTab: changeTab,
        );
      case 1:
        return RestCalculationScreen(
          flightData: flightData,
          onShiftPlanCreated: handleShiftPlanCreated,
        );
      case 2:
        return ShiftplanScreen(
          shiftPlanData: shiftPlanData,
          flightData: flightData,
        );
      default:
        return FlightSearchScreen(
          updateFlightData: updateFlightData,
          changeTab: changeTab,
        );
    }
  }

  // Function to handle tab selection.
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Function to show copyright information dialog.
  void _showCopyrightInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Impressum'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Copyright © the4Solvers'),
                Text('This is a Project of four Students from the FHGR.'),
                Text('All rights reserved.'),
                // Additional text can be added here.
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Building the main scaffold of the app.
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Resttime Calculator'),
        actions: <Widget>[
          // Button to show copyright information.
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showCopyrightInfo,
            tooltip: 'Info',
          ),
        ],
      ),
      body: _getCurrentScreen(), // Displaying the current screen based on tab selection.
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // Function called when a tab is tapped.
        currentIndex: _currentIndex, // Current selected tab index.
        items: [
          // Bottom navigation bar items.
          BottomNavigationBarItem(
            icon: new Icon(Icons.search),
            label: 'Flight Search',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.timer),
            label: 'Rest Calculation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Shiftplan',
          ),
        ],
      ),
    );
  }
}
