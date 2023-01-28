import 'dart:convert';

import 'package:banner_carousel/banner_carousel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:place_finder/logic/place_model.dart';
import 'package:place_finder/widgets/components/card_image.dart';
import 'package:place_finder/widgets/utils/map_utils.dart';

class PlaceDetails extends StatelessWidget {
  PlaceDetails(this.place, {Key? key}) : super(key: key);
  PlaceModel place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Place Details",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(children: [
            BannerCarousel(
              height: 500,
              animation: true,
              activeColor: Theme.of(context).primaryColor,
              // viewportFraction: 0.60,
              showIndicator: true,
              customizedBanners: List.generate(place.photos.length, (index) {
                return CachedNetworkImage(
                  imageUrl: place.photos[index],
                  imageBuilder: (context, imageProvider) => Container(
                      height: 300,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      )),
                );
              }),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      place.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      place.address,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      place.description,
                      textAlign: TextAlign.center,
                    )
                  ],
                ))
          ]),
        ),
      ),
    );
  }
}
