import 'package:flutter/material.dart';
import 'package:flutter_google_map/core/utils/google_maps_place_service.dart';
import 'package:flutter_google_map/models/place_auto_complete_model/place_auto_complete_model.dart';
import 'package:flutter_google_map/models/place_details_model/place_details_model.dart';

class CustomListView extends StatelessWidget {
  final List<PlaceAutoCompleteModel> places;
  final GoogleMapPlaceService service;
  final void Function(PlaceDetailsModel) onSelectPlace;
  const CustomListView({
    super.key,
    required this.places,
    required this.service,
    required this.onSelectPlace,
  });

  @override
  Widget build(BuildContext context) {
    return places.isNotEmpty
        ? Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 0,
                );
              },
              itemCount: places.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(places[index].description!),
                  onTap: () async {
                    var placeSelect = await service.getPlaceDetails(
                      placeId: places[index].placeId!.toString(),
                    );

                    onSelectPlace(placeSelect);
                  },
                  leading: const Icon(Icons.location_on),
                  trailing: const Icon(Icons.arrow_forward),
                  subtitle: Text(places[index].structuredFormatting!.mainText!),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                );
              },
            ))
        : const SizedBox();
  }
}
