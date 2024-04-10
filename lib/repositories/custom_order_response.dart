import 'dart:convert';

CustomOrderResponse CustomOrderResponseFromJson(String str) => CustomOrderResponse.fromJson(json.decode(str));

String CustomOrderResponseToJson(CustomOrderResponse data) => json.encode(data.toJson());
class CustomOrderResponse {
  bool? result;
  String? message;
  String? path;

  CustomOrderResponse({this.result, this.message, this.path});

  CustomOrderResponse.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    message = json['message'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['message'] = this.message;
    data['path'] = this.path;
    return data;
  }
}