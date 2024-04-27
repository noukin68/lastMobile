class RequestResponse {
  final String uid;

  RequestResponse({required this.uid});

  factory RequestResponse.fromJson(Map<String, dynamic> json) {
    return RequestResponse(uid: json['uid']);
  }
}
