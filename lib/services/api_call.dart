import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> fetchFlightData(String flightNumber) async {
  var url =
      'https://airlabs.co/api/v9/flight?flight_iata=$flightNumber&api_key=ae5dd420-49c7-4c0a-8512-f317e666207a';
  var response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load flight data');
  }
}
