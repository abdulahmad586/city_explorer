import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_finder/connection/internet_grabber.dart';
import 'package:place_finder/widgets/utils/map_utils.dart';

class PlaceModel {
  static const defaultPlaceImage =
      'https://images.pexels.com/photos/1205405/pexels-photo-1205405.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1';

  final String name, placeId, iconUrl;
  final LatLng latLng;
  final dynamic payload;
  dynamic payload2;
  String address, imageRef, description;
  List<String> photos;

  PlaceModel(
      {required this.name,
      required this.address,
      required this.imageRef,
      required this.placeId,
      required this.iconUrl,
      required this.payload,
      required this.description,
      required this.photos,
      required this.latLng}) {
    getPlaceDetails(placeId).then((value) {
      var addresses = value['result']['address_components'];
      if (addresses.length > 0) {
        address = '';
        for (var i = 0; i < addresses.length; i++) {
          address += addresses[i]['long_name'] + ' ';
        }
      }

      var photos = value['result']['photos'];
      if (photos.length > 0) {
        for (var i = 0; i < photos.length; i++) {
          this.photos.add(
              MapUtils().photoUrl(photos[i]["photo_reference"]).toString());
        }
        imageRef = this.photos[0];
      } else {
        imageRef = defaultPlaceImage;
        this.photos.add(defaultPlaceImage);
      }
      var reviews = value['result']['reviews'];

      if (reviews.length > 0) {
        description =
            "${reviews[0]['text']} \n\t - ${reviews[0]['author_name']}";
      } else {
        description = 'No description found';
      }

      payload2 = value['result'];
    }).catchError((e) {
      print("ERRP: $e");
    });
  }

  static List<PlaceModel> parse(List results) {
    final newList = results
        .map(
          (place) => PlaceModel(
              name: place['name'],
              address: place['vicinity'] ?? '',
              latLng: LatLng(
                place['geometry']['location']['lat'],
                place['geometry']['location']['lng'],
              ),
              imageRef: place['imageRef'] ?? '',
              placeId: place['place_id'] ?? 'none',
              iconUrl: place['icon'] ?? '',
              description: '',
              photos: [],
              payload: place),
        )
        .toList();

    return newList;
  }

  static Future<List<PlaceModel>?> getNearyByPlaces(
      LatLng userLocation, String place) async {
    try {
      Uri url = MapUtils().searchUrl(userLocation, place);
      String response = await InternetGrabber.request(url: url);
      var jsonObj = jsonDecode(response);
      return parse(jsonObj['results'] ?? []);
    } catch (e) {
      print('place_finder: ERRORRRRRRRRRRRRRR: ' + e.toString());
    }
    return [];
  }

  static Future<dynamic> getPlaceDetails(String placeId) async {
    try {
      Uri url = MapUtils().detailsUrl(placeId);
      String response = await InternetGrabber.request(url: url);

      var jsonObj = jsonDecode(response);
      return jsonObj;
    } catch (e) {
      print('place_finder: ERRORRRRRRRRRRRRRR: ' + e.toString());
    }
    return [];
  }
}
