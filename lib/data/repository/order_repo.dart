import 'dart:convert';

import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/data/model/body/place_order_body.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  OrderRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getRunningOrderList(int offset) async {
    return await apiClient.getData('${AppConstants.runningOrderListUri}?offset=$offset&limit=${100}');
  }

  Future<Response> getRunningSubscriptionOrderList(int offset) async {
    return await apiClient.getData('${AppConstants.runningSubscriptionOrderListUri}?offset=$offset&limit=${100}');
  }

  Future<Response> getHistoryOrderList(int offset) async {
    return await apiClient.getData('${AppConstants.historyOrderListUri}?offset=$offset&limit=10');
  }

  Future<Response> getOrderDetails(String orderID) async {
    return await apiClient.getData('${AppConstants.orderDetailsUri}$orderID');
  }

  Future<Response> cancelOrder(String orderID, String? reason) async {
    return await apiClient.postData(AppConstants.orderCancelUri, {'_method': 'put', 'order_id': orderID, 'reason': reason});
  }

  Future<Response> trackOrder(String? orderID) async {
    return await apiClient.getData('${AppConstants.trackUri}$orderID');
  }

  Future<Response> placeOrder(PlaceOrderBody orderBody) async {
    return await apiClient.postData(AppConstants.placeOrderUri, orderBody.toJson());
  }

  Future<Response> sendNotificationRequest(String orderId) async {
    return await apiClient.getData('${AppConstants.sendCheckoutNotificationUri}/$orderId');
  }

  Future<Response> getDeliveryManData(String orderID) async {
    return await apiClient.getData('${AppConstants.lastLocationUri}$orderID');
  }

  Future<Response> switchToCOD(String? orderID) async {
    return await apiClient.postData(AppConstants.codSwitchUri, {'_method': 'put', 'order_id': orderID});
  }

  Future<Response> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    return await apiClient.getData('${AppConstants.distanceMatrixUri}'
        '?origin_lat=${originLatLng.latitude}&origin_lng=${originLatLng.longitude}'
        '&destination_lat=${destinationLatLng.latitude}&destination_lng=${destinationLatLng.longitude}');
  }

  Future<Response> getRefundReasons() async {
    return await apiClient.getData(AppConstants.refundReasonsUri);
  }

  Future<Response> getCancelReasons() async {
    return await apiClient.getData('${AppConstants.orderCancellationUri}?offset=1&limit=30&type=customer');
  }

  Future<Response> submitRefundRequest(Map<String, String> body, XFile? data) async {
    return apiClient.postMultipartData(AppConstants.refundRequestUri, body,  [MultipartBody('image[]', data)]);
  }

  Future<Response> getExtraCharge(double? distance) async {
    return await apiClient.getData('${AppConstants.vehicleChargeUri}?distance=$distance');
  }

  Future<Response> getFoodsWithFoodIds(List<int?> ids) async {
    return await apiClient.postData(AppConstants.productListWithIdsUri, {'food_id': jsonEncode(ids)});
  }

  Future<Response> getSubscriptionList(int offset) async {
    return await apiClient.getData('${AppConstants.subscriptionListUri}?offset=$offset&limit=10');
  }

  Future<Response> updateSubscriptionStatus(int? subscriptionID, String? startDate, String? endDate, String status, String note, String? reason) async {
    return await apiClient.postData(
      '${AppConstants.subscriptionListUri}/$subscriptionID',
      {'_method': 'put', 'status': status, 'note': note, 'cancellation_reason': reason, 'start_date': startDate, 'end_date': endDate},
    );
  }

  Future<Response> getSubscriptionDeliveryLog(int? subscriptionID, int offset) async {
    return await apiClient.getData('${AppConstants.subscriptionListUri}/$subscriptionID/delivery-log?offset=$offset&limit=10');
  }

  Future<Response> getSubscriptionPauseLog(int? subscriptionID, int offset) async {
    return await apiClient.getData('${AppConstants.subscriptionListUri}/$subscriptionID/pause-log?offset=$offset&limit=10');
  }

  Future<Response> getDmTipMostTapped() async {
    return await apiClient.getData(AppConstants.mostTipsUri);
  }
}