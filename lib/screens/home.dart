import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/aiz_image.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/home_presenter.dart';
import 'package:active_ecommerce_flutter/screens/category_products.dart';
import 'package:active_ecommerce_flutter/screens/filter.dart';
import 'package:active_ecommerce_flutter/screens/flash_deal_list.dart';
import 'package:active_ecommerce_flutter/screens/todays_deal_products.dart';
import 'package:active_ecommerce_flutter/screens/top_sellers.dart';
import 'package:active_ecommerce_flutter/ui_elements/mini_product_card.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:toast/toast.dart';

import '../custom/device_info.dart';
import '../custom/toast_component.dart';
import '../data_model/flash_deal_response.dart';
import '../helpers/main_helpers.dart';
import '../repositories/flash_deal_repository.dart';
import '../ui_sections/drawer.dart';
import 'flash_deal_products.dart';

class Home extends StatefulWidget {
  Home({
    Key? key,
    this.title,
    this.show_back_button = false,
    go_back = true,
  }) : super(key: key);

  final String? title;
  bool show_back_button;
  late bool go_back;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  HomePresenter homeData = HomePresenter();

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      change();
    });
    // change();
    // TODO: implement initState
    super.initState();
  }

  int currentPage = 0;

  change() {
    homeData.onRefresh();
    homeData.mainScrollListener();
    homeData.initPiratedAnimation(this);
  }

  @override
  void dispose() {
    homeData.pirated_logo_controller.dispose();
    //  ChangeNotifierProvider<HomePresenter>.value(value: value)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () async {
        //CommonFunctions(context).appExitDialog();
        return widget.go_back;
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Scaffold(
            //key: homeData.scaffoldKey,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(110),
              child: buildAppBar(statusBarHeight, context),
            ),
            drawer: MainDrawer(),
            // drawerScrimColor: Colors.black,
            body: ListenableBuilder(
              listenable: homeData,
              builder: (context, child) {
                return Stack(
                  children: [
                    CustomScrollView(
                      controller: homeData.mainScrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      // physics: const BouncingScrollPhysics(
                      //     parent: AlwaysScrollableScrollPhysics()),
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildListDelegate([
                            AppConfig.purchase_code == ""
                                ? Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      9.0,
                                      16.0,
                                      9.0,
                                      0.0,
                                    ),
                                    child: Container(
                                      height: 140,
                                      color: Colors.black,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                              left: 20,
                                              top: 0,
                                              child: AnimatedBuilder(
                                                  animation: homeData
                                                      .pirated_logo_animation,
                                                  builder: (context, child) {
                                                    return Image.asset(
                                                      "assets/pirated_square.png",
                                                      height: homeData
                                                          .pirated_logo_animation
                                                          .value,
                                                      color: Colors.white,
                                                    );
                                                  })),
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 24.0,
                                                  left: 24,
                                                  right: 24),
                                              child: Text(
                                                "This is a pirated app. Do not use this. It may have security issues.",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            buildHomeCarouselSlider(context, homeData),
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  18.0,
                                  20.0,
                                  18.0,
                                  0.0,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .featured_categories_ucf,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(
                                      height: 154,
                                      child: buildHomeFeaturedCategories(
                                          context, homeData),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              color: MyTheme.white,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        Image.asset("assets/background_1.png")
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10.0,
                                            right: 18.0,
                                            left: 18.0),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .todays_deal_ucf,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      buildHomeTodayDealProductHorizontalList(
                                          homeData)
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Padding(
                            //   padding: const EdgeInsets.fromLTRB(
                            //     18.0,
                            //     0.0,
                            //     18.0,
                            //     0.0,
                            //   ),
                            //   child: buildHomeMenuRow1(context, homeData),
                            // ),
                            buildHomeBannerOne(context, homeData),
                            // Padding(
                            //   padding: const EdgeInsets.fromLTRB(
                            //     18.0,
                            //     0.0,
                            //     18.0,
                            //     0.0,
                            //   ),
                            //   child: buildHomeMenuRow2(context),
                            // ),
                          ]),
                        ),
                        // SliverList(
                        //   delegate: SliverChildListDelegate([
                        //     Padding(
                        //       padding: const EdgeInsets.fromLTRB(
                        //         18.0,
                        //         20.0,
                        //         18.0,
                        //         0.0,
                        //       ),
                        //       child: Column(
                        //         crossAxisAlignment:
                        //             CrossAxisAlignment.start,
                        //         children: [
                        //           Text(
                        //             AppLocalizations.of(context)!
                        //                 .featured_categories_ucf,
                        //             style: TextStyle(
                        //                 fontSize: 18,
                        //                 fontWeight: FontWeight.w700),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ]),
                        // ),
                        // SliverToBoxAdapter(
                        //   child: SizedBox(
                        //     height: 154,
                        //     child: buildHomeFeaturedCategories(
                        //         context, homeData),
                        //   ),
                        // ),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            Container(
                              color: MyTheme.white,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        Image.asset("assets/background_1.png")
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10.0,
                                            right: 18.0,
                                            left: 18.0),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .featured_products_ucf,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      buildHomeFeatureProductHorizontalList(
                                          homeData)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              buildHomeBannerTwo(context, homeData),
                            ],
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            Container(
                              color: MyTheme.white,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        Image.asset("assets/background_1.png")
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10.0,
                                            right: 18.0,
                                            left: 18.0),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .best_selling_ucf,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      buildHomeBestDealHorizontalList(
                                          homeData)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              homeData.flashDealProducts.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, right: 18.0, left: 18.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .flash_deal_ucf,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              homeData.flashDealProducts.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, right: 18.0, left: 18.0),
                                      child: buildFlashDealList(context),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                        // SliverList(
                        //   delegate: SliverChildListDelegate([
                        //     Padding(
                        //       padding: const EdgeInsets.fromLTRB(
                        //         18.0,
                        //         18.0,
                        //         20.0,
                        //         0.0,
                        //       ),
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Text(
                        //             AppLocalizations.of(context)!
                        //                 .all_products_ucf,
                        //             style: TextStyle(
                        //                 fontSize: 18,
                        //                 fontWeight: FontWeight.w700),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     SingleChildScrollView(
                        //       child: Column(
                        //         children: [
                        //           buildHomeAllProducts2(context, homeData),
                        //         ],
                        //       ),
                        //     ),
                        //     Container(
                        //       height: 80,
                        //     )
                        //   ]),
                        // ),
                      ],
                    ),
                    // Align(
                    //     alignment: Alignment.center,
                    //     child: buildProductLoadingContainer(homeData))
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHomeAllProducts(context, HomePresenter homeData) {
    if (homeData.isAllProductInitial && homeData.allProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: homeData.allProductScrollController));
    } else if (homeData.allProductList.length > 0) {
      //snapshot.hasData

      return GridView.builder(
        // 2
        //addAutomaticKeepAlives: true,
        itemCount: homeData.allProductList.length,
        controller: homeData.allProductScrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.618),
        padding: EdgeInsets.all(16.0),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          // 3
          return ProductCard(
            id: homeData.allProductList[index].id,
            image: homeData.allProductList[index].thumbnail_image,
            name: homeData.allProductList[index].name,
            main_price: homeData.allProductList[index].main_price,
            stroked_price: homeData.allProductList[index].stroked_price,
            has_discount: homeData.allProductList[index].has_discount,
            discount: homeData.allProductList[index].discount,
            product: homeData.allProductList[index],
          );
        },
      );
    } else if (homeData.totalAllProductData == 0) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  Widget buildHomeAllProducts2(context, HomePresenter homeData) {
    // if (homeData.isAllProductInitial && homeData.allProductList.length == 0) {
    if (homeData.isAllProductInitial) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: homeData.allProductScrollController));
    } else if (homeData.allProductList.length > 0) {
      return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: homeData.allProductList.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 20.0, bottom: 10, left: 18, right: 18),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ProductCard(
              id: homeData.allProductList[index].id,
              image: homeData.allProductList[index].thumbnail_image,
              name: homeData.allProductList[index].name,
              main_price: homeData.allProductList[index].main_price,
              stroked_price: homeData.allProductList[index].stroked_price,
              has_discount: homeData.allProductList[index].has_discount,
              discount: homeData.allProductList[index].discount,
              is_wholesale: homeData.allProductList[index].isWholesale,
              product: homeData.allProductList[index],
            );
          });
    } else if (homeData.totalAllProductData == 0) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  Widget buildHomeFeaturedCategories(context, HomePresenter homeData) {
    if (homeData.isCategoryInitial &&
        homeData.featuredCategoryList.length == 0) {
      return ShimmerHelper().buildHorizontalGridShimmerWithAxisCount(
          crossAxisSpacing: 14.0,
          mainAxisSpacing: 14.0,
          item_count: 10,
          mainAxisExtent: 170.0,
          controller: homeData.featuredCategoryScrollController);
    } else if (homeData.featuredCategoryList.length > 0) {
      //snapshot.hasData
      return GridView.builder(
          padding:
              const EdgeInsets.only(left: 18, right: 18, top: 13, bottom: 20),
          scrollDirection: Axis.horizontal,
          controller: homeData.featuredCategoryScrollController,
          itemCount: homeData.featuredCategoryList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 170.0),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CategoryProducts(
                    category_id: homeData.featuredCategoryList[index].id,
                    category_name: homeData.featuredCategoryList[index].name,
                  );
                }));
              },
              child: Container(
                decoration: BoxDecorations.buildBoxDecoration_1(),
                child: Row(
                  children: <Widget>[
                    Container(
                        width: 40,
                        // height: 40,
                        child: ClipRRect(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(6), right: Radius.zero),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/placeholder.png',
                              image:
                                  homeData.featuredCategoryList[index].banner,
                              // fit: BoxFit.cover,
                            ))),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          homeData.featuredCategoryList[index].name,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          softWrap: true,
                          style:
                              TextStyle(fontSize: 12, color: MyTheme.font_grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    } else if (!homeData.isCategoryInitial &&
        homeData.featuredCategoryList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_category_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget buildHomeTodayDealProductHorizontalList(HomePresenter homeData) {
    if (homeData.isTodayDeal == true &&
        homeData.todaysDealProducts.length == 0) {
      return Row(
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 64) / 3)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 64) / 3)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 160) / 3)),
        ],
      );
    } else if (homeData.todaysDealProducts.length > 0) {
      return SingleChildScrollView(
        child: SizedBox(
          height: 276,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                homeData.fetchFeaturedProducts();
              }
              return true;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(18.0),
              separatorBuilder: (context, index) => SizedBox(
                width: 14,
              ),
              itemCount: homeData.todaysDealProducts.length,
              scrollDirection: Axis.horizontal,
              //itemExtent: 135,

              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: (context, index) {
                return (index == homeData.todaysDealProducts.length)
                    ? SpinKitFadingFour(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    : MiniProductCard(
                        id: homeData.todaysDealProducts[index].id,
                        image:
                            homeData.todaysDealProducts[index].thumbnail_image,
                        name: homeData.todaysDealProducts[index].name,
                        main_price:
                            homeData.todaysDealProducts[index].main_price,
                        stroked_price:
                            homeData.todaysDealProducts[index].stroked_price,
                        has_discount:
                            homeData.todaysDealProducts[index].has_discount,
                        is_wholesale:
                            homeData.todaysDealProducts[index].isWholesale,
                        discount: homeData.todaysDealProducts[index].discount,
                  product: homeData.todaysDealProducts[index],
                      );
              },
            ),
          ),
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_related_product,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  Widget buildHomeBestDealHorizontalList(HomePresenter homeData) {
    if (homeData.bestSellings == true &&
        homeData.bestSellingProducts.length == 0) {
      return Row(
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 64) / 3)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 64) / 3)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 160) / 3)),
        ],
      );
    } else if (homeData.bestSellingProducts.length > 0) {
      return SingleChildScrollView(
        child: SizedBox(
          height: 276,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                homeData.fetchFeaturedProducts();
              }
              return true;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(18.0),
              separatorBuilder: (context, index) => SizedBox(
                width: 14,
              ),
              itemCount: homeData.bestSellingProducts.length,
              scrollDirection: Axis.horizontal,
              //itemExtent: 135,

              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: (context, index) {
                return (index == homeData.bestSellingProducts.length)
                    ? SpinKitFadingFour(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    : MiniProductCard(
                        id: homeData.bestSellingProducts[index].id,
                        image:
                            homeData.bestSellingProducts[index].thumbnail_image,
                        name: homeData.bestSellingProducts[index].name,
                        main_price:
                            homeData.bestSellingProducts[index].main_price,
                        stroked_price:
                            homeData.bestSellingProducts[index].stroked_price,
                        has_discount:
                            homeData.bestSellingProducts[index].has_discount,
                        is_wholesale:
                            homeData.bestSellingProducts[index].isWholesale,
                        discount: homeData.bestSellingProducts[index].discount,
                  product: homeData.bestSellingProducts[index],
                      );
              },
            ),
          ),
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_related_product,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  Widget buildHomeFeatureProductHorizontalList(HomePresenter homeData) {
    if (homeData.isFeaturedProductInitial == true &&
        homeData.featuredProductList.length == 0) {
      return Row(
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 64) / 3)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 64) / 3)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 160) / 3)),
        ],
      );
    } else if (homeData.featuredProductList.length > 0) {
      return SingleChildScrollView(
        child: SizedBox(
          // height: 248,
          height: 276,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                homeData.fetchFeaturedProducts();
              }
              return true;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(18.0),
              separatorBuilder: (context, index) => SizedBox(
                width: 14,
              ),
              itemCount: homeData.totalFeaturedProductData! >
                      homeData.featuredProductList.length
                  ? homeData.featuredProductList.length + 1
                  : homeData.featuredProductList.length,
              scrollDirection: Axis.horizontal,
              //itemExtent: 135,

              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: (context, index) {
                return (index == homeData.featuredProductList.length)
                    ? SpinKitFadingFour(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    : MiniProductCard(
                        id: homeData.featuredProductList[index].id,
                        image:
                            homeData.featuredProductList[index].thumbnail_image,
                        name: homeData.featuredProductList[index].name,
                        main_price:
                            homeData.featuredProductList[index].main_price,
                        stroked_price:
                            homeData.featuredProductList[index].stroked_price,
                        has_discount:
                            homeData.featuredProductList[index].has_discount,
                        is_wholesale:
                            homeData.featuredProductList[index].isWholesale,
                        discount: homeData.featuredProductList[index].discount,
                  product: homeData.featuredProductList[index],
                      );
              },
            ),
          ),
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_related_product,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  Widget buildHomeMenuRow1(BuildContext context, HomePresenter homeData) {
    return Row(
      children: [
        if (homeData.isTodayDeal)
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TodaysDealProducts();
                }));
              },
              child: Container(
                height: 90,
                decoration: BoxDecorations.buildBoxDecoration_1(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                          height: 20,
                          width: 20,
                          child: Image.asset("assets/todays_deal.png")),
                    ),
                    Text(AppLocalizations.of(context)!.todays_deal_ucf,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          ),
        if (homeData.isTodayDeal && homeData.isFlashDeal) SizedBox(width: 14.0),
        if (homeData.isFlashDeal)
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FlashDealList();
                }));
              },
              child: Container(
                height: 90,
                decoration: BoxDecorations.buildBoxDecoration_1(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                          height: 20,
                          width: 20,
                          child: Image.asset("assets/flash_deal.png")),
                    ),
                    Text(AppLocalizations.of(context)!.flash_deal_ucf,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget buildHomeMenuRow2(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /* Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CategoryList(
                  is_top_category: true,
                );
              }));
            },
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width / 3 - 4,
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset("assets/top_categories.png")),
                  ),
                  Text(
                    AppLocalizations.of(context).home_screen_top_categories,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(132, 132, 132, 1),
                        fontWeight: FontWeight.w300),
                  )
                ],
              ),
            ),
          ),
        ),*/
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Filter(
                  selected_filter: "brands",
                );
              }));
            },
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width / 3 - 4,
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset("assets/brands.png")),
                  ),
                  Text(AppLocalizations.of(context)!.brands_ucf,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(132, 132, 132, 1),
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
        ),
        if (vendor_system.$)
          SizedBox(
            width: 10,
          ),
        if (vendor_system.$)
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TopSellers();
                }));
              },
              child: Container(
                height: 90,
                width: MediaQuery.of(context).size.width / 3 - 4,
                decoration: BoxDecorations.buildBoxDecoration_1(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                          height: 20,
                          width: 20,
                          child: Image.asset("assets/top_sellers.png")),
                    ),
                    Text(AppLocalizations.of(context)!.top_sellers_ucf,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildHomeCarouselSlider(context, HomePresenter homeData) {
    if (homeData.isCarouselInitial && homeData.carouselImageList.length == 0) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 18, right: 18, top: 0, bottom: 14),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (homeData.carouselImageList.length > 0) {
      return Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 18, right: 18, top: 0, bottom: 20),
            child: CarouselSlider.builder(
              itemCount: homeData.carouselImageList.length,
              itemBuilder: (context, index, realIndex) {
                final imageUrl = homeData.carouselImageList[index];
                return Container(
                  height: 180,
                  // color: Colors.green,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(imageUrl), fit: BoxFit.cover)),
                );
                // return Image.network(imageUrl, fit: BoxFit.cover);
              },
              options: CarouselOptions(
                // aspectRatio: 338 / 140,
                height: 170,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 1000),
                autoPlayCurve: Curves.easeInExpo,
                enlargeCenterPage: false,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentPage = index;
                  });
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    homeData.carouselImageList.length,
                    (index) => Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentPage == index
                                ? MyTheme.green
                                : MyTheme.white,
                          ),
                        )),
              ),
            ),
          ),
        ],
      );
      // return CarouselSlider(
      //   options: CarouselOptions(
      //       aspectRatio: 338 / 140,
      //       viewportFraction: 1,
      //       initialPage: 0,
      //       enableInfiniteScroll: true,
      //       reverse: false,
      //       autoPlay: true,
      //       autoPlayInterval: Duration(seconds: 5),
      //       autoPlayAnimationDuration: Duration(milliseconds: 1000),
      //       autoPlayCurve: Curves.easeInExpo,
      //       enlargeCenterPage: false,
      //       scrollDirection: Axis.horizontal,
      //       onPageChanged: (index, reason) {
      //         homeData.incrementCurrentSlider(index);
      //       }),
      //   items: homeData.carouselImageList.map((i) {
      //     return Builder(
      //       builder: (BuildContext context) {
      //         return Padding(
      //           padding: const EdgeInsets.only(
      //               left: 18, right: 18, top: 0, bottom: 20),
      //           child: Stack(
      //             children: <Widget>[
      //               Container(
      //                   // color: Colors.amber,
      //                   width: double.infinity,
      //                   height: 140,
      //                   //decoration: BoxDecorations.buildBoxDecoration_1(),
      //                   child: AIZImage.radiusImage(i, 6)),
      //               Align(
      //                 alignment: Alignment.bottomCenter,
      //                 child: Row(
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   children: homeData.carouselImageList.map((url) {
      //                     int index = homeData.carouselImageList.indexOf(url);
      //                     return Container(
      //                       width: 7.0,
      //                       height: 7.0,
      //                       margin: EdgeInsets.symmetric(
      //                           vertical: 10.0, horizontal: 4.0),
      //                       decoration: BoxDecoration(
      //                         shape: BoxShape.circle,
      //                         color: homeData.current_slider == index
      //                             ? MyTheme.white
      //                             : Color.fromRGBO(112, 112, 112, .3),
      //                       ),
      //                     );
      //                   }).toList(),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         );
      //       },
      //     );
      //   }).toList(),
      // );
    } else if (!homeData.isCarouselInitial &&
        homeData.carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget buildHomeBannerOne(context, HomePresenter homeData) {
    if (homeData.isBannerOneInitial &&
        homeData.bannerOneImageList.length == 0) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 18.0, right: 18, top: 10, bottom: 20),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (homeData.bannerOneImageList.length > 0) {
      return Padding(
        padding: app_language_rtl.$!
            ? const EdgeInsets.only(right: 9.0)
            : const EdgeInsets.only(left: 9.0),
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 270 / 120,
              viewportFraction: .75,
              initialPage: 0,
              padEnds: false,
              enableInfiniteScroll: false,
              reverse: false,
              autoPlay: true,
              onPageChanged: (index, reason) {
                // setState(() {
                //   homeData.current_slider = index;
                // });
              }),
          items: homeData.bannerOneImageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 9.0, right: 9, top: 20.0, bottom: 20),
                  child: Container(
                    //color: Colors.amber,
                    width: double.infinity,
                    child: AIZImage.radiusImage(i, 6),
                  ),
                );
              },
            );
          }).toList(),
        ),
      );
    } else if (!homeData.isBannerOneInitial &&
        homeData.bannerOneImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget buildHomeBannerTwo(context, HomePresenter homeData) {
    if (homeData.isBannerTwoInitial &&
        homeData.bannerTwoImageList.length == 0) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 18.0, right: 18, top: 10, bottom: 10),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (homeData.bannerTwoImageList.length > 0) {
      return Padding(
        padding: app_language_rtl.$!
            ? const EdgeInsets.only(right: 9.0)
            : const EdgeInsets.only(left: 9.0),
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 270 / 120,
              viewportFraction: 0.7,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 1000),
              autoPlayCurve: Curves.easeInExpo,
              enlargeCenterPage: false,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                // setState(() {
                //   homeData.current_slider = index;
                // });
              }),
          items: homeData.bannerTwoImageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 9.0, right: 9, top: 20.0, bottom: 10),
                  child: Container(
                      width: double.infinity,
                      child: AIZImage.radiusImage(i, 6)),
                );
              },
            );
          }).toList(),
        ),
      );
    } else if (!homeData.isCarouselInitial &&
        homeData.carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      // Don't show the leading button
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: MyTheme.black,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      flexibleSpace: Stack(
        children: [
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Filter();
                        },
                      ),
                    );
                  },
                  child: buildHomeSearchBox(context),
                ),
              ),
            ),
          ),
          Positioned(
            top: 13,
            left: 130,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                AppConfig.app_name,
                style: TextStyle(
                    color: MyTheme.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 20),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 50,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 60,
                // color: Colors.orange,
                width: 70,
                child: Image.asset(
                  "assets/app_logo.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
      // flexibleSpace: Padding(
      //   // padding:
      //   //     const EdgeInsets.only(top: 40.0, bottom: 22, left: 18, right: 18),
      //   padding:
      //       const EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
      //   child: GestureDetector(
      //     onTap: () {
      //       Navigator.push(context, MaterialPageRoute(builder: (context) {
      //         return Filter();
      //       }));
      //     },
      //     child: buildHomeSearchBox(context),
      //   ),
      // ),
    );
  }

  buildHomeSearchBox(BuildContext context) {
    return Container(
      height: 36,
      // decoration: BoxDecorations.buildBoxDecoration_1(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: MyTheme.black),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 20,
            spreadRadius: 0.0,
            offset: Offset(0.0, 10.0), // shadow direction: bottom right
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.search_anything,
              style: TextStyle(fontSize: 13.0, color: MyTheme.textfield_grey),
            ),
            Image.asset(
              'assets/search.png',
              height: 16,
              //color: MyTheme.dark_grey,
              color: MyTheme.dark_grey,
            )
          ],
        ),
      ),
    );
  }

  Container buildProductLoadingContainer(HomePresenter homeData) {
    return Container(
      height: homeData.showAllLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(
            homeData.totalAllProductData == homeData.allProductList.length
                ? AppLocalizations.of(context)!.no_more_products_ucf
                : AppLocalizations.of(context)!.loading_more_products_ucf),
      ),
    );
  }
}

Widget buildFlashDealList(context) {
  return FutureBuilder<FlashDealResponse>(
      future: FlashDealRepository().getFlashDeals(),
      builder: (context, AsyncSnapshot<FlashDealResponse> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(AppLocalizations.of(context)!.network_error),
          );
        } else if (snapshot.hasData) {
          FlashDealResponse flashDealResponse = snapshot.data!;
          return buildFlashDealListItem(flashDealResponse, 0, context);
        } else {
          return SizedBox();
        }
      });
}

final List<CountdownTimerController> _timerControllerList = [];

DateTime convertTimeStampToDateTime(int timeStamp) {
  var dateToTimeStamp = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  return dateToTimeStamp;
}

buildFlashDealListItem(
    FlashDealResponse flashDealResponse, index, BuildContext context) {
  DateTime end = convertTimeStampToDateTime(
      flashDealResponse.flashDeals![index].date!); // YYYY-mm-dd
  DateTime now = DateTime.now();
  int diff = end.difference(now).inMilliseconds;
  int endTime = diff + now.millisecondsSinceEpoch;

  void onEnd() {}

  CountdownTimerController timeController =
      CountdownTimerController(endTime: endTime, onEnd: onEnd);
  _timerControllerList.add(timeController);

  return SizedBox(
    // color: MyTheme.amber,
    height: MediaQuery.of(context).size.height > 690 ? 291 : 278,
    child: CountdownTimer(
      controller: _timerControllerList[index],
      widgetBuilder: (_, CurrentRemainingTime? time) {
        return GestureDetector(
          onTap: () {
            if (time == null) {
              ToastComponent.showDialog(
                AppLocalizations.of(context)!.flash_deal_has_ended,
                gravity: Toast.center,
                duration: Toast.lengthLong,
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return FlashDealProducts(
                      flash_deal_id: flashDealResponse.flashDeals![index].id,
                      flash_deal_name:
                          flashDealResponse.flashDeals![index].title,
                      bannerUrl: flashDealResponse.flashDeals![index].banner,
                      countdownTimerController: _timerControllerList[index],
                    );
                  },
                ),
              );
            }
          },
          child: Container(
            width: DeviceInfo(context).width,
            // margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecorations.buildBoxDecoration_1(),
            // color: Colors.orange,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              buildFlashDealBanner(flashDealResponse, index),
                              SizedBox(
                                width: MediaQuery.of(context).size.width > 360
                                    ? 10
                                    : 7,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SizedBox(
                                      width: 199,
                                      child: Text(
                                        flashDealResponse
                                                .flashDeals![index].title ??
                                            "",
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: MyTheme.golden),
                                      ),
                                    ),
                                  ),
                                  time == null
                                      ? Text(
                                          AppLocalizations.of(context)!
                                              .ended_ucf,
                                          style: TextStyle(
                                              color: MyTheme.accent_color,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        )
                                      : buildTimerRowRow(time),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: List.generate(
                            flashDealResponse.flashDeals![index].products
                                    ?.products?.length ??
                                6,
                            (productIndex) => buildFlashDealsProductItem(
                                flashDealResponse,
                                index,
                                productIndex,
                                context),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget buildFlashDealsProductItemShimmer() {
  return Container(
    margin: const EdgeInsets.only(left: 10),
    height: 50,
    width: 136,
    decoration: BoxDecoration(
      color: MyTheme.light_grey,
      borderRadius: BorderRadius.circular(6.0),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            ),
          ),
          child: ShimmerHelper().buildBasicShimmerCustomRadius(
            height: 50,
            width: 50,
            radius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: ShimmerHelper().buildBasicShimmer(height: 15, width: 60))
      ],
    ),
  );
}

Card buildFlashDealBanner(flashDealResponse, index) {
  return Card(
    elevation: 10,
    child: FadeInImage.assetNetwork(
      placeholder: 'assets/placeholder_rectangle.png',
      image: flashDealResponse.flashDeals[index].banner,
      fit: BoxFit.cover,
      width: 110,
      height: 112,
    ),
  );
}

Widget buildFlashDealBannerShimmer(BuildContext context) {
  return ShimmerHelper().buildBasicShimmerCustomRadius(
      width: DeviceInfo(context).width,
      height: 180,
      color: MyTheme.medium_grey_50);
}

Widget buildTimerRowRow(CurrentRemainingTime time) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        timerContainer(
          Text(
            timeText(time.days.toString(), default_length: 3),
            style: TextStyle(
                color: MyTheme.white,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        timerContainer(
          Text(
            timeText(time.hours.toString(), default_length: 2),
            style: TextStyle(
                color: MyTheme.white,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        timerContainer(
          Text(
            timeText(time.min.toString(), default_length: 2),
            style: TextStyle(
                color: MyTheme.white,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        timerContainer(
          Text(
            timeText(time.sec.toString(), default_length: 2),
            style: TextStyle(
                color: MyTheme.white,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
        // const SizedBox(
        //   width: 10,
        // ),
        // Image.asset(
        //   "assets/flash_deal.png",
        //   height: 20,
        //   color: MyTheme.golden,
        // ),
        // const Spacer(),
        // InkWell(
        //     onTap: () {},
        //     child: Row(
        //       children: [
        //         Text(
        //           AppLocalizations.of(context)!.view_more_ucf,
        //           style: const TextStyle(fontSize: 10, color: MyTheme.grey_153),
        //         ),
        //         const SizedBox(
        //           width: 3,
        //         ),
        //         //Image.asset("assets/arrow.png",height: 10,color: MyTheme.grey_153,),
        //         const Icon(
        //           Icons.arrow_forward_outlined,
        //           size: 10,
        //           color: MyTheme.grey_153,
        //         )
        //       ],
        //     ))
      ],
    ),
  );
}

String timeText(String txt, {default_length = 3}) {
  var blankZeros = default_length == 3 ? "000" : "00";
  var leadingZeros = "";
  if (default_length == 3 && txt.length == 1) {
    leadingZeros = "00";
  } else if (default_length == 3 && txt.length == 2) {
    leadingZeros = "0";
  } else if (default_length == 2 && txt.length == 1) {
    leadingZeros = "0";
  }

  var newtxt = (txt == "" || txt == null.toString()) ? blankZeros : txt;

  // print(txt + " " + default_length.toString());
  // print(newtxt);

  if (default_length > txt.length) {
    newtxt = leadingZeros + newtxt;
  }
  //print(newtxt);

  return newtxt;
}

Widget buildTimerRowRowShimmer(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Icon(
          Icons.watch_later_outlined,
          color: MyTheme.grey_153,
        ),
        const SizedBox(
          width: 10,
        ),
        ShimmerHelper().buildBasicShimmerCustomRadius(
            height: 30,
            width: 30,
            radius: BorderRadius.circular(6),
            color: MyTheme.shimmer_base),
        const SizedBox(
          width: 4,
        ),
        ShimmerHelper().buildBasicShimmerCustomRadius(
            height: 30,
            width: 30,
            radius: BorderRadius.circular(6),
            color: MyTheme.shimmer_base),
        const SizedBox(
          width: 4,
        ),
        ShimmerHelper().buildBasicShimmerCustomRadius(
            height: 30,
            width: 30,
            radius: BorderRadius.circular(6),
            color: MyTheme.shimmer_base),
        const SizedBox(
          width: 4,
        ),
        ShimmerHelper().buildBasicShimmerCustomRadius(
            height: 30,
            width: 30,
            radius: BorderRadius.circular(6),
            color: MyTheme.shimmer_base),
        const SizedBox(
          width: 10,
        ),
        Image.asset(
          "assets/flash_deal.png",
          height: 20,
          color: MyTheme.golden,
        ),
        const Spacer(),
        InkWell(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.view_more_ucf,
                  style: TextStyle(fontSize: 10, color: MyTheme.grey_153),
                ),
                const SizedBox(
                  width: 3,
                ),
                //Image.asset("assets/arrow.png",height: 10,color: MyTheme.grey_153,),
                const Icon(
                  Icons.arrow_forward_outlined,
                  size: 10,
                  color: MyTheme.grey_153,
                )
              ],
            ))
      ],
    ),
  );
}

Widget timerContainer(Widget child) {
  return Container(
    constraints: const BoxConstraints(minWidth: 45, minHeight: 45),
    alignment: Alignment.center,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      color: MyTheme.accent_color,
    ),
    child: child,
  );
}

Widget buildFlashDealsProductItem(
    flashDealResponse, flashDealIndex, productIndex, context) {
  return Card(
    child: Container(
      margin: const EdgeInsets.only(left: 10),
      height: 150,
      width: 140,
      decoration: BoxDecoration(
        color: MyTheme.white,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height > 690 ? 110 : 87,
            width: 160,
            child: ClipRRect(
              clipBehavior: Clip.none,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
              child: FadeInImage(
                placeholder: const AssetImage("assets/placeholder.png"),
                image: NetworkImage(flashDealResponse.flashDeals[flashDealIndex]
                    .products.products[productIndex].image),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.height > 690 ? 10.0 : 1,
                top: 5),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width > 360 ? 130 : 100,
                  child: Text(
                    flashDealResponse.flashDeals[flashDealIndex].products!
                        .products[productIndex].name,
                    maxLines: 2,
                    // convertPrice(flashDealResponse.flashDeals[flashDealIndex].products!
                    //     .products[productIndex].price),
                    style: TextStyle(
                        fontSize: 12,
                        color: MyTheme.accent_color,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width > 360 ? 10.0 : 1,
                top: 5),
            child: Row(
              children: [
                Text(
                  // flashDealResponse.flashDeals[flashDealIndex].products!
                  //     .products[productIndex].price,
                  convertPrice(flashDealResponse.flashDeals[flashDealIndex]
                      .products!.products[productIndex].price),
                  style: TextStyle(
                      fontSize: 12,
                      color: MyTheme.green,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
