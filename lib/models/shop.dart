class Shop {
  String? shopId;
  String? userId;
  String? serviceImages;
  String? shopName;
  String? shopDesc;
  String? shopBank;
  String? shopBankAcc;
  String? shopAddress;
  String? shopDate;

  Shop(
      {this.shopId,
      this.userId,
      this.serviceImages,
      this.shopName,
      this.shopDesc,
      this.shopBank,
      this.shopBankAcc,
      this.shopAddress,
      this.shopDate});

  Shop.fromJson(Map<String, dynamic> json) {
    shopId = json['shop_id'];
    userId = json['user_id'];
    serviceImages = json['service_imagesNum'];
    shopName = json['shop_name'];
    shopDesc = json['shop_desc'];
    shopBank = json['shop_bank'];
    shopBankAcc = json['shop_bankAcc'];
    shopAddress = json['shop_address'];
    shopDate = json['shop_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shop_id'] = shopId;
    data['user_id'] = userId;
    data['service_imagesNum'] = serviceImages;
    data['shop_name'] = shopName;
    data['shop_desc'] = shopDesc;
    data['shop_bank'] = shopBank;
    data['shop_bankAcc'] = shopBankAcc;
    data['shop_address'] = shopAddress;
    data['shop_date'] = shopDate;
    return data;
  }
}
