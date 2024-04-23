import 'dart:convert';
CustomOrderData CustomOrderDataFromJson(String str) => CustomOrderData.fromJson(json.decode(str));
String CustomOrderDataToJson(CustomOrderData data) => json.encode(data.toJson());

class CustomOrderData {
  List<CustomData>? customData;
  bool? success;
  int? status;

  CustomOrderData({this.customData, this.success, this.status});

  CustomOrderData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      customData = <CustomData>[];
      json['data'].forEach((v) {
        customData!.add(new CustomData.fromJson(v));
      });
    }
    success = json['success'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.customData != null) {
      data['data'] = this.customData!.map((v) => v.toJson()).toList();
    }
    data['success'] = this.success;
    data['status'] = this.status;
    return data;
  }
}

class CustomData {
  int? id;
  String? code;
  int? userId;
  String? status;
  String? file;
  String? type;
  String? extension;
  String? remarks;
  String? date;

  CustomData(
      {this.id,
        this.code,
        this.userId,
        this.status,
        this.file,
        this.type,
        this.extension,
        this.remarks,
        this.date});

  CustomData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    userId = json['user_id'];
    status = json['status'];
    file = json['file'];
    type = json['type'];
    extension = json['extension'];
    remarks = json['remarks'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['file'] = this.file;
    data['type'] = this.type;
    data['extension'] = this.extension;
    data['remarks'] = this.remarks;
    data['date'] = this.date;
    return data;
  }
}





// class CustomOrderData {
//   List<CustomData>? customData;
//   Pages? links;
//   Meta? meta;
//   bool? success;
//   int? status;
//
//   CustomOrderData(
//       {this.customData, this.links, this.meta, this.success, this.status});
//
//   CustomOrderData.fromJson(Map<String, dynamic> json) {
//     if (json['data'] != null) {
//       customData = <CustomData>[];
//       json['data'].forEach((v) {
//         customData!.add(new CustomData.fromJson(v));
//       });
//     }
//     links = json['links'] != null ? new Pages.fromJson(json['links']) : null;
//     meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
//     success = json['success'];
//     status = json['status'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.customData != null) {
//       data['data'] = this.customData!.map((v) => v.toJson()).toList();
//     }
//     if (this.links != null) {
//       data['links'] = this.links!.toJson();
//     }
//     if (this.meta != null) {
//       data['meta'] = this.meta!.toJson();
//     }
//     data['success'] = this.success;
//     data['status'] = this.status;
//     return data;
//   }
// }
//
// class CustomData {
//   int? id;
//   String? code;
//   int? userId;
//   String? status;
//   String? file;
//   String? type;
//   String? extension;
//   String? remarks;
//   String? date;
//
//   CustomData(
//       {this.id,
//         this.code,
//         this.userId,
//         this.status,
//         this.file,
//         this.type,
//         this.extension,
//         this.remarks,
//         this.date});
//
//   CustomData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     code = json['code'];
//     userId = json['user_id'];
//     status = json['status'];
//     file = json['file'];
//     type = json['type'];
//     extension = json['extension'];
//     remarks = json['remarks'];
//     date = json['date'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['code'] = this.code;
//     data['user_id'] = this.userId;
//     data['status'] = this.status;
//     data['file'] = this.file;
//     data['type'] = this.type;
//     data['extension'] = this.extension;
//     data['remarks'] = this.remarks;
//     data['date'] = this.date;
//     return data;
//   }
// }
//
// class Pages {
//   String? first;
//   String? last;
//   String? prev;
//   String? next;
//
//   Pages({this.first, this.last, this.prev, this.next});
//
//   Pages.fromJson(Map<String, dynamic> json) {
//     first = json['first'];
//     last = json['last'];
//     prev = json['prev'];
//     next = json['next'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['first'] = this.first;
//     data['last'] = this.last;
//     data['prev'] = this.prev;
//     data['next'] = this.next;
//     return data;
//   }
// }
//
// class Meta {
//   int? currentPage;
//   int? from;
//   int? lastPage;
//   List<Links>? links;
//   String? path;
//   int? perPage;
//   int? to;
//   int? total;
//
//   Meta(
//       {this.currentPage,
//         this.from,
//         this.lastPage,
//         this.links,
//         this.path,
//         this.perPage,
//         this.to,
//         this.total});
//
//   Meta.fromJson(Map<String, dynamic> json) {
//     currentPage = json['current_page'];
//     from = json['from'];
//     lastPage = json['last_page'];
//     if (json['links'] != null) {
//       links = <Links>[];
//       json['links'].forEach((v) {
//         links!.add(new Links.fromJson(v));
//       });
//     }
//     path = json['path'];
//     perPage = json['per_page'];
//     to = json['to'];
//     total = json['total'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['current_page'] = this.currentPage;
//     data['from'] = this.from;
//     data['last_page'] = this.lastPage;
//     if (this.links != null) {
//       data['links'] = this.links!.map((v) => v.toJson()).toList();
//     }
//     data['path'] = this.path;
//     data['per_page'] = this.perPage;
//     data['to'] = this.to;
//     data['total'] = this.total;
//     return data;
//   }
// }
//
// class Links {
//   String? url;
//   String? label;
//   bool? active;
//
//   Links({this.url, this.label, this.active});
//
//   Links.fromJson(Map<String, dynamic> json) {
//     url = json['url'];
//     label = json['label'];
//     active = json['active'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['url'] = this.url;
//     data['label'] = this.label;
//     data['active'] = this.active;
//     return data;
//   }
// }
