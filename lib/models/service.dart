class Service {
  String? serviceId;
  String? userId;
  String? serviceName;
  String? serviceDesc;
  String? servicePrice;
  String? serviceBankAcc;
  String? serviceAddress;
  String? serviceState;
  String? serviceLocal;
  String? serviceLat;
  String? serviceLng;
  String? serviceDate;

  Service(
      {this.serviceId,
      this.userId,
      this.serviceName,
      this.serviceDesc,
      this.servicePrice,
      this.serviceBankAcc,
      this.serviceAddress,
      this.serviceState,
      this.serviceLocal,
      this.serviceLat,
      this.serviceLng,
      this.serviceDate});

  Service.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'];
    userId = json['user_id'];
    serviceName = json['service_name'];
    serviceDesc = json['service_desc'];
    servicePrice = json['service_price'];
    serviceBankAcc = json['service_bankAcc'];
    serviceAddress = json['service_address'];
    serviceState = json['service_state'];
    serviceLocal = json['service_local'];
    serviceLat = json['service_lat'];
    serviceLng = json['service_lng'];
    serviceDate = json['service_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_id'] = serviceId;
    data['user_id'] = userId;
    data['service_name'] = serviceName;
    data['service_desc'] = serviceDesc;
    data['service_price'] = servicePrice;
    data['service_bankAcc'] = serviceBankAcc;
    data['service_address'] = serviceAddress;
    data['service_state'] = serviceState;
    data['service_local'] = serviceLocal;
    data['service_lat'] = serviceLat;
    data['service_lng'] = serviceLng;
    data['service_date'] = serviceDate;
    return data;
  }
}