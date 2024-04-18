
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/coupon_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/bg_widget.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/not_logged_in_screen.dart';
import 'package:efood_multivendor/view/base/web_page_title_widget.dart';
import 'package:efood_multivendor/view/screens/checkout/helper/checkout_helper.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/bottom_section_widget.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/order_place_button.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/top_section_widget.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel>? cartList;
  final bool fromCart;
  const CheckoutScreen({Key? key, required this.fromCart, required this.cartList}) : super(key: key);

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  double? _taxPercent = 0;
  bool? _isCashOnDeliveryActive;
  bool? _isDigitalPaymentActive;
  late bool _isWalletActive;
  late List<CartModel> _cartList;

  List<AddressModel> address = [];
  bool firstTime = true;
  final tooltipController1 = JustTheController();
  final tooltipController2 = JustTheController();
  final tooltipController3 = JustTheController();


  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {

      Get.find<OrderController>().streetNumberController.text = Get.find<LocationController>().getUserAddress()!.road ?? '';
      Get.find<OrderController>().houseController.text = Get.find<LocationController>().getUserAddress()!.house ?? '';
      Get.find<OrderController>().floorController.text = Get.find<LocationController>().getUserAddress()!.floor ?? '';
      Get.find<OrderController>().couponController.text = '';

      Get.find<OrderController>().getDmTipMostTapped();
      Get.find<OrderController>().setPreferenceTimeForView('', isUpdate: false);
      if(Get.find<OrderController>().isPartialPay){
        Get.find<OrderController>().changePartialPayment(isUpdate: false);
      }

      Get.find<LocationController>().getZone(
          Get.find<LocationController>().getUserAddress()!.latitude,
          Get.find<LocationController>().getUserAddress()!.longitude, false, updateInAddress: true
      );
      Get.find<CouponController>().setCoupon('', isUpdate: false);

      Get.find<OrderController>().stopLoader(isUpdate: false);
      Get.find<OrderController>().updateTimeSlot(0, notify: false);

      if(Get.find<UserController>().userInfoModel == null) {
        Get.find<UserController>().getUserInfo();
      }
      if(Get.find<LocationController>().addressList == null) {
        Get.find<LocationController>().getAddressList(canInsertAddress: true);
      }
      _isCashOnDeliveryActive = Get.find<SplashController>().configModel!.cashOnDelivery;
      _isDigitalPaymentActive = Get.find<SplashController>().configModel!.digitalPayment;
      _isWalletActive = Get.find<SplashController>().configModel!.customerWalletStatus == 1;
      _cartList = [];
      widget.fromCart ? _cartList.addAll(Get.find<CartController>().cartList) : _cartList.addAll(widget.cartList!);
      Get.find<RestaurantController>().initCheckoutData(_cartList[0].product!.restaurantId);

      Get.find<CouponController>().getCouponList(restaurantId: _cartList[0].product!.restaurantId);

      Get.find<OrderController>().updateTips(
        Get.find<AuthController>().getDmTipIndex().isNotEmpty ? int.parse(Get.find<AuthController>().getDmTipIndex()) : 0, notify: false,
      );
      Get.find<OrderController>().tipController.text = Get.find<OrderController>().selectedTips != -1 ? AppConstants.tips[Get.find<OrderController>().selectedTips] : '';

    }
  }

  @override
  void dispose() {
    super.dispose();
    // _streetNumberController.dispose();
    // _houseController.dispose();
    // _floorController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      appBar: CustomAppBar(title: 'checkout'.tr),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: BgWidget(
        child: isLoggedIn ? GetBuilder<LocationController>(builder: (locationController) {
          return GetBuilder<RestaurantController>(builder: (restController) {
            bool todayClosed = false;
            bool tomorrowClosed = false;

            if(restController.restaurant != null) {
              todayClosed = restController.isRestaurantClosed(true, restController.restaurant!.active!, restController.restaurant!.schedules);
              tomorrowClosed = restController.isRestaurantClosed(false, restController.restaurant!.active!, restController.restaurant!.schedules);
              _taxPercent = restController.restaurant!.tax;
            }
            return GetBuilder<CouponController>(builder: (couponController) {
              return GetBuilder<OrderController>(builder: (orderController) {
                bool showTips = orderController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && !orderController.subscriptionOrder;
                double deliveryCharge = -1;
                double charge = -1;
                double? maxCodOrderAmount;
                if(restController.restaurant != null && orderController.distance != null && orderController.distance != -1 ) {

                  deliveryCharge = CheckoutHelper.getDeliveryCharge(restController: restController, orderController: orderController, returnDeliveryCharge: true)!;
                  charge = CheckoutHelper.getDeliveryCharge(restController: restController, orderController: orderController, returnDeliveryCharge: false)!;
                  maxCodOrderAmount = CheckoutHelper.getDeliveryCharge(restController: restController, orderController: orderController, returnMaxCodOrderAmount: true);

                }

                double price = 0;
                double? discount = 0;
                double? couponDiscount = couponController.discount;
                double tax = 0;
                bool taxIncluded = Get.find<SplashController>().configModel!.taxIncluded == 1;
                double addOns = 0;
                double subTotal = 0;
                double orderAmount = 0;
                bool restaurantSubscriptionActive = false;
                int subscriptionQty = orderController.subscriptionOrder ? 0 : 1;
                double additionalCharge =  Get.find<SplashController>().configModel!.additionalChargeStatus! ? Get.find<SplashController>().configModel!.additionCharge! : 0;

                if(restController.restaurant != null) {

                  restaurantSubscriptionActive =  restController.restaurant!.orderSubscriptionActive! && widget.fromCart;

                  subscriptionQty = CheckoutHelper.getSubscriptionQty(orderController: orderController, restaurantSubscriptionActive: restaurantSubscriptionActive);

                  for (var cartModel in _cartList) {
                    List<AddOns> addOnList = [];
                    for (var addOnId in cartModel.addOnIds!) {
                      for (AddOns addOns in cartModel.product!.addOns!) {
                        if (addOns.id == addOnId.id) {
                          addOnList.add(addOns);
                          break;
                        }
                      }
                    }

                    for (int index = 0; index < addOnList.length; index++) {
                      addOns = addOns + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
                    }
                    price = price + (cartModel.price! * cartModel.quantity!);
                    double? dis = (restController.restaurant!.discount != null
                        && DateConverter.isAvailable(restController.restaurant!.discount!.startTime, restController.restaurant!.discount!.endTime))
                        ? restController.restaurant!.discount!.discount : cartModel.product!.discount;
                    String? disType = (restController.restaurant!.discount != null
                        && DateConverter.isAvailable(restController.restaurant!.discount!.startTime, restController.restaurant!.discount!.endTime))
                        ? 'percent' : cartModel.product!.discountType;
                    discount = discount! + ((cartModel.price! - PriceConverter.convertWithDiscount(cartModel.price, dis, disType)!) * cartModel.quantity!);
                  }
                  if (restController.restaurant != null && restController.restaurant!.discount != null) {
                    if (restController.restaurant!.discount!.maxDiscount != 0 && restController.restaurant!.discount!.maxDiscount! < discount!) {
                      discount = restController.restaurant!.discount!.maxDiscount;
                    }
                    if (restController.restaurant!.discount!.minPurchase != 0 && restController.restaurant!.discount!.minPurchase! > (price + addOns)) {
                      discount = 0;
                    }
                  }
                  price = PriceConverter.toFixed(price);
                  addOns = PriceConverter.toFixed(addOns);
                  discount = PriceConverter.toFixed(discount!);
                  couponDiscount = PriceConverter.toFixed(couponDiscount!);
                  subTotal = price + addOns;
                  orderAmount = (price - discount) + addOns - couponDiscount;

                  if (orderController.orderType == 'take_away' || restController.restaurant!.freeDelivery!
                      || (Get.find<SplashController>().configModel!.freeDeliveryOver != null && orderAmount
                          >= Get.find<SplashController>().configModel!.freeDeliveryOver!) || couponController.freeDelivery) {
                    deliveryCharge = 0;
                  }
                }

                if(taxIncluded){
                  tax = orderAmount * _taxPercent! /(100 + _taxPercent!);
                }else {
                  tax = PriceConverter.calculation(orderAmount, _taxPercent, 'percent', 1);
                }
                tax = PriceConverter.toFixed(tax);
                deliveryCharge = PriceConverter.toFixed(deliveryCharge);
                double total = subTotal + deliveryCharge - discount - couponDiscount! + (taxIncluded ? 0 : tax) + (showTips ? orderController.tips : 0) + additionalCharge;

                total = PriceConverter.toFixed(total);
                orderController.setTotalAmount(total - (orderController.isPartialPay ? Get.find<UserController>().userInfoModel?.walletBalance ?? 0 : 0));

                return (orderController.distance != null && locationController.addressList != null && restController.restaurant != null) ? Column(
                  children: [
                    WebScreenTitleWidget(title: 'checkout'.tr),

                    Expanded(child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: FooterView(
                        child: Center(
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: ResponsiveHelper.isDesktop(context) ? Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                                Expanded(flex: 6, child: TopSectionWidget(
                                  charge: charge, deliveryCharge: deliveryCharge,
                                  locationController: locationController, tomorrowClosed: tomorrowClosed, todayClosed: todayClosed,
                                  price: price, discount: discount, addOns: addOns, restaurantSubscriptionActive: restaurantSubscriptionActive,
                                  showTips: showTips, isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
                                  isWalletActive: _isWalletActive, fromCart: widget.fromCart, total: total, tooltipController3: tooltipController3, tooltipController2: tooltipController2,
                                )),
                                const SizedBox(width: Dimensions.paddingSizeLarge),

                                Expanded(
                                  flex: 4,
                                  child: BottomSectionWidget(
                                    isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!, isWalletActive: _isWalletActive,
                                    orderController: orderController, total: total, subTotal: subTotal, discount: discount, couponController: couponController,
                                    taxIncluded: taxIncluded, tax: tax, deliveryCharge: deliveryCharge, restaurantController: restController, locationController: locationController,
                                    todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount, maxCodOrderAmount: maxCodOrderAmount,
                                    subscriptionQty: subscriptionQty, taxPercent: _taxPercent!, fromCart: widget.fromCart, cartList: _cartList,
                                    price: price, addOns: addOns, charge: charge,
                                  ),
                                )
                              ]),
                            ) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                              TopSectionWidget(
                                charge: charge, deliveryCharge: deliveryCharge,
                                locationController: locationController, tomorrowClosed: tomorrowClosed, todayClosed: todayClosed,
                                price: price, discount: discount, addOns: addOns, restaurantSubscriptionActive: restaurantSubscriptionActive,
                                showTips: showTips, isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
                                isWalletActive: _isWalletActive, fromCart: widget.fromCart, total: total, tooltipController3: tooltipController3, tooltipController2: tooltipController2,
                              ),

                              BottomSectionWidget(
                                isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!, isWalletActive: _isWalletActive,
                                orderController: orderController, total: total, subTotal: subTotal, discount: discount, couponController: couponController,
                                taxIncluded: taxIncluded, tax: tax, deliveryCharge: deliveryCharge, restaurantController: restController, locationController: locationController,
                                todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount, maxCodOrderAmount: maxCodOrderAmount,
                                subscriptionQty: subscriptionQty, taxPercent: _taxPercent!, fromCart: widget.fromCart, cartList: _cartList,
                                price: price, addOns: addOns, charge: charge,
                              ),
                            ]),
                          ),
                        ),
                      ),
                    )),

                    ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(
                                'total_amount'.tr,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                              ),
                              PriceConverter.convertAnimationPrice(
                                total * (orderController.subscriptionOrder ? (subscriptionQty == 0 ? 1 : subscriptionQty) : 1),
                                textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                              ),
                            ]),
                          ),

                          OrderPlaceButton(
                            orderController: orderController, restController: restController, locationController: locationController,
                            todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount, deliveryCharge: deliveryCharge,
                            tax: tax, discount: discount, total: total, maxCodOrderAmount: maxCodOrderAmount, subscriptionQty: subscriptionQty,
                            cartList: _cartList, isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
                            isWalletActive: _isWalletActive, fromCart: widget.fromCart,
                          )
                        ],
                      ),
                    ),

                  ],
                ) : const Center(child: CircularProgressIndicator());

              });
            });
          });
        }) : NotLoggedInScreen(callBack: (value){
          initCall();
          setState(() {});
        }),
      ),
    );
  }

}

















