import 'package:app/constants/colors.dart';
import 'package:app/models/place.dart';
import 'package:app/providers/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class ViewLocation extends StatefulWidget {
  Place location;
  bool approximate;
  ViewLocation(this.location, this.approximate, {Key? key}) : super(key: key);

  @override
  _ViewLocationState createState() => _ViewLocationState();
}

class _ViewLocationState extends State<ViewLocation> {
  Completer<GoogleMapController> _controllerMap = Completer();
  dynamic mapController = null;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    Place location = widget.location;
    Map<MarkerId, Marker> markersLocation = <MarkerId, Marker>{};

    Set<Circle> circles = <Circle>{};

    if (!widget.approximate) {
      final MarkerId markerId = MarkerId("1");

      final Marker marker = Marker(
        markerId: markerId,
        position:
            LatLng(location.lat ?? provider.lat, location.lng ?? provider.long),
        infoWindow: InfoWindow(title: "", snippet: ''),
        draggable: false,
        icon: provider.getFromIconPin,
        onTap: () {
          print("marker tap");
        },
      );
      markersLocation[markerId] = marker;
    } else {
      circles = Set.from([
        Circle(
          fillColor: CustomColors.primary.withAlpha(100),
          strokeWidth: 1,
          strokeColor: CustomColors.primary,
          circleId: CircleId("2"),
          center: LatLng(
              location.lat ?? provider.lat, location.lng ?? provider.long),
          radius: 100,
        )
      ]);
    }

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
      rotateGesturesEnabled: true,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      initialCameraPosition: CameraPosition(
        target:
            LatLng(location.lat ?? provider.lat, location.lng ?? provider.long),
        bearing: 0,
        zoom: 16,
      ),
      onMapCreated: (GoogleMapController controller) {
        setState(() {
          mapController = controller;
          mapController.setMapStyle("[]");
        });
        _controllerMap.complete(controller);
      },
      onCameraMoveStarted: () {},
      onCameraIdle: (() {}),
      markers: Set<Marker>.of(markersLocation.values),
      circles: circles,
    );
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text("",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                )),
            elevation: 0,
            centerTitle: true,
            leading: new IconButton(
              icon: new FaIcon(FontAwesomeIcons.arrowLeft,
                size: 20,
                color: CustomColors.primary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )),
        body: Stack(
          children: [
            Positioned.fill(child: map),
            Positioned(
              width: MediaQuery.of(context).size.width,
              top: 60,
              left: 0,
              child: Visibility(
                visible: !widget.approximate,
                child: Text(
                  location.formatted_address ?? location.name ?? "",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ));
  }
}

