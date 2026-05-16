import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingResult {
  final String displayName;
  final String city;
  final String country;
  final String? state;
  final double lat;
  final double lon;

  GeocodingResult({
    required this.displayName,
    required this.city,
    required this.country,
    this.state,
    required this.lat,
    required this.lon,
  });
}

class GeocodingService {
  static const Duration _timeout = Duration(seconds: 30);
  static const String _userAgent = 'AuroraWeatherApp/1.0';

  /// Search for cities by name
  Future<List<GeocodingResult>> searchCity(String query) async {
    if (query.trim().isEmpty) return [];

    final encodedQuery = Uri.encodeComponent(query.trim());
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=$encodedQuery'
      '&format=json'
      '&limit=5'
      '&addressdetails=1',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': _userAgent},
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body);
      return results.map((r) {
        final address = r['address'] as Map<String, dynamic>? ?? {};
        final city = address['city'] ??
            address['town'] ??
            address['village'] ??
            address['municipality'] ??
            r['name'] ??
            '';
        final country = address['country'] ?? '';
        final state = address['state'];

        return GeocodingResult(
          displayName: r['display_name'] ?? '',
          city: city.toString(),
          country: country.toString(),
          state: state?.toString(),
          lat: double.parse(r['lat'].toString()),
          lon: double.parse(r['lon'].toString()),
        );
      }).toList();
    } else {
      throw Exception('Geocoding failed: ${response.statusCode}');
    }
  }

  /// Reverse geocode: lat/lon → city name
  Future<GeocodingResult> reverseGeocode(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$lat'
      '&lon=$lon'
      '&format=json'
      '&addressdetails=1',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': _userAgent},
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final r = jsonDecode(response.body) as Map<String, dynamic>;
      final address = r['address'] as Map<String, dynamic>? ?? {};
      final city = address['city'] ??
          address['town'] ??
          address['village'] ??
          address['municipality'] ??
          address['county'] ??
          'Unknown';
      final country = address['country'] ?? '';
      final state = address['state'];

      return GeocodingResult(
        displayName: r['display_name'] ?? '',
        city: city.toString(),
        country: country.toString(),
        state: state?.toString(),
        lat: lat,
        lon: lon,
      );
    } else {
      throw Exception('Reverse geocoding failed: ${response.statusCode}');
    }
  }
}
