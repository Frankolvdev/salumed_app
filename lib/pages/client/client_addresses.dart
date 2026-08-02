import 'package:app/constants/colors.dart';
import 'package:app/pages/client/client_add_address.dart';
import 'package:app/pages/client/client_edit_address.dart';
import 'package:app/providers/app.dart';
import 'package:flutter/material.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../services/web_service.dart';

class ClientAddresses extends StatefulWidget {
  const ClientAddresses({Key? key}) : super(key: key);

  @override
  State<ClientAddresses> createState() => _ClientAddressesState();
}

class _ClientAddressesState extends State<ClientAddresses> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Direcciones",
          style: TextStyle(color: CustomColors.primary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: CustomColors.primary),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: (provider.user.addresses!.length > 0)
          ? ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Column(
                        children: provider.user.addresses!.map((address) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: ClientEditAdress(address),
                                      type: PageTransitionType.slideInUp,
                                      duration: Duration(milliseconds: 250)));
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.check,
                                            color:
                                                (address.is_delivery == "true")
                                                    ? Colors.blue
                                                    : Colors.transparent,
                                          ),
                                        ),
                                        Flexible(
                                            child: Text(address.street ?? "")),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            FontAwesomeIcons.chevronRight,
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                              "${address.zip_code} ${address.street} - ${address.state} - ${address.municipality}"),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      Center(
                          child: Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 2,
                                backgroundColor: CustomColors.primary2,
                                shape: StadiumBorder()),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: ClientAddAdress(),
                                      type: PageTransitionType.slideInUp,
                                      duration: Duration(milliseconds: 250)));
                            },
                            child: Container(
                              width: 130,
                              height: 35.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Agregar Dirección",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                )
              ],
            )
          : Center(
              child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: CustomColors.primary2,
                      shape: StadiumBorder()),
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: ClientAddAdress(),
                            type: PageTransitionType.slideInUp,
                            duration: Duration(milliseconds: 250)));
                  },
                  child: Container(
                    width: 130,
                    height: 35.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Agregar Dirección",
                          style: TextStyle(color: Colors.white, fontSize: 15.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
    );
  }
}
