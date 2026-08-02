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
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SelectLocation extends StatefulWidget {
  String defaultAddress;
  SelectLocation({this.defaultAddress = ""});
  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation>
    with WidgetsBindingObserver {
  TextStyle style = TextStyle(fontSize: 18.0);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final myCtrlPhone = TextEditingController();
  final formKey = new GlobalKey<FormState>();

  final ctrlFrom = TextEditingController();
  final ctrlWhere = TextEditingController();

  bool focusWhere = true;
  var listenUser = null;

  bool searchPlaceLoading = false;
  bool showBtnConfirmLocationMap = false;

  dynamic place = null;

  bool entryMap = false;

  PanelController _slidingPanel = new PanelController();
  //var searchPlacesStream = SearchPlacesStream();
  bool findResults = false;

  Completer<GoogleMapController> _controllerMap = Completer();
  Map<MarkerId, Marker> markersLocation = <MarkerId, Marker>{};
  final MarkerId markerId = MarkerId("1");

  dynamic mapController = null;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addObserver(this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.defaultAddress.trim() != "") {
        ctrlFrom.text = widget.defaultAddress;
        searchPlace();
        FocusScope.of(context).unfocus();
      }
    });
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
    WidgetsBinding.instance!.removeObserver(this);
    if (listenUser != null) listenUser?.cancel();
    super.dispose();
  }

  void hideSliding() {
    FocusScope.of(context).requestFocus(FocusNode());
    final provider = Provider.of<AppProvider>(context, listen: false);
    _controllerMap.future.then((controller) {
      _slidingPanel.close();
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

    setState(() {
      showBtnConfirmLocationMap = true;
    });
  }

  void openSliding() {
    _slidingPanel.open();
  }

  void searchPlace() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    openSliding();
    /*/searchPlacesStream.searchPlacesByKeyword(
        ctrlFrom.text.isEmpty ? "" : ctrlFrom.text,
        provider.lat.toString(),
        provider.long.toString(),
        context);*/
  }

  void createMarkerSelectLocation() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(provider.lat, provider.long),
      infoWindow: InfoWindow(title: "Ubicación", snippet: ''),
      draggable: false,
      icon: provider.getFromIconPin,
      onTap: () {
        print("marker tap");
      },
    );
    setState(() {
      // adding a new marker to map
      markersLocation[markerId] = marker;
    });
  }

  void updatePositionMarker(CameraPosition _position) {
    Marker marker = markersLocation[markerId]!;
    setState(() {
      markersLocation[markerId] = marker.copyWith(
          positionParam:
              LatLng(_position.target.latitude, _position.target.longitude));
    });
  }

  void progressLocationMap() {
    simpleLoading(context, (BuildContext contextDialog) {
      setState(() {
        place = null;
      });

      Marker? marker = markersLocation[markerId];

      WebService(context)
          .reverseGeocode(marker!.position.latitude.toString(),
              marker.position.longitude.toString())
          .then((List<Place> places) {
        if (places.length > 0) {
          setState(() {
            Place placeTmp = places[0];
            placeTmp.lat = marker.position.latitude;
            placeTmp.lng = marker.position.longitude;
            place = placeTmp;
          });
          setState(() {
            //showBtnConfirmLocationMap = true;
          });
          Navigator.pop(contextDialog);
        } else {
          setState(() {
            place = null;
          });
          Navigator.pop(contextDialog);
        }
      }).catchError((e) {
        Navigator.pop(contextDialog);
        print(e);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final provider = Provider.of<AppProvider>(context, listen: true);

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
        createMarkerSelectLocation();
      },
      onCameraMove: ((_position) => updatePositionMarker(_position)),
      onCameraMoveStarted: () {
        /* setState(() {
          showBtnConfirmLocationMap = true;
        });*/
      },
      onCameraIdle: (() {
        if (entryMap) {
          progressLocationMap();
        }
      }),
      markers: Set<Marker>.of(markersLocation.values),
    );

    Widget fromText = TextField(
      onTap: () {},
      autofocus: true,
      controller: ctrlFrom,
      style: TextStyle(color: (place != null) ? Colors.orange : Colors.black),
      textInputAction: TextInputAction.search,
      //maxLength: 1,
      textAlign: TextAlign.left,

      //focusNode: myFocusNode1,
      decoration: InputDecoration(
          counterText: '',
          hintText: "Introduzca la dirección",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: InkWell(
            onTap: () {
              setState(() {
                place = null;
              });
              ctrlFrom.text = "";
              FocusScope.of(context).requestFocus(FocusNode());

              //searchPlacesStream.searchPlacesByKeyword("",provider.lat.toString(), provider.long.toString(), context);
              //searchPlace();
            },
            child: Icon(
              Icons.cancel,
              size: 20,
              color: CustomColors.primary,
            ),
          ),
          suffixIcon: InkWell(
            splashColor: CustomColors.primary,
            onTap: () {
              searchPlace();
            },
            child: Icon(
              Icons.search,
              size: 20,
              color: CustomColors.primary,
            ),
          ),
          //contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          contentPadding: const EdgeInsets.fromLTRB(45, 0, 0, 0),
          //contentPadding: EdgeInsets.zero,
          filled: true,
          isDense: true,
          fillColor: Colors.grey[300],
          focusColor: Colors.grey[200],
          hoverColor: Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Colors.transparent, width: 0.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Colors.transparent, width: 0.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          border: InputBorder.none),
      onChanged: (valueSearch) {
        setState(() {
          place = null;
        });
        //searchPlace();
      },
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(FocusNode());
        searchPlace();
      },
    );

    Widget content = Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      hideSliding();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            FontAwesomeIcons.mapPin,
                            size: 20,
                            color: CustomColors.primary,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Confirmar ubicación en mapa",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                /* StreamBuilder<dynamic>(
                    stream: searchPlacesStream.searchPlacesStream,
                    builder: (context, snapshot) {
                      SchedulerBinding.instance!
                          .addPostFrameCallback((_) => setState(() {
                                findResults = false;
                              }));
                      if (snapshot.hasData && snapshot.data != null) {
                        if (snapshot.data == "searching") {
                          return Flexible(
                            fit: FlexFit.loose,
                            child: LinearProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  CustomColors.primary),
                            ),
                          );
                        }

                        SchedulerBinding.instance!
                            .addPostFrameCallback((_) => setState(() {
                                  findResults = true;
                                }));

                        if ((snapshot.data as List<Place>).length <= 0) {
                          return Flexible(
                            child: EmptyStateImage(
                                "Ningún lugar encontrado", Container(), true),
                          );
                        }

                        List<Place> places = snapshot.data;
                        return Expanded(
                          child: ListView.separated(
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (BuildContext content, int index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      place = places[index];
                                    });
                                    hideSliding();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child:
                                              Icon(Icons.location_on, size: 20),
                                        ),
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                places[index].name ?? "",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                  places[index]
                                                          .formatted_address ??
                                                      "",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ],
                                        ))
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext content, int index) {
                                return Divider(
                                  height: 1,
                                  color: Colors.grey[300],
                                );
                              },
                              itemCount: places.length),
                        );
                      } else {
                        return Flexible(
                          child: Container(
                              child: Center(
                            child: EmptyStateImage(
                                "Ningún lugar encontrado", Container(), true),
                          )),
                        );
                      }
                    }),*/
              ],
            )));

    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize:
              Size(double.infinity, 150 - MediaQuery.of(context).padding.top),
          child: AppBar(
            leading: new IconButton(
              icon: new Icon(
                Icons.arrow_back,
                color: CustomColors.primary,
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                //icon: Icon(FontAwesomeIcons.shoppingBag),
                icon: Icon(
                  FontAwesomeIcons.filter,
                  color: Colors.transparent,
                ),
                onPressed: () {},
              ),
            ],
            title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[]),
            flexibleSpace: Container(
              child: Stack(children: <Widget>[
                Positioned(
                  top: 0,
                  height: 150,
                  width: ((MediaQuery.of(context).size.width) - 50),
                  left: ((MediaQuery.of(context).size.width) / 2) -
                      (((MediaQuery.of(context).size.width) - 50) / 2),
                  child: FadeAnimation(
                      0.5,
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15)),
                      )),
                ),
                Positioned(
                  top: -4,
                  height: 150,
                  width: ((MediaQuery.of(context).size.width) - 20),
                  left: ((MediaQuery.of(context).size.width) / 2) -
                      (((MediaQuery.of(context).size.width) - 20) / 2),
                  child: FadeAnimation(
                      1,
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(15)),
                      )),
                ),
                Positioned(
                  top: -10,
                  height: 150,
                  width: width,
                  child: FadeAnimation(
                      1.5,
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade900, spreadRadius: 1),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.only(
                                top: AppBar().preferredSize.height + 33,
                                left: 18,
                                right: 18),
                            height: 90,
                            child: Container(
                                child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3.0),
                                  child: Container(height: 35, child: fromText),
                                ),
                              ],
                            )),
                          ),
                        ),
                      )),
                ),
              ]),
            ),
          ),
        ),
        body: SlidingUpPanel(
          onPanelSlide: (double val) {
            setState(() {
              //showBtnConfirmLocationMap = false;
              entryMap = true;
            });
          },
          onPanelOpened: () {
            setState(() {
              showBtnConfirmLocationMap = false;
            });
          },
          onPanelClosed: () {
            setState(() {
              showBtnConfirmLocationMap = true;
            });
          },
          panelSnapping: false,
          controller: _slidingPanel,
          defaultPanelState: PanelState.OPEN,
          padding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
          color: Colors.white,
          maxHeight: MediaQuery.of(context).size.height - 150,
          boxShadow: [BoxShadow(color: Colors.transparent)],
          panel: Container(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
            width: MediaQuery.of(context).size.width,
            child: content,
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 290),
              child: map,
            ),
          ),
        ),
        bottomNavigationBar: FadeAnimation(
            1.2,
            (showBtnConfirmLocationMap)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Mueva el mapa para ubicar el pin justo donde se encuentra la ubicación deseada",
                          style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  onPressed: () {
                                    ctrlFrom.text = place.formatted_address;

                                    Navigator.pop(context, place);
                                  },
                                  color: (place == null)
                                      ? Colors.grey[300]
                                      : CustomColors.primary,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        FontAwesomeIcons.arrowRight,
                                        color: Colors.white,
                                        size: 15.0,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Usar esta ubicación",
                                          style: new TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  )
                : SizedBox(
                    height: 0,
                  )));
  }
}
