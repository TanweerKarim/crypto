class UserModel {
  final String name;
  final String uid;
  final String profilePic;
  final String deviceToken;
  final bool online;
  final bool istyping;
  final String totalFunds;
  final String profit;
  final String loss;

  UserModel({
    required this.name,
    required this.uid,
    required this.profilePic,
    required this.deviceToken,
    required this.online,
    required this.istyping,
    required this.totalFunds,
    required this.profit,
    required this.loss,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'profilePic': profilePic,
      'deviceToken': deviceToken,
      'online': online,
      'istyping': istyping,
      'totalFunds': totalFunds,
      'profit': profit,
      'loss': loss
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      profilePic: map['profilePic'] ?? '',
      deviceToken: map['deviceToken'] ?? '',
      online: map['online'] ?? false,
      istyping: map['istyping'] ?? false,
      totalFunds: map['totalFunds'] ?? '',
      profit: map['profit'] ?? '',
      loss: map['loss'] ?? '',
    );
  }
}
