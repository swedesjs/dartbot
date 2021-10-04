import "package:dio/dio.dart";

enum IpResponseStatus { SUCCESS, FAIL, UNKNOWN }

class _IpResponse {
  Map<String, dynamic> options;
  _IpResponse(this.options);

  IpResponseStatus get status {
    final statusResponse = options["status"] as String;

    return statusResponse == "success"
        ? IpResponseStatus.SUCCESS
        : statusResponse == "fail"
            ? IpResponseStatus.FAIL
            : IpResponseStatus.UNKNOWN;
  }

  String get continent => options["continent"];
  String get continentCode => options["continentCode"];
  String get country => options["country"];
  String get countryCode => options["countryCode"];
  String get region => options["region"];
  String get regionName => options["regionName"];
  String get city => options["city"];
  String get district => options["district"];
  String get zip => options["zip"];
  String get timezone => options["timezone"];
  String get currency => options["currency"];
  String get isp => options["isp"];
  String get org => options["org"];
  String get as => options["as"];
  String get asname => options["asname"];
  String get reverse => options["reverse"];
  String get query => options["query"];

  num get lat => options["lat"];
  num get lon => options["lon"];
  num get offset => options["offset"];

  bool get mobile => options["mobile"];
  bool get proxy => options["proxy"];
  bool get hosting => options["hosting"];

  String get message => options["message"];
}

class IpService {
  Uri url;

  IpService(this.url);

  Future<_IpResponse> load() async {
    final response = await Dio().get("http://ip-api.com/json/${url.path}", queryParameters: {
      "fields":
          "status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon,timezone,offset,currency,isp,org,as,asname,reverse,mobile,proxy,hosting,query",
      "lang": "ru"
    });

    // ignore: avoid_as
    return _IpResponse(response.data as Map<String, dynamic>);
  }
}
