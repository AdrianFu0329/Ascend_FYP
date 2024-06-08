// ignore_for_file: file_names

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeoLocation {
  Future<String?> getCityFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String? country = placemark.country;
        String? state = placemark.administrativeArea;
        if (state != null && country != null) {
          return '$state, $country';
        } else if (country != null) {
          return country;
        } else if (state != null) {
          return state;
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

  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
  }
}
