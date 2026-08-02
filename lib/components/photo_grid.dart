import 'dart:math';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/models/asset.dart';

import 'package:flutter/material.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class PhotoGrid extends StatefulWidget {
  final List<AssetModel> assets;
  final Function(int) onImageClicked;
  final Function onExpandClicked;

  PhotoGrid(
    this.assets,
    this.onImageClicked,
    this.onExpandClicked,
  );

  @override
  createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  final int maxImages = 5;
  bool expanded = false;
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var images = buildImages();
    return Container(
        constraints: new BoxConstraints(
          minHeight: 200,
          minWidth: MediaQuery.of(context).size.width,
          maxHeight: 300,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: grid(images));

    /* return Container(
      width: MediaQuery.of(context).size.width,
   
      child: StaggeredGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: (images.length >= 4) ? 3 : 2,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          staggeredTiles: tmpList,
          children: buildImages()),
    );*/
    // return GridView(
    //   shrinkWrap: true,
    //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    //     maxCrossAxisExtent: 200,
    //     crossAxisSpacing: 2,
    //     mainAxisSpacing: 2,
    //   ),
    //   children: images,
    // );
  }

  Widget grid(List<Widget> images) {
    if (images.length == 1) {
      return images[0];
    } else if (images.length == 2) {
      return Row(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: images[0],
          )),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: images[1],
          ))
        ],
      );
    } else if (images.length == 3) {
      print("entre");
      return Row(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: images[0],
          )),
          Expanded(
            child: Column(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: images[1],
                )),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: images[2],
                ))
              ],
            ),
          )
        ],
      );
    } else if (images.length == 4) {
      return Row(
        children: [
          Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: images[0],
              )),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: images[1],
                )),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: images[2],
                )),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: images[3],
                ))
              ],
            ),
          )
        ],
      );
    } else if (images.length >= 5) {
      return Row(
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: images[0],
              )),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: images[1],
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: images[2],
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: images[3],
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: images[4],
                      )),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      );
    } else {
      return images[0];
    }
  }

  List<Widget> buildImages() {
    int numImages = widget.assets.length;

    List<Widget> tmpList = [];

    for (var i = 0; i < numImages; i++) {
      if (i + 1 == maxImages && numImages > maxImages) {
        tmpList.add(GestureDetector(
          onTap: () {
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [itemBottomSheetTemplate(widget.assets, i)],
                  );
                });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: FadeInImage.assetNetwork(
                    placeholder: "assets/images/loading-image1.gif",
                    image: imagesUrl + (widget.assets[i].name ?? ""),
                    fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: Colors.black54,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+' + ((numImages - 1) - i).toString(),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ));
      } else {
        tmpList.add(GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: FadeInImage.assetNetwork(
                placeholder: "assets/images/loading-image1.gif",
                image: imagesUrl + (widget.assets[i].name ?? ""),
                fit: BoxFit.cover),
          ),
          onTap: () {
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [itemBottomSheetTemplate(widget.assets, i)],
                  );
                });
          },
        ));
      }
    }
    return tmpList;
  }

  Widget itemBottomSheetTemplate(List<AssetModel> pictures, index) {
    _pageController = PageController(initialPage: index);
    return Container(
      height: MediaQuery.of(context).size.height * .90,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(150.0, 20.9, 150.0, 0.0),
            child: Container(
              height: 8.0,
              width: 80.0,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.all(const Radius.circular(8.0))),
            ),
          ),
          Expanded(
            child: PhotoViewGallery.builder(
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              itemCount: pictures.length,
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider:
                      NetworkImage(imagesUrl + (pictures[index].name ?? "")),
                  initialScale: PhotoViewComputedScale.contained * 0.9,
                  heroAttributes:
                      PhotoViewHeroAttributes(tag: pictures[index].id ?? "a"),
                );
              },

              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!,
                    color: CustomColors.primary,
                  ),
                ),
              ),
              //backgroundDecoration: widget.backgroundDecoration,
              pageController: _pageController,
              onPageChanged: (int index) {},
            ),
          )
        ],
      ),
    );
  }
}
