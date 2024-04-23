import 'dart:math';

import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/category_response.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/presenter/bottom_appbar_index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/ui_sections/drawer.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/screens/category_products.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryList extends StatefulWidget {
  CategoryList(
      {Key? key,
      this.parent_category_id = 0,
      this.parent_category_name = "",
      this.is_base_category = false,
      this.is_top_category = false,
      this.bottomAppbarIndex})
      : super(key: key);

  final int parent_category_id;
  final String parent_category_name;
  final bool is_base_category;
  final bool is_top_category;
  final BottomAppbarIndex? bottomAppbarIndex;

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(children: [
        Container(
          height: DeviceInfo(context).height! / 4,
          width: DeviceInfo(context).width,
          // color: MyTheme.accent_color,
          alignment: Alignment.topRight,
          child: Image.asset(
            "assets/background_1.png",
          ),
        ),
        Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              child: buildAppBar(context),
              preferredSize: Size(
                DeviceInfo(context).width!,
                50,
              ),
            ),
            body: buildBody()),
        Align(
          alignment: Alignment.bottomCenter,
          child: widget.is_base_category || widget.is_top_category
              ? Container(
                  height: 0,
                )
              : buildBottomContainer(),
        )
      ]),
    );
  }

  Widget buildBody() {
    return CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverList(
            delegate: SliverChildListDelegate([
          buildCategoryList(),
          Container(
            height: widget.is_base_category ? 60 : 90,
          )
        ]))
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.accent_color,
      centerTitle: true,
      leading: widget.is_base_category
          ? Builder(
              builder: (context) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                child: UsefulElements.backToMain(context,
                    go_back: false, color: "white"),
              ),
            )
          : Builder(
              builder: (context) => IconButton(
                icon: Icon(CupertinoIcons.arrow_left, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
      title: Text(
        getAppBarTitle(),
        style: TextStyle(
            fontSize: 16, color: MyTheme.white, fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  String getAppBarTitle() {
    String name = widget.parent_category_name == ""
        ? (widget.is_top_category
            ? AppLocalizations.of(context)!.top_categories_ucf
            : AppLocalizations.of(context)!.categories_ucf)
        : widget.parent_category_name;

    return name;
  }

  buildCategoryList() {
    var data = widget.is_top_category
        ? CategoryRepository().getTopCategories()
        : CategoryRepository()
            .getCategories(parent_id: widget.parent_category_id);
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: FutureBuilder(
          future: data,
          builder: (context, AsyncSnapshot<CategoryResponse> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SingleChildScrollView(child: buildShimmer());
            }
            if (snapshot.hasError) {
              //snapshot.hasError
              print("category list error");
              print(snapshot.error.toString());
              return Container(
                height: 10,
              );
            } else if (snapshot.hasData) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  // mainAxisSpacing: 14,
                  // crossAxisSpacing: 14,
                  // childAspectRatio: 0.7,
                  // crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  // childAspectRatio: 0.7,
                  crossAxisCount: 2,
                ),
                itemCount: snapshot.data!.categories!.length,
                padding: EdgeInsets.only(
                    left: 18,
                    right: 18,
                    bottom: widget.is_base_category ? 30 : 0),
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return buildCategoryItemCard(snapshot.data, index);
                },
              );
            } else {
              return SingleChildScrollView(child: buildShimmer()
                  /*
                ListView.builder(
                  itemCount: 10,
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, bottom: 4.0, left: 16.0, right: 16.0),
                      child: Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: MyTheme.shimmer_base,
                            highlightColor: MyTheme.shimmer_highlighted,
                            child: Container(
                              height: 60,
                              width: 60,
                              color: Colors.white,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, bottom: 8.0),
                                child: Shimmer.fromColors(
                                  baseColor: MyTheme.shimmer_base,
                                  highlightColor: MyTheme.shimmer_highlighted,
                                  child: Container(
                                    height: 20,
                                    width: MediaQuery.of(context).size.width * .7,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Shimmer.fromColors(
                                  baseColor: MyTheme.shimmer_base,
                                  highlightColor: MyTheme.shimmer_highlighted,
                                  child: Container(
                                    height: 20,
                                    width: MediaQuery.of(context).size.width * .5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),*/
                  );
            }
          }),
    );
  }

  Widget buildCategoryItemCard(categoryResponse, index) {
    var itemWidth = ((DeviceInfo(context).width! - 36) / 3);
    print(itemWidth);
    final Random random = Random();
    final int r = random.nextInt(256);
    final int g = random.nextInt(256);
    final int b = random.nextInt(256);
    final Color randomBorderColor = Color.fromRGBO(r, g, b, 1);

    return Container(
      // color: Colors.orange,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: randomBorderColor),
        color: MyTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 20,
            spreadRadius: 0.0,
            offset: Offset(0.0, 10.0), // shadow direction: bottom right
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return CategoryProducts(
                  category_id: categoryResponse.categories[index].id,
                  category_name: categoryResponse.categories[index].name,
                );
              },
            ),
          );
        },
        child: Container(
          //padding: EdgeInsets.all(8),
          // color: Colors.amber,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(maxHeight: itemWidth - 28),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10)),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: categoryResponse.categories[index].banner,
                    fit: BoxFit.fill,
                    height: itemWidth,
                    width: DeviceInfo(context).width,
                  ),
                ),
              ),
              Container(
                // height: 30,
                //color: Colors.amber,
                alignment: Alignment.center,
                width: DeviceInfo(context).width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Text(
                  categoryResponse.categories[index].name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 12,
                      height: 1.6,
                      fontWeight: FontWeight.w600),
                ),
              ),
              // Spacer()
            ],
          ),
        ),
      ),
    );
  }

  Container buildBottomContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),

      height: widget.is_base_category ? 0 : 80,
      //color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: (MediaQuery.of(context).size.width - 32),
                height: 40,
                child: Btn.basic(
                  minWidth: MediaQuery.of(context).size.width,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0))),
                  child: Text(
                    AppLocalizations.of(context)!.all_products_of_ucf +
                        " " +
                        widget.parent_category_name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CategoryProducts(
                        category_id: widget.parent_category_id,
                        category_name: widget.parent_category_name,
                      );
                    }));
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildShimmer() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1,
        crossAxisCount: 3,
      ),
      itemCount: 18,
      padding: EdgeInsets.only(
          left: 18, right: 18, bottom: widget.is_base_category ? 30 : 0),
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecorations.buildBoxDecoration_1(),
          child: ShimmerHelper().buildBasicShimmer(),
        );
      },
    );
  }
}
