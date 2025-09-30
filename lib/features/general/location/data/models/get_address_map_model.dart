// To parse this JSON data, do
//
//     final getAddressMapModel = getAddressMapModelFromJson(jsonString);

import 'dart:convert';

GetAddressMapModel getAddressMapModelFromJson(String str) => GetAddressMapModel.fromJson(json.decode(str));
String getAddressMapModelToJson(GetAddressMapModel data) => json.encode(data.toJson());
class GetAddressMapModel {
    int? placeId;
    String? licence;
    String? osmType;
    int? osmId;
    String? lat;
    String? lon;
    String? getAddressMapModelClass;
    String? type;
    int? placeRank;
    String? addresstype;
    String? name;
    String? displayName;
    Address? address;
    List<String>? boundingbox;

    GetAddressMapModel({
        this.placeId,
        this.licence,
        this.osmType,
        this.osmId,
        this.lat,
        this.lon,
        this.getAddressMapModelClass,
        this.type,
        this.placeRank,
        this.addresstype,
        this.name,
        this.displayName,
        this.address,
        this.boundingbox,
    });

    factory GetAddressMapModel.fromJson(Map<String, dynamic> json) => GetAddressMapModel(
        placeId: json["place_id"],
        licence: json["licence"],
        osmType: json["osm_type"],
        osmId: json["osm_id"],
        lat: json["lat"],
        lon: json["lon"],
        getAddressMapModelClass: json["class"],
        type: json["type"],
        placeRank: json["place_rank"],
        addresstype: json["addresstype"],
        name: json["name"],
        displayName: json["display_name"],
        address: json["address"] == null ? null : Address.fromJson(json["address"]),
        boundingbox: json["boundingbox"] == null ? [] : List<String>.from(json["boundingbox"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "place_id": placeId,
        "licence": licence,
        "osm_type": osmType,
        "osm_id": osmId,
        "lat": lat,
        "lon": lon,
        "class": getAddressMapModelClass,
        "type": type,
        "place_rank": placeRank,
        "addresstype": addresstype,
        "name": name,
        "display_name": displayName,
        "address": address?.toJson(),
        "boundingbox": boundingbox == null ? [] : List<dynamic>.from(boundingbox!.map((x) => x)),
    };
}

class Address {
    String? neighbourhood;
    String? suburb;
    String? city;
    String? state;
    String? iso31662Lvl4;
    String? postcode;
    String? country;
    String? countryCode;
    Address({
        this.neighbourhood,
        this.suburb,
        this.city,
        this.state,
        this.iso31662Lvl4,
        this.postcode,
        this.country,
        this.countryCode,
    });
    factory Address.fromJson(Map<String, dynamic> json) => Address(
        neighbourhood: json["neighbourhood"],
        suburb: json["suburb"],
        city: json["city"],
        state: json["state"],
        iso31662Lvl4: json["ISO3166-2-lvl4"],
        postcode: json["postcode"],
        country: json["country"],
        countryCode: json["country_code"],
    );
    Map<String, dynamic> toJson() => {
        "neighbourhood": neighbourhood,
        "suburb": suburb,
        "city": city,
        "state": state,
        "ISO3166-2-lvl4": iso31662Lvl4,
        "postcode": postcode,
        "country": country,
        "country_code": countryCode,
    };
}
