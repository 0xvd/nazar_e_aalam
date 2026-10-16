class WallpaperModel {
  bool? status;
  String? message;
  List<Data>? data;

  WallpaperModel({this.status, this.message, this.data});

  WallpaperModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? category;
  List<Wallpapers>? wallpapers;

  Data({this.category, this.wallpapers});

  Data.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    if (json['wallpapers'] != null) {
      wallpapers = <Wallpapers>[];
      json['wallpapers'].forEach((v) {
        wallpapers!.add(Wallpapers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    if (wallpapers != null) {
      data['wallpapers'] = wallpapers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Wallpapers {
  int? id;
  String? name;
  String? category;
  String? wallpaper;

  Wallpapers({this.id, this.name, this.category, this.wallpaper});

  Wallpapers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    category = json['category'];
    wallpaper = json['wallpaper'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['category'] = category;
    data['wallpaper'] = wallpaper;
    return data;
  }
}
