// ignore_for_file: file_names

import 'package:geocoding/geocoding.dart';

class GeoLocation {
  Future<String?> getCityFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return placemarks[0].locality;
      } else {
        return "Unknown";
      }
    } catch (e) {
      return e.toString();
    }
  }
}
