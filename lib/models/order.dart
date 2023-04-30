class MyOrder {
  String? userId;
  String? sellerId;
  String? shopId;
  String? shopName;
  String? serviceName;
  String? quantity;
  String? price;
  String? totalAmount;
  String? time;
  String? payment;
  String? remark;

  MyOrder(
      {this.userId,
      this.sellerId,
      this.shopId,
      this.shopName,
      this.serviceName,
      this.quantity,
      this.price,
      this.totalAmount,
      this.time,
      this.payment,
      this.remark});

  MyOrder.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    sellerId = json['sellerId'];
    shopId = json['shopId'];
    shopName = json['shopName'];
    serviceName = json['serviceName'];
    quantity = json['quantity'];
    price = json['price'];
    totalAmount = json['totalAmount'];
    time = json['time'];
    payment = json['payment'];
    remark = json['remark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['sellerId'] = sellerId;
    data['shopId'] = shopId;
    data['shopName'] = shopName;
    data['serviceName'] = serviceName;
    data['quantity'] = quantity;
    data['price'] = price;
    data['totalAmount'] = totalAmount;
    data['time'] = time;
    data['payment'] = payment;
    data['remark'] = remark;
    return data;
  }
}
