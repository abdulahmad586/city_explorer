import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_finder/logic/place_model.dart';
import 'package:place_finder/state/main.state.dart';
import 'package:place_finder/widgets/components/card_image.dart';
import 'package:place_finder/widgets/components/search_bar.dart';
import 'package:place_finder/widgets/pages/place_details.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class MainMap extends StatefulWidget {
  MainMap(this.defaultLocation, {Key? key}) : super(key: key);
  LatLng defaultLocation;

  @override
  State<StatefulWidget> createState() {
    return _MainMapState();
  }
}

class _MainMapState extends State<MainMap> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const searchAll = {"key": 'all', "label": "All places"};

  bool showTip = false;
  bool moving = false;
  bool loaded = false;

  late BuildContext stateContext;

  @override
  void initState() {
    super.initState();
  }

  void load() {
    if (!loaded) {
      BlocProvider.of<MainMapCubit>(stateContext).getNearbyPlaces();
      loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider<MainMapCubit>(
            create: (_) => MainMapCubit(widget.defaultLocation),
            child: BlocBuilder<MainMapCubit, MainMapState>(
              builder: (context, state) {
                stateContext = context;
                load();

                return Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: CameraPosition(
                        target: state.location!,
                        zoom: 14.4746,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      onCameraMoveStarted: () {
                        if (!moving) {
                          BlocProvider.of<MainMapCubit>(context)
                              .updateSelectedPlace(null);
                        }
                      },
                      onTap: (argument) {
                        print("TAPPED");
                        BlocProvider.of<MainMapCubit>(context)
                            .updateSelectedPlace(null);
                      },
                      onCameraIdle: () {
                        _onFinishAnimate(state);
                      },
                      buildingsEnabled: true,
                      markers: Set<Marker>.of(
                          BlocProvider.of<MainMapCubit>(context)
                              .allPlaces((place) => showMiniDetails(place))),
                    ),
                    _buildControls(state),
                    Align(
                      alignment: Alignment.center,
                      child: SimpleTooltip(
                          tooltipTap: () {
                            print("Tooltip tap");
                          },
                          ballonPadding: EdgeInsets.all(0.0),
                          borderColor: Colors.transparent,
                          arrowLength: 20,
                          backgroundColor: Colors.white,
                          animationDuration: Duration(seconds: 1),
                          show: showTip && state.selectedPlace != null,
                          tooltipDirection: TooltipDirection.up,
                          content: Material(
                            child: state.selectedPlace == null
                                ? const Text('Tap a pin')
                                : _buildMiniPlaceView(
                                    state.selectedPlace!, state),
                          ),
                          child: const SizedBox()),
                    ),
                  ],
                );
              },
            )));
  }

  Widget _buildControls(MainMapState state) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(180),
            )
          ],
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: state.selectedType != null &&
                      state.selectedType!['key'] == searchAll['key']
                  ? FancySearchField(
                      hint: "Search interesting places",
                      loader: BlocProvider.of<MainMapCubit>(stateContext)
                          .loadPlaces,
                      itemBuilder: (place) => ListTile(
                            leading: const Icon(Icons.location_on),
                            title:
                                Text((place as Map<String, String>)['label']!),
                            trailing: Text(place['found']!),
                          ),
                      onSelected: (place) {
                        BlocProvider.of<MainMapCubit>(stateContext).searchPlace(
                            (place as Map<String, String>)['key']!);
                        BlocProvider.of<MainMapCubit>(stateContext)
                            .updateSelectedType(place);
                      })
                  : Text(
                      state.selectedType!['label'] ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
            ),
            state.loading!
                ? const SizedBox(
                    width: 30, height: 30, child: CircularProgressIndicator())
                : IconButton(
                    onPressed: () {
                      if (state.selectedType!['key'] != searchAll['key']) {
                        BlocProvider.of<MainMapCubit>(stateContext)
                            .updateSelectedType(null);
                        BlocProvider.of<MainMapCubit>(stateContext)
                            .getNearbyPlaces();
                      }
                    },
                    icon: Icon(state.selectedType!['key'] == searchAll['key']
                        ? Icons.search
                        : Icons.clear),
                  ),
          ],
        ));
  }

  void _onFinishAnimate(MainMapState state) {
    if (state.selectedPlace != null) {
      setState(() {
        showTip = true;
      });
    }
  }

  Future<void> moveCamera(LatLng pos, {double zoom = 19.152}) async {
    final GoogleMapController controller = await _controller.future;
    var position =
        CameraPosition(bearing: 192.8334901395799, target: pos, zoom: zoom);

    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  showMiniDetails(PlaceModel plac) {
    BlocProvider.of<MainMapCubit>(stateContext).updateSelectedPlace(plac);
    moving = true;
    moveCamera(LatLng(plac.latLng.latitude, plac.latLng.longitude));
  }

  Widget _buildMiniPlaceView(PlaceModel place, MainMapState state) {
    return Container(
      padding: const EdgeInsets.all(3),
      height: 90,
      width: 220,
      child: Row(
        children: [
          CardImage(
            imageString: place.imageRef,
            size: const Size(60, 80),
            radius: 6,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                place.name,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                place.address,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      BlocProvider.of<MainMapCubit>(stateContext)
                          .updateSelectedPlace(null);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return PlaceDetails(place);
                      }));
                    },
                    child: const Text(
                      'Open',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      moveCamera(
                          LatLng(place.latLng.latitude, place.latLng.longitude),
                          zoom: 23.12);
                    },
                    child: const Text(
                      'Zoom',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              )
            ]),
          ),
        ],
      ),
    );
  }
}
