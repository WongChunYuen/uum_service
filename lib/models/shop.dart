class Shop {
  String? shopId;
  String? userId;
  String? serviceImages;
  String? shopName;
  String? shopDesc;
  String? shopOpen;
  String? shopClose;
  String? shopAddress;
  String? shopStatus;
  String? shopDate;

  Shop(
      {this.shopId,
      this.userId,
      this.serviceImages,
      this.shopName,
      this.shopDesc,
      this.shopOpen,
      this.shopClose,
      this.shopAddress,
      this.shopStatus,
      this.shopDate});

  Shop.fromJson(Map<String, dynamic> json) {
    shopId = json['shop_id'];
    userId = json['user_id'];
    serviceImages = json['service_imagesNum'];
    shopName = json['shop_name'];
    shopDesc = json['shop_desc'];
    shopOpen = json['shop_openTime'];
    shopClose = json['shop_closeTime'];
    shopAddress = json['shop_address'];
    shopStatus = json['shop_status'];
    shopDate = json['shop_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shop_id'] = shopId;
    data['user_id'] = userId;
    data['service_imagesNum'] = serviceImages;
    data['shop_name'] = shopName;
    data['shop_desc'] = shopDesc;
    data['shop_openTime'] = shopOpen;
    data['shop_closeTime'] = shopClose;
    data['shop_address'] = shopAddress;
    data['shop_status'] = shopStatus;
    data['shop_date'] = shopDate;
    return data;
  }
}
