// Import statements for Flutter material components and dart:async for Timer functionality.
import 'package:flutter/material.dart';
import 'dart:async';

// SplashScreen class - a StatefulWidget for displaying a splash screen.
class SplashScreen extends StatefulWidget {
  final Widget Function() onInitializationComplete; // Callback function to execute after initialization.

  // Constructor requiring a function to be executed after initialization.
  SplashScreen({required this.onInitializationComplete});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// _SplashScreenState class - contains the state for SplashScreen.
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin { // Mixin used for animation control.
  late AnimationController _controller; // Controller for animation.

  @override
  void initState() {
    super.initState();
    // Initializing the animation controller with a duration of 2 seconds.
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this, // Providing the current context for vsync.
    )..repeat(); // Repeating the animation.

    // Setting up a Timer to navigate to the next screen after 2 seconds.
    Timer(
        Duration(seconds: 3),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => widget.onInitializationComplete())) // Navigating to the next screen when the timer completes.
    );
  }

  @override
  void dispose() {
    // Disposing the animation controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Building the UI for the splash screen.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centering content in the column.
          children: <Widget>[
            // RotationTransition for rotating the icon.
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_controller), // Animation for rotation.
              child: Icon(Icons.calculate, size: 50, color: Colors.red), // Icon being rotated.
            ),
            SizedBox(height: 20), // Spacing between the icon and text.
            // Text widget for splash screen message.
            Text("Your rest during work",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
