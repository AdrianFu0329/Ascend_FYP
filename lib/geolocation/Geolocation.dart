// ignore_for_file: file_names

import 'package:geocoding/geocoding.dart';

class GeoLocation {
  Future<String?> getCityFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String? state = placemark.administrativeArea;
        String? locality = placemark.locality;
        if (state != null && locality != null) {
          return '$locality, $state';
        } else if (state != null) {
          return state;
        } else if (locality != null) {
          return locality;
        } else {
          return 'Unknown';
        }
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return e.toString();
    }
  }
}
