class Service {
  String? serviceId;
  String? userId;
  String? serviceImages;
  String? serviceName;
  String? serviceDesc;
  String? servicePrice;
  String? serviceBank;
  String? serviceBankAcc;
  String? serviceAddress;
  String? serviceDate;

  Service(
      {this.serviceId,
      this.userId,
      this.serviceImages,
      this.serviceName,
      this.serviceDesc,
      this.servicePrice,
      this.serviceBank,
      this.serviceBankAcc,
      this.serviceAddress,
      this.serviceDate});

  Service.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'];
    userId = json['user_id'];
    serviceImages = json['service_imagesNum'];
    serviceName = json['service_name'];
    serviceDesc = json['service_desc'];
    servicePrice = json['service_price'];
    serviceBank = json['service_bank'];
    serviceBankAcc = json['service_bankAcc'];
    serviceAddress = json['service_address'];
    serviceDate = json['service_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_id'] = serviceId;
    data['user_id'] = userId;
    data['service_imagesNum'] = serviceImages;
    data['service_name'] = serviceName;
    data['service_desc'] = serviceDesc;
    data['service_price'] = servicePrice;
    data['service_bank'] = serviceBank;
    data['service_bankAcc'] = serviceBankAcc;
    data['service_address'] = serviceAddress;
    data['service_date'] = serviceDate;
    return data;
  }
}