import 'dart:convert';
import 'package:http/http.dart' as http;

class ReverseGeocodingService {
  static Future<String> getAddress({
    required double lat,
    required double lng,
  }) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=json'
      '&lat=$lat'
      '&lon=$lng'
      '&zoom=18'
      '&addressdetails=1',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'MorianaMobile/1.0',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name'] ?? 'Alamat tidak ditemukan';
    } else {
      throw 'Gagal mengambil alamat';
    }
  }
}
