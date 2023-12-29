import 'package:flutter/material.dart';
import 'screens/flight_search_screen.dart';
import 'screens/rest_calculation_screen.dart';
import 'screens/shiftplan_screen.dart';
import 'widgets/splash_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Resttime Calculator',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: SplashScreen(
          onInitializationComplete: () =>
              MyHomePage()), // Set SplashScreen as home
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  dynamic flightData; // Variable to store flight data
  Map<String, dynamic> shiftPlanData = {}; // Variable to store shift plan data

  void updateFlightData(dynamic newFlightData) {
    setState(() {
      flightData = newFlightData;
    });
  }

  void handleShiftPlanCreated(Map<String, dynamic> data) {
    setState(() {
      shiftPlanData = data;
      _currentIndex = 2; // Switch to ShiftplanScreen
    });
  }

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Resttime Calculator'),
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
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
