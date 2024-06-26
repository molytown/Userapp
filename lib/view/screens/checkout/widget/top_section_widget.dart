import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_dropdown.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/screens/address/widget/address_widget.dart';
import 'package:efood_multivendor/view/screens/cart/widget/delivery_option_button.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/order_type_widget.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/sections/coupon_section.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/sections/delivery_man_tips_section.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/sections/payment_section.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/sections/time_slot_section.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/subscription_view.dart';
import 'package:efood_multivendor/view/screens/location/widget/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
class TopSectionWidget extends StatelessWidget {
  final double charge;
  final double deliveryCharge;
  final LocationController locationController;
  final bool tomorrowClosed;
  final bool todayClosed;
  final double price;
  final double discount;
  final double addOns;
  final bool restaurantSubscriptionActive;
  final bool showTips;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final bool fromCart;
  final double total;
  final JustTheController tooltipController3;
  final JustTheController tooltipController2;

  const TopSectionWidget({
    Key? key, required this.charge, required this.deliveryCharge, required this.locationController,
    required this.tomorrowClosed, required this.todayClosed, required this.price, required this.discount,
    required this.addOns, required this.restaurantSubscriptionActive, required this.showTips,
    required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive, required this.isWalletActive,
    required this.fromCart, required this.total, required this.tooltipController3, required this.tooltipController2}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool takeAway = false;
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    GlobalKey<CustomDropdownState> dropDownKey = GlobalKey<CustomDropdownState>();
    AddressModel addressModel;

    return GetBuilder<OrderController>(
      builder: (orderController) {
        takeAway = (orderController.orderType == 'take_away');
        return GetBuilder<RestaurantController>(
          builder: (restController) {
            return Column(children: [

              SizedBox(height: !isDesktop && isCashOnDeliveryActive && restaurantSubscriptionActive ? Dimensions.paddingSizeSmall : 0),

              isCashOnDeliveryActive && restaurantSubscriptionActive ? Container(
                width: context.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, spreadRadius: 1, offset: const Offset(1, 2))],
                ),
                margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
                padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeLarge),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('order_type'.tr, style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Row(children: [
                    Expanded(child: OrderTypeWidget(
                      title: 'regular_order'.tr,
                      icon: Images.regularOrder,
                      isSelected: !orderController.subscriptionOrder,
                      onTap: () {
                        orderController.setSubscription(false);
                        if(orderController.isPartialPay){
                          orderController.changePartialPayment();
                        } else {
                          orderController.setPaymentMethod(-1);
                        }
                        orderController.updateTips(
                          Get.find<AuthController>().getDmTipIndex().isNotEmpty ? int.parse(Get.find<AuthController>().getDmTipIndex()) : 1, notify: false,
                        );
                      },
                    )),
                    SizedBox(width: isCashOnDeliveryActive ? Dimensions.paddingSizeSmall : 0),

                    Expanded(child: OrderTypeWidget(
                      title: 'subscription_order'.tr,
                      icon: Images.subscriptionOrder,
                      isSelected: orderController.subscriptionOrder,
                      onTap: () {
                        orderController.setSubscription(true);
                        orderController.addTips(0);
                        if(orderController.isPartialPay){
                          orderController.changePartialPayment();
                        } else {
                          orderController.setPaymentMethod(-1);
                        }
                      },
                    )),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  orderController.subscriptionOrder ? SubscriptionView(
                    orderController: orderController,
                  ) : const SizedBox(),
                  SizedBox(height: orderController.subscriptionOrder ? Dimensions.paddingSizeLarge : 0),
                ]),
              ) : const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              restController.restaurant != null ? Container(
                width: context.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, spreadRadius: 1, offset: const Offset(1, 2))],
                ),
                margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text('delivery_option'.tr, style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [

                    (Get.find<SplashController>().configModel!.homeDelivery! && restController.restaurant!.delivery!)
                        ? DeliveryOptionButton(
                      value: 'delivery', title: 'home_delivery'.tr, charge: charge,
                      isFree: restController.restaurant!.freeDelivery, total: total,
                    ) : const SizedBox(),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    (Get.find<SplashController>().configModel!.takeAway! && restController.restaurant!.takeAway!)
                        ? DeliveryOptionButton(
                      value: 'take_away', title: 'take_away'.tr, charge: deliveryCharge, isFree: true, total: total,
                    ) : const SizedBox(),

                  ])),
                  SizedBox(height: isDesktop ? Dimensions.paddingSizeDefault : 0),
                ]),
              ) : const SizedBox(),

              SizedBox(height: orderController.orderType != 'take_away' ? ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge : 0),

              (orderController.orderType != 'take_away' && !ResponsiveHelper.isDesktop(context)) ? Center(child: Text('${'delivery_charge'.tr}: ${(orderController.orderType == 'take_away'
                  || (orderController.orderType == 'delivery' ? restController.restaurant!.freeDelivery! : true)) ? 'free'.tr
                  : charge != -1 ? PriceConverter.convertPrice(orderController.orderType == 'delivery' ? charge : deliveryCharge)
                  : 'calculating'.tr}', textDirection: TextDirection.ltr)) : const SizedBox(),

              SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

              /// Time Slot
              TimeSlotSection(fromCart: fromCart, orderController: orderController, restController: restController, tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, tooltipController2: tooltipController2,),

              ///Delivery Address
              orderController.orderType != 'take_away' ? Container(
                margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, spreadRadius: 1, offset: const Offset(1, 2))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('deliver_to'.tr, style: robotoMedium),
                    InkWell(
                      onTap: () async{
                        dropDownKey.currentState?.toggleDropdown();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                        child: Icon(Icons.arrow_drop_down, size: 34, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ]),


                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        color: Colors.transparent,
                        border: Border.all(color: Colors.transparent)
                    ),
                    child: CustomDropdown<int>(
                      key: dropDownKey,
                      hideIcon: true,
                      onChange: (int? value, int index) async {

                        if(value == -1) {
                          var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, restController.restaurant!.zoneId));
                          if(address != null) {

                            restController.insertAddresses(Get.context!, address, notify: true);

                            orderController.streetNumberController.text = address.road ?? '';
                            orderController.houseController.text = address.house ?? '';
                            orderController.floorController.text = address.floor ?? '';

                            orderController.getDistanceInMeter(
                              LatLng(double.parse(address.latitude), double.parse(address.longitude )),
                              LatLng(double.parse(restController.restaurant!.latitude!), double.parse(restController.restaurant!.longitude!)),
                            );
                          }
                        } else if(value == -2) {
                          _checkPermission(() async {
                            addressModel = await locationController.getCurrentLocation(true, mapController: null, showSnackBar: true);

                            if(addressModel.zoneIds!.isNotEmpty) {

                              restController.insertAddresses(Get.context!, addressModel, notify: true);

                              orderController.getDistanceInMeter(
                                LatLng(
                                  locationController.position.latitude, locationController.position.longitude,
                                ),
                                LatLng(double.parse(restController.restaurant!.latitude!), double.parse(restController.restaurant!.longitude!)),
                              );
                            }
                          });

                        } else{
                          orderController.getDistanceInMeter(
                            LatLng(
                              double.parse(restController.address[value!].latitude!),
                              double.parse(restController.address[value].longitude!),
                            ),
                            LatLng(double.parse(restController.restaurant!.latitude!), double.parse(restController.restaurant!.longitude!)),
                          );
                          orderController.setAddressIndex(value);

                          orderController.streetNumberController.text = restController.address[value].road ?? '';
                          orderController.houseController.text = restController.address[value].house ?? '';
                          orderController.floorController.text = restController.address[value].floor ?? '';
                        }

                      },
                      dropdownButtonStyle: DropdownButtonStyle(
                        height: 0, width: double.infinity,
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      dropdownStyle: DropdownStyle(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      ),
                      items: restController.addressList,
                      child: const SizedBox(),

                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? 90 : 75),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        border: Border.all(color: Theme.of(context).primaryColor)
                    ),
                    child: AddressWidget(
                      address: (restController.address.length-1) >= orderController.addressIndex ? restController.address[orderController.addressIndex] : restController.address[0],
                      fromAddress: false, fromCheckout: true,
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeDefault),

                  !ResponsiveHelper.isDesktop(context) ? CustomTextField(
                    titleText: 'street_number'.tr,
                    inputType: TextInputType.streetAddress,
                    focusNode: orderController.streetNode,
                    nextFocus: orderController.houseNode,
                    controller: orderController.streetNumberController,
                  ) : const SizedBox(),
                  SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

                  Row(
                    children: [
                      ResponsiveHelper.isDesktop(context) ? Expanded(
                        child: CustomTextField(
                          titleText: 'street_number'.tr,
                          inputType: TextInputType.streetAddress,
                          focusNode: orderController.streetNode,
                          nextFocus: orderController.houseNode,
                          controller: orderController.streetNumberController,
                          showTitle: ResponsiveHelper.isDesktop(context),
                        ),
                      ) : const SizedBox(),
                      SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

                      Expanded(
                        child: CustomTextField(
                          titleText: 'house'.tr,
                          inputType: TextInputType.text,
                          focusNode: orderController.houseNode,
                          nextFocus: orderController.floorNode,
                          controller: orderController.houseController,
                          showTitle: ResponsiveHelper.isDesktop(context),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: CustomTextField(
                          titleText: 'floor'.tr,
                          inputType: TextInputType.text,
                          focusNode: orderController.floorNode,
                          inputAction: TextInputAction.done,
                          controller: orderController.floorController,
                          showTitle: ResponsiveHelper.isDesktop(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                ]),
              ) : const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeSmall),


              /// Coupon
              !ResponsiveHelper.isDesktop(context) ? CouponSection(
                charge: charge, orderController: orderController, price: price,
                discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, total: total,
              ) : const SizedBox(),
              SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

              ///DmTips
              DeliveryManTipsSection(
                takeAway: takeAway, tooltipController3: tooltipController3, orderController: orderController,
                totalPrice: total, onTotalChange: (double price) => total + price,
              ),

              SizedBox(height: (orderController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Dimensions.paddingSizeExtraSmall : 0),

              ///payment..
              ResponsiveHelper.isDesktop(context) ? PaymentSection(
                isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
                isWalletActive: isWalletActive, total: total, orderController: orderController,
              ) : const SizedBox(),

              SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

              ResponsiveHelper.isDesktop(context) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('additional_note'.tr, style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                CustomTextField(
                  controller: orderController.noteController,
                  titleText: 'ex_please_provide_extra_napkin'.tr,
                  maxLines: 3,
                  inputType: TextInputType.multiline,
                  inputAction: TextInputAction.done,
                  capitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
              ]) : const SizedBox(),

            ]);
          }
        );
      }
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    }else {
      onTap();
    }
  }
}
