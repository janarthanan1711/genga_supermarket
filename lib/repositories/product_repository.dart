import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/category.dart';
import 'package:active_ecommerce_flutter/data_model/classified_ads_details_response.dart';
import 'package:active_ecommerce_flutter/data_model/classified_ads_response.dart';
import 'package:active_ecommerce_flutter/data_model/common_response.dart';
import 'package:active_ecommerce_flutter/data_model/product_details_response.dart';
import 'package:active_ecommerce_flutter/data_model/product_mini_response.dart';
import 'package:active_ecommerce_flutter/data_model/variant_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';

import '../data_model/variant_price_response.dart';

class ProductRepository {
  Future<CatResponse> getCategoryRes() async {
    String url = ("${AppConfig.BASE_URL}/seller/products/categories");

    var reqHeader = {
      "App-Language": app_language.$!,
      "Authorization": "Bearer ${access_token.$}",
      "Content-Type": "application/json"
    };

    final response = await ApiRequest.get(url: url, headers: reqHeader);

    return catResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getFeaturedProducts({page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/featured?page=${page}");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getBestSellingProducts() async {
    String url = ("${AppConfig.BASE_URL}/products/best-seller");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    print("Best Seller=========>${response.body}");
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getInHouseProducts({page}) async {
    String url = ("${AppConfig.BASE_URL}/products/inhouse?page=$page");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getTodaysDealProducts() async {
    String url = ("${AppConfig.BASE_URL}/products/todays-deal");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    print("Todays Deal=====>${response.body}");
    return productMiniResponseFromJson(response.body);

  }

  Future<ProductMiniResponse> getFlashDealProducts({int? id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/flash-deal-products/" + id.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getCategoryProducts(
      {int? id = 0, name = "", page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/category/" +
        id.toString() +
        "?page=${page}&name=${name}");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    print("category Products-------->${response.body}");
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getShopProducts(
      {int? id = 0, name = "", page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/seller/" +
        id.toString() +
        "?page=${page}&name=${name}");

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getBrandProducts(
      {int? id = 0, name = "", page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/brand/" +
        id.toString() +
        "?page=${page}&name=${name}");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    // print(url.toString());
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getFilteredProducts(
      {name = "",
      sort_key = "",
      page = 1,
      brands = "",
      categories = "",
      min = "",
      max = ""}) async {
    String url = ("${AppConfig.BASE_URL}/products/search" +
        "?page=${page}&name=${name}&sort_key=${sort_key}&brands=${brands}&categories=${categories}&min=${min}&max=${max}");

    print(url.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getDigitalProducts({
    page = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/products/digital?page=$page");
    print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    // print(response.body);
    return productMiniResponseFromJson(response.body);
  }

  Future<ClassifiedAdsResponse> getClassifiedProducts({
    page = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/classified/all?page=$page");
    print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    // print(response.body);
    return classifiedAdsResponseFromJson(response.body);
  }

  Future<ClassifiedAdsResponse> getOwnClassifiedProducts({
    page = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/classified/own-products?page=$page");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
    });
    // print(response.body);
    return classifiedAdsResponseFromJson(response.body);
  }

  Future<ClassifiedAdsResponse> getClassifiedOtherAds({
    id = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/classified/related-products/$id");
    print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    // print(response.body);
    return classifiedAdsResponseFromJson(response.body);
  }

  Future<ClassifiedProductDetailsResponse> getClassifiedProductsDetails(
      id) async {
    String url = ("${AppConfig.BASE_URL}/classified/product-details/$id");
    // print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    // print(response.body);
    return classifiedProductDetailsResponseFromJson(response.body);
  }

  Future<CommonResponse> getDeleteClassifiedProductResponse(id) async {
    String url = ("${AppConfig.BASE_URL}/classified/delete/$id");
    print(url.toString());

    final response = await ApiRequest.delete(url: url, headers: {
      "App-Language": app_language.$!,
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
    });

    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> getStatusChangeClassifiedProductResponse(
      id, status) async {
    String url = ("${AppConfig.BASE_URL}/classified/change-status/$id");

    var post_body = jsonEncode({"status": status});
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: post_body,
    );

    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> addProductResponse(postBody) async {
    String url = ("${AppConfig.BASE_URL}/classified/store");

    final response = await ApiRequest.post(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: postBody,
    );

    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> updateCustomerProductResponse(
      postBody, id, lang) async {
    String url = ("${AppConfig.BASE_URL}/classified/update/$id?lang=$lang");

    final response = await ApiRequest.post(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: postBody,
    );

    return commonResponseFromJson(response.body);
  }

  Future<ProductDetailsResponse> getProductDetails({int? id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/products/" + id.toString());
    print(url.toString());
    print(SystemConfig.systemCurrency!.code.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });

    return productDetailsResponseFromJson(response.body);
  }

  Future<ProductDetailsResponse> getDigitalProductDetails({int id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/products/" + id.toString());
    print(url.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });

    //print(response.body.toString());
    return productDetailsResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getRelatedProducts({int? id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/products/related/" + id.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getTopFromThisSellerProducts(
      {int? id = 0}) async {
    String url =
        ("${AppConfig.BASE_URL}/products/top-from-seller/" + id.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });

    // print("top selling product url ${url.toString()}");
    // print("top selling product ${response.body.toString()}");

    return productMiniResponseFromJson(response.body);
  }

  Future<VariantResponse> getVariantWiseInfo(
      {int? id = 0, color = '', variants = '', qty = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/variant/price");

    var postBody = jsonEncode({
      'id': id.toString(),
      "color": color,
      "variants": variants,
      "quantity": qty
    });

    final response = await ApiRequest.post(
        url: url,
        headers: {
          "App-Language": app_language.$!,
          "Content-Type": "application/json",
        },
        body: postBody);

    return variantResponseFromJson(response.body);
  }

  Future<VariantPriceResponse> getVariantPrice({id, quantity}) async {
    String url = ("${AppConfig.BASE_URL}/varient-price");

    var post_body = jsonEncode({"id": id, "quantity": quantity});
    print(url.toString());
    print(post_body.toString());
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "App-Language": app_language.$!,
          "Content-Type": "application/json",
        },
        body: post_body);

    return variantPriceResponseFromJson(response.body);
  }
}
