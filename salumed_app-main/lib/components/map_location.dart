import 'dart:async';
import 'dart:ui';
import 'package:app/components/empty_state_image.dart';
import 'package:app/components/fade_animation.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/place.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/search_places_stream.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapLocation extends StatefulWidget {
  Place place;
  String titleMarker;
  String subtitleMarker;

  bool showFull;
  MapLocation(this.place, this.titleMarker,
      {required Key? key, this.subtitleMarker = "", this.showFull = false})
      : super(key: key);

  @override
  State<MapLocation> createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> with WidgetsBindingObserver {
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
  }

  void createMarkerSelectLocation(Place place) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(place.lat ?? provider.lat, place.lng ?? provider.long),
      infoWindow:
          InfoWindow(title: widget.titleMarker, snippet: widget.subtitleMarker),
      visible: true,
      draggable: false,
      icon: (kIsWeb)
          ? BitmapDescriptor.defaultMarker
          : BitmapDescriptor.defaultMarker,
    );
    setState(() {
      // adding a new marker to map
      markersLocation[markerId] = marker;
    });
    focus(place);
  }

  void focus(Place place) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    _controllerMap.future.then((controller) async {
      await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: (place != null && place is Place)
              ? LatLng((place as Place).lat ?? provider.lat,
                  (place as Place).lng ?? provider.long)
              : LatLng(provider.lat, provider.long),
          zoom: 17.0,
        ),
      ));

      Timer(Duration(seconds: 1), () async {
        await controller.showMarkerInfoWindow(markerId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final provider = Provider.of<AppProvider>(context, listen: true);

    Widget map = GoogleMap(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
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
    return Container(
      constraints: (widget.showFull)
          ? BoxConstraints()
          : BoxConstraints(
              maxWidth: double.infinity,
              minWidth: 100,
              maxHeight: 400,
              minHeight: 400),
      child: map,
    );
  }
}
