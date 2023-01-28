import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapUtils {
  static const String _baseUrlNearBySearch =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
  static const String _baseUrlDetailsSearch =
      "https://maps.googleapis.com/maps/api/place/details/json?";
  static const String _baseUrlPhoto =
      "https://maps.googleapis.com/maps/api/place/photo?";

  final String _placesApi = dotenv.env['GOOGLE_MAP_API_KEY'] as String;

  Uri searchUrl(LatLng userLocation, String placeKey) {
    final api = "&key=$_placesApi";
    final location =
        "location=${userLocation.latitude},${userLocation.longitude}";
    String type = "&type=$placeKey";
    const rankBy = "&rankby=distance";
    final url =
        Uri.parse(_baseUrlNearBySearch + location + rankBy + type + api);
    return url;
  }

  Uri detailsUrl(String placeId) {
    final api = "&key=$_placesApi";
    final place = "place_id=$placeId";
    final url = Uri.parse(_baseUrlDetailsSearch + place + api);
    return url;
  }

  Uri photoUrl(String photoRef) {
    final api = "&key=$_placesApi";
    final photo = "photo_reference=$photoRef";
    const maxWidth = "&maxwidth=400";
    final url = Uri.parse(_baseUrlPhoto + photo + maxWidth + api);
    return url;
  }
}
