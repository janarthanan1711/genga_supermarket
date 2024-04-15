import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/product_details.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_alert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../data_model/product_mini_response.dart';
import '../helpers/shared_value_helper.dart';
import '../screens/auction_products_details.dart';

class ProductCard extends StatefulWidget {
  var identifier;
  int? id;
  String? image;
  String? name;
  String? main_price;
  String? stroked_price;
  bool? has_discount;
  bool? is_wholesale;
  var discount;
  Product product;

  ProductCard({
    Key? key,
    this.identifier,
    this.id,
    this.image,
    this.name,
    this.main_price,
    this.is_wholesale = false,
    this.stroked_price,
    this.has_discount,
    this.discount,
    required this.product
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

final ProductController productController = Get.put(ProductController());

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    //print((MediaQuery.of(context).size.width - 48 ) / 2);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return widget.identifier == 'auction'
                  ? AuctionProductsDetails(id: widget.id)
                  : ProductDetails(
                      id: widget.id,
                    );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1().copyWith(),
        child: Stack(
          children: [
            Column(children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: double.infinity,
                  child: ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(6), bottom: Radius.zero),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png',
                      image: widget.image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        widget.name!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: FontWeight.w400),
                      ),
                    ),

                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15,right: 15,top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.has_discount!
                        ? Text(
                          SystemConfig.systemCurrency != null
                              ? widget.stroked_price!.replaceAll(
                              SystemConfig.systemCurrency!.code!,
                              SystemConfig.systemCurrency!.symbol!)
                              : widget.stroked_price!,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: MyTheme.medium_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        )
                        : Container(
                      height: 8.0,
                    ),
                    Text(
                      SystemConfig.systemCurrency!.code != null
                          ? widget.main_price!.replaceAll(
                          SystemConfig.systemCurrency!.code!,
                          SystemConfig.systemCurrency!.symbol!)
                          : widget.main_price!,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0, top: 2,bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: MyTheme.accent_color,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.add,color: MyTheme.white,),
                        ),
                      ),
                      onTap: ()async{
                        await variantAlertDialog(context);
                      },
                    )
                  ],
                ),
              )
            ]),


            // discount and wholesale
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.has_discount!)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        margin: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          // color: const Color(0xffe62e04),
                          color: MyTheme.orange,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(6.0),
                            bottomLeft: Radius.circular(6.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x14000000),
                              offset: Offset(-1, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.discount ?? "",
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xffffffff),
                            fontWeight: FontWeight.w700,
                            height: 1.8,
                          ),
                          textHeightBehavior: TextHeightBehavior(
                              applyHeightToFirstAscent: false),
                          softWrap: false,
                        ),
                      ),
                    Visibility(
                      visible: whole_sale_addon_installed.$,
                      child: widget.is_wholesale != null && widget.is_wholesale!
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6.0),
                                  bottomLeft: Radius.circular(6.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0x14000000),
                                    offset: Offset(-1, 1),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                              child: Text(
                                "Wholesale",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: const Color(0xffffffff),
                                  fontWeight: FontWeight.w700,
                                  height: 1.8,
                                ),
                                textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false),
                                softWrap: false,
                              ),
                            )
                          : SizedBox.shrink(),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future variantAlertDialog(BuildContext context) async {
    // Set loading to true to display loader
    productController.isLoading.value = true;
    await productController.fetchProductDetailsMain(widget.id);
    // Set loading to false after data is fetched
    productController.isLoading.value = false;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        productController.quantityController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Container(
            height: 220,
            child: GetBuilder<ProductController>(
              builder: (productController) {
                if (productController.isLoading.value) {
                  // Show loader if isLoading is true
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  // Display content once data is loaded
                  // return Container();
                  return ProductAlertBox(
                    product: widget.product,
                    productController: productController,
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
