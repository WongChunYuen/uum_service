// User object to store user data and pass it over the screen
class User {
  String? id;
  String? accstatus;
  String? image;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? verify;
  String? regdate;

  User(
      {required this.id,
      required this.accstatus,
      required this.image,
      required this.name,
      required this.email,
      required this.phone,
      required this.address,
      required this.verify,
      required this.regdate});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accstatus = json['accstatus'];
    image = json['image'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    verify = json['verify'];
    regdate = json['regdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['accstatus'] = accstatus;
    data['image'] = image;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['address'] = address;
    data['verify'] = verify;
    data['regdate'] = regdate;
    return data;
  }
}
