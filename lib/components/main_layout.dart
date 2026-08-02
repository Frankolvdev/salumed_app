import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/app.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  List<dynamic> menuData;
  int index;
  Function callbackNotifications;

  List<int> hideMenus;
    Function callbackHome;
  MainLayout(this.menuData, this.index, this.callbackNotifications,this.callbackHome,
      {Key? key, this.hideMenus = const []})
      : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String title = "";


    @override
  void initState() {
    super.initState();

    scaffoldKeyMainLayout =new 
        GlobalKey<ScaffoldState>(); // Inicializa el GlobalKey
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    UserModel user = provider.user;

    double widthLeftMenu =
        (MediaQuery.of(context).size.width >= breakPointDesktop)
            ? desktopMenuLeftWidth
            : 0;

    return WillPopScope(
        onWillPop: () async {

if(scaffoldKeyMainLayout != null && scaffoldKeyMainLayout.currentState != null) {

            if (scaffoldKeyMainLayout.currentState?.isDrawerOpen ?? false) {
      // Si el Drawer está abierto, deja que Flutter lo cierre automáticamente
      return true;
    }

}
widget.callbackHome();
  return false;
},
      child: Scaffold(
          key: scaffoldKeyMainLayout,
          drawer: drawerLeft(user),
          body: Row(
            children: [
              (widthLeftMenu > 0)
                  ? Container(
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                right: BorderSide(
                                  //                   <--- left side
                                  color: Colors.grey.shade200,
                                  width: 1.0,
                                ),
                              )),
                          height: MediaQuery.of(context).size.height,
                          width: widthLeftMenu,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0.0),
                            child: ListView(
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                InkWell(
                                    onTap: () {},
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 75,
                                            height: 75,
                                            decoration: new BoxDecoration(
                                              border: new Border.all(
                                                width: 1,
                                                color: Colors.grey.shade200,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade200,
                                                  spreadRadius: 2,
                                                  blurRadius: 2,
                                                  offset: Offset(0,
                                                      0), // changes position of shadow
                                                ),
                                              ], // border color
                                              shape: BoxShape.circle,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 5.0, horizontal: 5.0),
                                              child: (user.picture != null &&
                                                      getImageUrl(user.picture!)
                                                              .trim() !=
                                                          "")
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              75.0),
                                                      child: FadeInImage
                                                          .assetNetwork(
                                                        placeholder:
                                                            "assets/images/loading-image1.gif",
                                                        image: getImageUrl(
                                                            user.picture!),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : Container(
                                                      decoration: new BoxDecoration(
                                                          color:
                                                              Colors.transparent,
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .all(
                                                                  Radius.circular(
                                                                      75.0))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8.0),
                                                        child: Image.asset(
                                                          (getRoleName(user.roles[
                                                                      0]) ==
                                                                  "Hospital")
                                                              ? "assets/images/hospital_avatar.png"
                                                              : "assets/images/avatar.png",
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                menuLeftItems()
                              ],
                            ),
                          )),
                    )
                  : Container(),
              Container(
                width: MediaQuery.of(context).size.width - widthLeftMenu,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Positioned.fill(
                        top: MediaQuery.of(context).padding.top + 50,
                        child: widget.menuData[widget.index]["widget"]),
                    Positioned(
                      top: MediaQuery.of(context).padding.top,
                      left: 0,
                      height: 50,
                      width: MediaQuery.of(context).size.width - widthLeftMenu,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            (widthLeftMenu <= 0)
                                ? InkWell(
                                    onTap: () {
                                      scaffoldKeyMainLayout.currentState!.openDrawer();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 18),
                                      child: Icon(FontAwesomeIcons.bars),
                                    ),
                                  )
                                : Container(),
                            Text((widget.menuData[widget.index]["title"]=="Inicio")?"" :widget.menuData[widget.index]["title"],
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 18)),
                            InkWell(
                              onTap: () {
                                widget.callbackNotifications();
                              },
                              child: Stack(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 18),
                                      child: Icon(
                                        FontAwesomeIcons.bell,
                                        size: 30,
                                      )),
                                  Positioned(
                                      top: 8,
                                      left: 18,
                                      child: Visibility(
                                        visible: provider.notificationsUnread > 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            borderRadius: new BorderRadius.all(
                                                Radius.circular(12.0)),
                                            color: Colors.red,
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }

  Widget drawerLeft(UserModel user) {
    return Padding(
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 0),
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 0.75,
        child: Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(35),
                  bottomRight: Radius.circular(35)),
            ),
            child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: ListView(
                    children: [
                      InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Column(
                              children: [
                                Container(
                                  width: 75,
                                  height: 75,
                                  decoration: new BoxDecoration(
                                    border: new Border.all(
                                      width: 1,
                                      color: Colors.grey.shade200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        spreadRadius: 2,
                                        blurRadius: 2,
                                        offset: Offset(
                                            0, 0), // changes position of shadow
                                      ),
                                    ], // border color
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 5.0),
                                    child: (user.picture != null &&
                                            getImageUrl(user.picture!).trim() !=
                                                "")
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(75.0),
                                            child: FadeInImage.assetNetwork(
                                              placeholder:
                                                  "assets/images/loading-image1.gif",
                                              image: getImageUrl(user.picture!),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Container(
                                            decoration: new BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        Radius.circular(75.0))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.asset(
                                                "assets/images/avatar.png",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      menuLeftItems()
                    ],
                  ),
                ))),
      ),
    );
  }

  Widget menuLeftItems() {
    return Column(
        children: widget.menuData
            .where((element) {
              bool flag = false;
              if (element.containsKey("hide")) {
                if (element["hide"] is bool && element["hide"] == true) {
                  flag = true;
                }
              }
              return !flag;
            })
            .toList()
            .asMap()
            .entries
            .map((e) {
              return itemLeftMenu(e.key);
            })
            .toList());
  }

  Widget itemLeftMenu(int indexItem) {
    dynamic item = widget.menuData[indexItem];
    return Visibility(
      visible: !widget.hideMenus.contains(indexItem),
      child: InkWell(
        onTap: () {
          item["function"]();
        },
        child: Container(
          color:
              (widget.index == indexItem) ? Colors.grey.shade200 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(item["icon"],
                            color: CustomColors.primary, size: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(item["title"],
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2),
                        )
                      ])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
