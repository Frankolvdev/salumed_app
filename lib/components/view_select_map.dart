import 'dart:async';

import 'package:app/components/map_location.dart';
import 'package:app/components/map_selected.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/place.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/app.dart';

class ViewSelectMap extends StatefulWidget {
  Place place;

  ViewSelectMap(this.place, {Key? key}) : super(key: key);

  @override
  State<ViewSelectMap> createState() => _ViewSelectMapState();
}

class _ViewSelectMapState extends State<ViewSelectMap>
    with WidgetsBindingObserver {
  Completer<GoogleMapController> _controllerMap = Completer();
  Map<MarkerId, Marker> markersLocation = <MarkerId, Marker>{};
  final MarkerId markerId = MarkerId("1");

  dynamic mapController = null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addObserver(this);
    WidgetsBinding.instance?.addPostFrameCallback((_) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      try {
        if (mapController != null) mapController.setMapStyle("[]");
      } catch (e) {}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
    try {
      (mapController as GoogleMapController).dispose();
    } catch (e) {}
  }

  void createMarkerSelectLocation(Place place) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(place.lat ?? provider.lat, place.lng ?? provider.long),
        infoWindow: InfoWindow(title: "Ubicación", snippet: ''),
        draggable: true,
        icon: BitmapDescriptor.defaultMarker,
        onTap: () {
          print("marker tap");
        },
        onDragEnd: (LatLng position) {
          endDrag(position);
        });
    setState(() {
      // adding a new marker to map
      markersLocation[markerId] = marker;
    });
    focus(place);
  }

  void updatePositionMarker(Place place) async {
    print("ENTRE  A updatePositionMarker");
    final provider = Provider.of<AppProvider>(context, listen: false);
    Marker marker = markersLocation[markerId]!;
    setState(() {
      markersLocation = <MarkerId, Marker>{};
    });
    await Future.delayed(Duration(milliseconds: 50));
    setState(() {
      final Marker marker = Marker(
          markerId: markerId,
          position:
              LatLng(place.lat ?? provider.lat, place.lng ?? provider.long),
          infoWindow: InfoWindow(title: "Ubicación", snippet: ''),
          draggable: true,
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            print("marker tap");
          },
          onDragEnd: (LatLng position) {
            endDrag(position);
          });
      markersLocation[markerId] = marker;
    });

    try {
      if (mapController != null) mapController.setMapStyle("[]");
    } catch (e) {}
    focus(place);
    //progressLocationMap();
  }

  void endDrag(LatLng position) {
    simpleLoading(context, (BuildContext contextDialog) {
      try {
        Marker? marker = markersLocation[markerId];

        WebService(context)
            .reverseGeocode(
                position.latitude.toString(), position.longitude.toString())
            .then((List<Place> places) {
          if (places.length > 0) {
            places[0].lat = position.latitude;
            places[0].lng = position.longitude;

            // widget.callbackDragEnd(places[0])();
            Navigator.pop(contextDialog);
          } else {
            Navigator.pop(contextDialog);
          }
        }).catchError((e) {
          Navigator.pop(contextDialog);
          print(e);
        });
      } catch (e) {
        Navigator.pop(contextDialog);
        print(e);
      }
    });
  }

  void focus(Place place) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    _controllerMap.future.then((controller) {
      controller
          .animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: (place != null && place is Place)
                  ? LatLng((place as Place).lat ?? provider.lat,
                      (place as Place).lng ?? provider.long)
                  : LatLng(provider.lat, provider.long),
              zoom: 17.0,
            ),
          ))
          .then((value) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    Widget map = GoogleMap(
      mapType: MapType.normal,
      liteModeEnabled: false,
      compassEnabled: false,
      indoorViewEnabled: false,
      rotateGesturesEnabled: false,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      initialCameraPosition: CameraPosition(
        target: LatLng(provider.lat, provider.long),
        bearing: 0,
        zoom: 15.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        setState(() {
          mapController = controller;
          mapController.setMapStyle("[]");
        });

        _controllerMap.complete(controller);
        createMarkerSelectLocation(widget.place);
      },
      onCameraMoveStarted: () {
        /* setState(() {
          showBtnConfirmLocationMap = true;
        });*/
      },
      onCameraIdle: (() {}),
      markers: Set<Marker>.of(markersLocation.values),
    );
    return Scaffold(
      appBar: AppBar(
//        backgroundColor: Colors.transparent,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(""),
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(FontAwesomeIcons.arrowLeft,
                    size: 20, color: CustomColors.primary),
              ))),
      body: Stack(
        children: [
          Positioned.fill(
            child: map,
          )
        ],
      ),
    );
  }
}
