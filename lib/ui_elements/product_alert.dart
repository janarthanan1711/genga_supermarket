import 'package:active_ecommerce_flutter/helpers/main_helpers.dart';
import 'package:flutter/material.dart';
import '../../../controllers/product_controller.dart';
import '../../../data_model/product_mini_response.dart';
import '../../../my_theme.dart';

class ProductAlertBox extends StatelessWidget {
  final ProductController productController;
  final Product product;

  const ProductAlertBox(
      {super.key, required this.productController, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(6), bottom: Radius.zero),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: product.thumbnail_image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 190,
                    child: Text(
                      product.name!,
                      // overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        height: 46,
                        width: 190,
                        decoration: BoxDecoration(
                          border: Border.all(color: MyTheme.textfield_grey),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: productController.quantityController,
                          textAlign: TextAlign.center,
                          cursorRadius: Radius.circular(17),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Quantity",
                            hintStyle: TextStyle(color: MyTheme.textfield_grey)
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Container(
                        height: 46,
                        width: 190,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            border: Border.all(color: MyTheme.textfield_grey),
                            borderRadius: BorderRadius.circular(17)),
                        child: Center(
                          child: Text(convertPrice(product.main_price!)),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Stocks: ${productController.stock}"),
                      SizedBox(
                        width: 25,
                      ),
                      InkWell(
                        child: Container(
                          height: 34,
                          width: 89,
                          decoration: BoxDecoration(
                              border: Border.all(color: MyTheme.textfield_grey),
                              borderRadius: BorderRadius.circular(17),
                              color: MyTheme.accent_color),
                          child: Center(
                            child: Text(
                              "Add",
                              style: TextStyle(
                                  color: MyTheme.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        onTap: () async {
                          await productController.addToCart(
                              id: product.id,
                              context: context,
                              mode: "add_to_cart");
                          Navigator.pop(context);
                        },
                      ),
                      // SizedBox(width: 5,),
                      // InkWell(
                      //   child: Container(
                      //     height: 34,
                      //     width: 94,
                      //     decoration: BoxDecoration(
                      //         border: Border.all(color: MyTheme.textfield_grey),
                      //         borderRadius: BorderRadius.circular(17),
                      //         color: MyTheme.orange),
                      //     child: Center(
                      //       child: Text(
                      //         "Next",
                      //         style: TextStyle(
                      //             color: MyTheme.white,
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //     ),
                      //   ),
                      //   onTap: () async{
                      //     await  productController.addToCart(id: product.id,context: context,mode: "add_to_cart");
                      //   },
                      // ),
                    ],
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
