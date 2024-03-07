import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  final int id;
  final String name;
  final String image;
  final String address;
  final LatLng latLang;
  PlaceModel(
      {required this.id,
      required this.name,
      required this.image,
      required this.address,
      required this.latLang});
}

List<PlaceModel> places = [
  PlaceModel(
      id: 1,
      name: "Lagos",
      image: "assets/images/lagos.jpg",
      address: "Lagos, Nigeria",
      latLang: const LatLng(25.230391907166233, 55.26471287335303)),
  PlaceModel(
      id: 2,
      name: "Abuja",
      image: "assets/images/abuja.jpg",
      address: "Abuja, Nigeria",
      latLang: const LatLng(30.03233440258355, 30.98290617374865)),
  PlaceModel(
    id: 3,
    name: "Kano",
    image: "assets/images/kano.jpg",
    address: "Kano, Nigeria",
    latLang: const LatLng(25.225122539319237, 55.30053195462235),
  ),
];
