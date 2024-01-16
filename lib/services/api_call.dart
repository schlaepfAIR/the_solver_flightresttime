// Import necessary libraries
import 'dart:convert';  // Import the 'dart:convert' library for JSON encoding and decoding
import 'package:http/http.dart' as http;  // Import the 'http' package for making HTTP requests

// Define a function to fetch flight data from an API
Future<dynamic> fetchFlightData(String flightNumber) async {
  // Construct the URL for the API request, including the flight number and API key
  var url = 'https://airlabs.co/api/v9/flight?flight_iata=$flightNumber&api_key=ae5dd420-49c7-4c0a-8512-f317e666207a';
  
  // Send an HTTP GET request to the constructed URL and wait for the response
  var response = await http.get(Uri.parse(url));

  // Check if the response status code is 200, which indicates success
  if (response.statusCode == 200) {
    // If successful, decode the JSON response and return it as a dynamic object
    return json.decode(response.body);
  } else {
    // If the response status code is not 200, throw an exception with an error message
    throw Exception('Failed to load flight data');
  }
}
