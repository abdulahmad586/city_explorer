import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_finder/logic/place_model.dart';

class MainMapCubit extends Cubit<MainMapState> {
  MainMapCubit(this.location)
      : super(MainMapState(
          lastState: null,
          errorStr: "",
          error: false,
          location: location,
        ));
  LatLng location;

  void updateSelectedPlace(PlaceModel? place) {
    emit(MainMapState(lastState: state, selectedPlace: place));
  }

  void updateSelectedType(Map<String, String>? type) {
    emit(MainMapState(lastState: state, selectedType: type));
  }

  List<Marker> allPlaces(Function(PlaceModel) showMiniDetails) {
    List<Marker> all = [];
    for (var i = 0; i < state.nearbyPlaces!.keys.length; i++) {
      var places = state.nearbyPlaces![state.nearbyPlaces!.keys.toList()[i]];
      if (places != null && places.isNotEmpty) {
        all.addAll(List.generate(
          places.length,
          (index) => Marker(
            markerId: MarkerId(
              places[index].name.replaceAll(" ", ''),
            ),
            position: places[index].latLng,
            onTap: () {
              showMiniDetails(places[i]);
            },
            consumeTapEvents: true,
          ),
        ));
      }
    }
    return all;
  }

  Future<List<Map<String, String>>> loadPlaces(String search) async {
    return state.places!
        .where((element) =>
            element['label']!.toLowerCase().startsWith(search.toLowerCase()))
        .toList();
  }

  void getNearbyPlaces() async {
    try {
      emit(MainMapState(lastState: state, loading: true));
      for (int i = 0; i < state.places!.length; i++) {
        var places = await PlaceModel.getNearyByPlaces(
            state.location!, state.places![i]['key']!);
        state.places![i]['found'] =
            places == null ? '0' : places.length.toString();
        state.nearbyPlaces![state.places![i]['key']!] = places ?? [];
      }
      emit(MainMapState(lastState: state, loading: false));
    } catch (e) {
      print('ERR: $e');
    }
  }

  void searchPlace(String place) async {
    try {
      emit(MainMapState(lastState: state, loading: true));

      var placesFound =
          await PlaceModel.getNearyByPlaces(state.location!, place);

      for (int i = 0; i < state.places!.length; i++) {
        if (place == state.places![i]['key']) {
          state.places![i]['found'] =
              placesFound == null ? '0' : placesFound.length.toString();
          state.nearbyPlaces![state.places![i]['key']!] = placesFound ?? [];
        } else {
          state.nearbyPlaces![state.places![i]['key']!] = [];
        }
      }
      emit(MainMapState(lastState: state, loading: false));
    } catch (e) {
      print('ERR: $e');
    }
  }
}

class MainMapState {
  MainMapState? lastState;
  String? errorStr;
  bool? error;
  bool? loading;
  LatLng? location;
  PlaceModel? selectedPlace;
  Map<String, String>? selectedType;
  Map<String, List<PlaceModel>>? nearbyPlaces;
  List<Map<String, String>>? places;

  MainMapState({
    this.lastState,
    this.errorStr,
    this.error,
    this.loading,
    this.location,
    this.selectedPlace,
    this.selectedType,
    this.nearbyPlaces,
    this.places,
  }) {
    if (lastState != null) {
      errorStr = errorStr ?? lastState!.errorStr;
      error = error ?? lastState!.error;
      loading = loading ?? lastState!.loading;
      location = location ?? lastState!.location;
      // selectedPlace = selectedPlace ?? lastState!.selectedPlace;
      selectedType = selectedType ?? lastState!.selectedType;
      nearbyPlaces = nearbyPlaces ?? lastState!.nearbyPlaces;
      places = places ?? lastState!.places;
    } else {
      errorStr = errorStr;
      error = error ?? false;
      location = location;
      loading = loading ?? false;
      selectedPlace = selectedPlace;
      selectedType = {"key": 'all', "label": "All places"};
      nearbyPlaces = {
        "amusement_park": [],
        "aquarium": [],
        "art_gallery": [],
        "bar": [],
        "park": [],
        "stadium": [],
        "restaurant": [],
        "florist": [],
        "zoo": [],
      };
      places = [
        {"key": "amusement_park", "label": "Amusement park", "found": "0"},
        {"key": "aquarium", "label": "Aquarium", "found": "0"},
        {"key": "art_gallery", "label": "Art Gallery", "found": "0"},
        {"key": "bar", "label": "Bar", "found": "0"},
        {"key": "park", "label": "Park", "found": "0"},
        {"key": "stadium", "label": "Stadium", "found": "0"},
        {"key": "restaurant", "label": "Restaurant", "found": "0"},
        {"key": "florist", "label": "Florist", "found": "0"},
        {"key": "zoo", "label": "Zoo", "found": "0"},
      ];
    }
  }
}
