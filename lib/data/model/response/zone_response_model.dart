
import 'package:efood_multivendor/data/model/response/zone_model.dart';

class ZoneResponseModel {
  final bool _isSuccess;
  final List<int> _zoneIds;
  final String? _message;
  final List<ZoneData> _zoneData;
  ZoneResponseModel(this._isSuccess, this._message, this._zoneIds, this._zoneData);

  String? get message => _message;
  List<int> get zoneIds => _zoneIds;
  bool get isSuccess => _isSuccess;
  List<ZoneData> get zoneData => _zoneData;
}

class ZoneData {
  int? id;
  String? name;
  Coordinates? coordinates;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? restaurantWiseTopic;
  String? customerWiseTopic;
  String? deliverymanWiseTopic;
  double? minimumShippingCharge;
  double? perKmShippingCharge;
  String? zoneCountry;
  String? zoneCurrency;
  bool? cod;
  List<DigitalPayment>? digitalPayment;
  double? maximumShippingCharge;
  double? maxCodOrderAmount;
  double? increasedDeliveryFee;
  int? increasedDeliveryFeeStatus;
  String? increaseDeliveryChargeMessage;

  ZoneData({
    this.id,
    this.status,
    this.minimumShippingCharge,
    this.increasedDeliveryFee,
    this.increasedDeliveryFeeStatus,
    this.perKmShippingCharge,
    this.maxCodOrderAmount,
    this.maximumShippingCharge,
    this.digitalPayment,
    this.zoneCountry,
    this.zoneCurrency,
    this.cod,
    this.coordinates,
    this.createdAt,
    this.customerWiseTopic,
    this.deliverymanWiseTopic,
    this.increaseDeliveryChargeMessage,
    this.name,
    this.restaurantWiseTopic,
    this.updatedAt,
  });

  ZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    minimumShippingCharge = json['minimum_shipping_charge']?.toDouble();
    increasedDeliveryFee = json['increased_delivery_fee']?.toDouble();
    increasedDeliveryFeeStatus = json['increased_delivery_fee_status'];
    perKmShippingCharge = json['per_km_shipping_charge']?.toDouble();
    maxCodOrderAmount = json['max_cod_order_amount']?.toDouble();
    maximumShippingCharge = json['maximum_shipping_charge']?.toDouble();
    zoneCountry = json['zone_country'];
    zoneCurrency = json['zone_currency'];
    cod = json['cod'];
    coordinates = json['coordinates'] != null ? Coordinates.fromJson(json['coordinates']) : null;
    createdAt = json['created_at'];
    customerWiseTopic = json['customer_wise_topic'];
    deliverymanWiseTopic = json['deliveryman_wise_topic'];
    increaseDeliveryChargeMessage = json['increase_delivery_charge_message'];
    name = json['name'];
    restaurantWiseTopic = json['restaurant_wise_topic'];
    updatedAt = json['updated_at'];
    if(json['digital_payment'] != null) {
      digitalPayment = [];
      json['digital_payment'].forEach((v) {
        digitalPayment!.add(DigitalPayment.fromJson(v));
      });
    }


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['increased_delivery_fee'] = increasedDeliveryFee;
    data['increased_delivery_fee_status'] = increasedDeliveryFeeStatus;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['max_cod_order_amount'] = maxCodOrderAmount;
    data['maximum_shipping_charge'] = maximumShippingCharge;
    data['zone_country'] = zoneCountry;
    data['zone_currency'] = zoneCurrency;
    data['cod'] = cod;
    if (coordinates != null) {
      data['coordinates'] = coordinates!.toJson();
    }
    data['created_at'] = createdAt;
    data['customer_wise_topic'] = customerWiseTopic;
    data['deliveryman_wise_topic'] = deliverymanWiseTopic;
    data['increase_delivery_charge_message'] = increaseDeliveryChargeMessage;
    data['name'] = name;
    data['restaurant_wise_topic'] = restaurantWiseTopic;
    data['updated_at'] = updatedAt;
    if (digitalPayment != null) {
      data['digital_payment'] = digitalPayment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

