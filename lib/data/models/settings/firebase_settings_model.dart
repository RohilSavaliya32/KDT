class FirebaseSettingsModel {
  final String? appId;
  final String? apiKey;
  final String? projectId;
  final String? authDomain;
  final String? storageBucket;
  final String? messagingSenderId;

  FirebaseSettingsModel({
    this.appId,
    this.apiKey,
    this.projectId,
    this.authDomain,
    this.storageBucket,
    this.messagingSenderId,
  });

  factory FirebaseSettingsModel.fromJson(Map<String, dynamic> json) {
    return FirebaseSettingsModel(
      appId: json['appId'],
      apiKey: json['apiKey'],
      projectId: json['projectId'],
      authDomain: json['authDomain'],
      storageBucket: json['storageBucket'],
      messagingSenderId: json['messagingSenderId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'apiKey': apiKey,
      'projectId': projectId,
      'authDomain': authDomain,
      'storageBucket': storageBucket,
      'messagingSenderId': messagingSenderId,
    };
  }
}