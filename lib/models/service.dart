class Service {
  String? serviceId;
  String? shopId;
  String? serviceName;
  String? servicePrice;
  String? serviceStatus;
  String? serviceDate;

  Service(
      {this.serviceId,
      this.shopId,
      this.serviceName,
      this.servicePrice,
      this.serviceStatus,
      this.serviceDate});

  Service.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'];
    shopId = json['shop_id'];
    serviceName = json['service_name'];
    servicePrice = json['service_price'];
    serviceStatus = json['service_status'];
    serviceDate = json['service_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_id'] = serviceId;
    data['shop_id'] = shopId;
    data['service_name'] = serviceName;
    data['service_price'] = servicePrice;
    data['service_status'] = serviceStatus;
    data['service_date'] = serviceDate;
    return data;
  }
}
