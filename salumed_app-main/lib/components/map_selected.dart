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

class MapSelected extends StatefulWidget {
  Place place;
  Function callbackDragEnd;
    Function cancelScrollView;
  MapSelected(this.place, this.callbackDragEnd,this.cancelScrollView, {required Key? key})
      : super(key: key);

  @override
  State<MapSelected> createState() => _MapSelectedState();
}

class _MapSelectedState extends State<MapSelected> with WidgetsBindingObserver {
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
        infoWindow: InfoWindow(title: "Ubicación", snippet: ''),
        draggable: true,
        icon: BitmapDescriptor.defaultMarker,
        onTap: () {
        print("marker tap");
        widget.cancelScrollView(true);
        },
        onDrag: (LatLng){
        widget.cancelScrollView(true);
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
              print("entre a reverse geocode");
          if (places.length > 0) {
            places[0].lat = position.latitude;
            places[0].lng = position.longitude;
  print("SI HAY PLACES");
            widget.callbackDragEnd(places[0])();
            Navigator.pop(contextDialog);
          } else {
            Navigator.pop(contextDialog);
          }
            widget.cancelScrollView(false);
        }).catchError((e) {
            widget.cancelScrollView(false);
          Navigator.pop(contextDialog);
          print(e);
        });
      } catch (e) {
          widget.cancelScrollView(false);
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
    final width = MediaQuery.of(context).size.width;
    final provider = Provider.of<AppProvider>(context, listen: true);

    Widget map = MouseRegion(
      onHover: (e){
   
            print("entre a onHover");
              
           widget.cancelScrollView(true);
      },
onEnter: (e){
print("onEnter");
},


      
      child: GoogleMap(
        
        gestureRecognizers:  <Factory<OneSequenceGestureRecognizer>>[
      new Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer(),),
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
        
      
        onCameraIdle: (() {
          widget.cancelScrollView(false);
        }),
        markers: Set<Marker>.of(markersLocation.values),
      ),
    );
    return Container(
      constraints: BoxConstraints(
          maxWidth: double.infinity,
          minWidth: 100,
          maxHeight: 400,
          minHeight: 400),
      child: map,
    );
  }
}
