import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
    bool? status;
    String? message;
    String? accessToken;

    LoginResponse({
        this.status,
        this.message,
        this.accessToken,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        status: json["status"],
        message: json["message"],
        accessToken: json["access_token"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "access_token": accessToken,
    };
}
