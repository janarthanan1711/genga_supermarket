import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../app_config.dart';
import '../data_model/check_response_model.dart';
import '../data_model/common_response.dart';
import '../data_model/custom_order_data.dart';
import '../data_model/uploaded_file_list_response.dart';
import '../helpers/response_check.dart';
import '../helpers/shared_value_helper.dart';
import 'api-request.dart';
import 'custom_order_response.dart';

class FileUploadRepository {
  Future<CommonResponse> fileUpload(File file) async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/file/upload");

    Map<String, String> header = {
      "App-Language": app_language.$!,
      "Authorization": "Bearer ${access_token.$}",
      "Content-Type":
          "multipart/form-data; boundary=<calculated when request is sent>",
      "Accept": "*/*",
      "System-Key": AppConfig.system_key
    };

    final httpReq = http.MultipartRequest("POST", url);
    httpReq.headers.addAll(header);

    final image = await http.MultipartFile.fromPath("aiz_file", file.path);

    httpReq.files.add(image);

    final response = await httpReq.send();
    var commonResponse =
        CommonResponse(result: false, message: "File upload failed");

    var responseDecode = await response.stream.bytesToString();

    print("file Upload Response=========>${responseDecode}");
    print("file Upload Responsesssssss=========>${httpReq.files}");

    if (response.statusCode == 200) {
      try {
        commonResponse = commonResponseFromJson(responseDecode);
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
    }
    return commonResponse;
  }

  Future<UploadedFilesListResponse> getFiles(page, search, type, sort) async {
    String url =
        ("${AppConfig.BASE_URL}/file/all?page=$page&search=$search&type=$type&sort=$sort");
    final response = await ApiRequest.get(url: url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$!,
      "System-Key": AppConfig.system_key
    });

    print("file Upload Data=======>${response.body}");

    return uploadedFilesListResponseFromJson(response.body);
  }

  Future<CommonResponse> deleteFile(id) async {
    String url = ("${AppConfig.BASE_URL}/file/delete/$id");
    final response = await ApiRequest.get(url: url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$!,
      "System-Key": AppConfig.system_key
    });

    return commonResponseFromJson(response.body);
  }

  Future<dynamic> getCustomOrderResponse(String image, String filename) async {
    var post_body = jsonEncode({"image": "${image}", "filename": "$filename"});
    print(post_body.toString());

    String url = ("${AppConfig.BASE_URL}/custom-order/create");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: post_body);

    bool checkResult = ResponseCheck.apply(response.body);

    print("Custom Order Post=========>${post_body}");

    print("Custom Order Response=======>${response.body}");

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return CustomOrderResponseFromJson(response.body);
  }


  Future<CustomOrderData> getCustomOrderDatas() async {
    String url = ("${AppConfig.BASE_URL}/custom-order");
    final response = await ApiRequest.get(url: url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$!,
      "System-Key": AppConfig.system_key
    });

    print("get Custom Order Data======>${response.body}");

    return CustomOrderDataFromJson(response.body);
  }

}
