import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../custom/toast_component.dart';
import '../data_model/product_details_response.dart';
import '../data_model/product_mini_response.dart';
import '../helpers/shared_value_helper.dart';
import '../repositories/cart_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/wishlist_repository.dart';
import "package:get/get.dart";

import '../screens/login.dart';


class ProductController extends GetxController {
  // CartController cartController = Get.put(CartController());
  var isAddedToCart = true;
  var colorList = [];
  var selectedColorIndex = 0;
  DetailedProduct? productDetails;
  var productList = <DetailedProduct>[].obs;
  String? variant = "";
  int? quantity = 1;
  var totalPrice = "".obs;
  var stock_txt;
  final selectedChoices = [];
  var productImageList = [];
  var _choiceString = "";
  int? stock = 0;
  var productNewColorList = [];
  // var addressList = <AddressScheduleView>[].obs;
  var scheduledOrderData = 0.obs;

  // var quantityText = "1".obs;
  final quantityText = TextEditingController().obs;
  var itemsIndex = 0.obs;
  var getProductId = 0.obs;
  bool isInWishList = false;
  RxBool addToCarts = false.obs;
  RxInt selectedProductId = 0.obs;
  // var scheduledOrderList = <Data>[].obs;
  var addressCountry = ''.obs;
  var addressCity = ''.obs;
  var addressState = ''.obs;
  var addressPostal = ''.obs;
  var fullAddress = ''.obs;
  var scheduledAddressDetails = [].obs;
  RxMap addressDetails = {}.obs;
  var cityIdList = [].obs;
  var cityPrice = ''.obs;
  var wholeSalePrice = "".obs;
  var citypriceList = ''.obs;
  var wholeSalePriceList = ''.obs;
  RxBool cityAvailable = false.obs;
  RxBool wholeSaleAvailable = false.obs;
  RxBool isWholeSale = false.obs;
  RxBool isLoading = false.obs;
  TextEditingController quantityController = TextEditingController();

  @override
  void onClose() {
    clearAll();
    super.onClose();
  }

  @override
  void onInit() {
    // scheduledOrderList();
    super.onInit();
  }

  // ProductDetails productDetailz = ProductDetails();

  void setSelectedProduct(int productId) {
    addToCarts.value = true;
    update();
  }

  setProductDetailValues() async {
    if (productDetails != null) {
      // fetchVariantPrice();
      stock = productDetails!.current_stock;
      selectedChoices.clear();
      productDetails!.choice_options!.forEach((choiceOption) {
        selectedChoices.add(choiceOption.options![0]);
      });
      setChoiceString();
      update();
    }
  }

  setChoiceString() {
    _choiceString = selectedChoices.join(",").toString();
    update();
  }

  fetchProductDetailsMain(id) async {
    isLoading.value = true;
    var productDetailsResponse =
        await ProductRepository().getProductDetails(id: id);
    productDetails = productDetailsResponse.detailed_products![0];
    setProductDetailValues();
    getVariantData(id);
    fetchWishListCheckInfo(id);
    isLoading.value = false;
    update();
  }


  setQuantity(quantity) {
    quantityText.value.text = "${quantity ?? 0}";
    update();
  }

  getVariantData(id) async {
    var colorString = productNewColorList.isNotEmpty
        ? productNewColorList[selectedColorIndex].toString().replaceAll("#", "")
        : "";

    var variantResponse = await ProductRepository().getVariantWiseInfo(
        id: id, color: colorString, variants: _choiceString, qty: quantity);
    if (variantResponse.variantData != null) {
      stock = variantResponse.variantData!.stock;
      stock_txt = variantResponse.variantData!.stockTxt;
      if (quantity! > stock!) {
        quantity = stock;
      }
      variant = variantResponse.variantData!.variant;
      totalPrice.value = variantResponse.variantData!.price!;
      setQuantity(quantity);
      update();
    } else {
      // Handle null or unexpected response
      print("Error fetching Variants");
    }
  }



  // incrementQuantityCart(id, {context}) {
  //   if (quantity! < stock!) {
  //     quantity = (quantity!) + 1;
  //     // quantityText.value = quantity.toString();
  //     quantityText.value.text = quantity.toString();
  //     //fetchVariantPrice();
  //     getVariantData(id);
  //     update();
  //   } else if (quantity! < 1) {
  //     ToastComponent.showDialog("No Stocks Available",
  //         gravity: Toast.center, duration: Toast.lengthLong);
  //   } else if (quantity! >= quantity!) {
  //     ToastComponent.showDialog("Maximum Limit Reached",
  //         gravity: Toast.center, duration: Toast.lengthLong);
  //   }
  // }

  // decrementQuantityCart(id, {context}) {
  //   if (quantity! > 1) {
  //     quantity = quantity! - 1;
  //     // quantityText.value = quantity.toString();
  //     quantityText.value.text = quantity.toString();
  //     // calculateTotalPrice();
  //     // fetchVariantPrice();
  //     getVariantData(id);
  //     update();
  //   } else if (quantity! < 1) {
  //     addToCarts.value = false;
  //     update();
  //   } else {
  //     ToastComponent.showDialog("Need to select atleast one item",
  //         gravity: Toast.center, duration: Toast.lengthLong);
  //   }
  // }

  addToCart({mode, context, id}) async {
    if (is_logged_in.$ == false) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.you_need_to_log_in,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      return;
    }
    int quantity = int.parse(quantityController.text);
    if (quantity > productDetails!.current_stock!) {
      ToastComponent.showDialog("Cannot Add to cart more than stock",
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      // quantity = int.parse(quantityController.text);
      update();
      var cartAddResponse = await CartRepository()
          .getCartAddResponse(id, variant, user_id.$, quantity);

      if (cartAddResponse.result == false) {
        ToastComponent.showDialog(cartAddResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);
        return;
      } else {
        // Provider.of<CartCounter>(context, listen: false).getCount();
        // cartController.getCount();
        if (mode == "add_to_cart") {
            ToastComponent.showDialog(cartAddResponse.message,
                gravity: Toast.center, duration: Toast.lengthLong);
            // Navigator.push(context, MaterialPageRoute(builder: (context) {
            //   return Cart(has_bottomnav: false);
            // })).then((value) {
            //   // onPopped(value);
            // });
          // reset();
          // fetchAll();
        } else if (mode == 'buy_now') {
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return Cart(has_bottomnav: false);
          // })).then((value) {
          //   // onPopped(value);
          // });
        }
      }
    }
  }

  fetchWishListCheckInfo(id) async {
    var wishListCheckResponse =
        await WishListRepository().isProductInUserWishList(
      product_id: id,
    );
    //print("p&u:" + widget.id.toString() + " | " + _user_id.toString());
    isInWishList = wishListCheckResponse.is_in_wishlist;
    update();
  }

  addToWishList(id, {context}) async {
    var wishListCheckResponse = await WishListRepository().add(product_id: id);
    //print("p&u:" + widget.id.toString() + " | " + _user_id.toString());
    isInWishList = wishListCheckResponse.is_in_wishlist;
    update();
  }

  removeFromWishList(id, {context}) async {
    var wishListCheckResponse =
        await WishListRepository().remove(product_id: id);
    //print("p&u:" + widget.id.toString() + " | " + _user_id.toString());
    isInWishList = wishListCheckResponse.is_in_wishlist;
    update();
  }

  onWishTap(context, id) {
    if (is_logged_in.$ == false) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.you_need_to_log_in,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }
    if (isInWishList) {
      isInWishList = false;
      ToastComponent.showDialog("Remove From Wishlist",
          gravity: Toast.center, duration: Toast.lengthLong);
      removeFromWishList(id);
      update();
    } else {
      isInWishList = true;
      ToastComponent.showDialog("Added to Wishlist",
          gravity: Toast.center, duration: Toast.lengthLong);
      addToWishList(id);
      update();
    }
  }




  // fetchCity(id){
  //   cityIdList.add(productDetails!.city![0].cityId);
  //   for(var cityid in cityIdList[0].ci)
  // }

  // fetchAddressById(id) async {
  //   try {
  //     var getAddress = await AddressRepository().getAddressResponseById(id);
  //     var addressData = getAddress
  //     as AddressViewFromSchedule; // Assuming getAddress is already an instance of AddressViewFromSchedule
  //     for (AddressScheduleView address in addressData.data ?? []) {
  //       print("Address Details: ${address}");
  //       addressCity.value = address.cityName!;
  //       addressState.value = address.stateName!;
  //       addressCountry.value = address.countryName!;
  //       addressPostal.value = address.postalCode!;
  //     }
  //     print("Scheduled Address Details=======>$addressDetails");
  //   } catch (e) {
  //     print("Error fetching address details: $e");
  //   }
  // }

  clearAll() {
    // restProductDetailValues();
    // _currentImage = 0;
    productImageList.clear();
    colorList.clear();
    selectedChoices.clear();
    _choiceString = "";
    variant = "";
    selectedColorIndex = 0;
    quantity = 1;
    isInWishList = false;
    getProductId.value = 0;
    scheduledAddressDetails.clear();
  }
}
