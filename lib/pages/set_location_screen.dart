import 'package:ascend_fyp/geolocation/Geolocation.dart';
import 'package:ascend_fyp/models/autocomplete_prediction.dart';
import 'package:ascend_fyp/models/constants.dart';
import 'package:ascend_fyp/models/place_autocomplete_response.dart';
import 'package:ascend_fyp/network/network_utils.dart';
import 'package:ascend_fyp/widgets/location_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SetLocationScreen extends StatefulWidget {
  final bool enableCurrentLocation;
  const SetLocationScreen({
    super.key,
    required this.enableCurrentLocation,
  });

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  Map<String, dynamic> locationData = {};
  TextEditingController locationController = TextEditingController();
  List<AutocompletePrediction> placePredictions = [];
  GeoLocation geoLocation = GeoLocation();

  void placeAutocomplete(String query) async {
    Uri uri = Uri.https(
      "maps.googleapis.com",
      'maps/api/place/autocomplete/json',
      {
        "input": query,
        "key": placesAPIKey,
      },
    );
    String? response = await NetworkUtils.fetchUri(uri);

    if (response != null) {
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResults(response);
      if (result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  Future<void> selectLocation(String location) async {
    try {
      String? name;
      String? country;
      List<String> parts = location.split(',');

      if (parts.isNotEmpty) {
        name = parts[0].trim();
      }

      if (parts.length > 1) {
        country = parts.last.trim();
      }
      Map<String, dynamic> result = {
        'location': "$name, $country",
      };
      setState(() {
        locationController.text = location;
        locationData = result;
      });
    } catch (e) {
      debugPrint('Error obtaining location details: $e');
    }
  }

  Future<void> getCurrentPosition() async {
    Position position = await geoLocation.getLocation();

    String? address = await GeoLocation()
        .getCityFromCoordinates(position.latitude, position.longitude);

    Map<String, dynamic> result = {
      'location': address,
    };

    setState(() {
      Navigator.pop(context, result);
    });
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle currentLocationStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 14,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
          const Color.fromRGBO(247, 243, 237, 1)),
      backgroundColor: WidgetStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(
              color: Color.fromRGBO(247, 243, 237, 1), width: 1.5),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.check,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.pop(context, locationData);
          },
        ),
        title: Row(
          children: [
            Text(
              "Set Location",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Form(
              child: TextFormField(
                controller: locationController,
                onChanged: (value) {
                  placeAutocomplete(value);
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search a location",
                  hintStyle: Theme.of(context).textTheme.titleMedium,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Icon(
                      Icons.location_on,
                      color: Color.fromRGBO(247, 243, 237, 1),
                      size: 20,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(247, 243, 237, 1),
                      width: 2.5,
                    ),
                  ),
                ),
                style: Theme.of(context).textTheme.titleMedium,
                cursorColor: const Color.fromRGBO(247, 243, 237, 1),
              ),
            ),
            const SizedBox(height: 24),
            widget.enableCurrentLocation
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await getCurrentPosition();
                      },
                      style: currentLocationStyle,
                      icon: Image.asset(
                        "lib/assets/images/location_icon.png",
                        width: 18,
                        height: 18,
                      ),
                      label: const Text("Use My Current Location"),
                    ),
                  )
                : Container(),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: placePredictions.length,
                itemBuilder: (context, index) => LocationListTile(
                  onPress: (selectedLocation) {
                    setState(() {
                      selectLocation(selectedLocation);
                    });
                  },
                  location: placePredictions[index].description!,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
