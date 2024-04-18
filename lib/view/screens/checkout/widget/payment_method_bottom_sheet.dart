import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/payment_button_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double totalPrice;
  final bool isSubscriptionPackage;
  const PaymentMethodBottomSheet({
    Key? key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.totalPrice, this.isSubscriptionPackage = false}) : super(key: key);

  @override
  State<PaymentMethodBottomSheet> createState() => _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  bool canSelectWallet = true;
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;

  @override
  void initState() {
    super.initState();
    Get.find<SplashController>().updateActivePaymentMethodList();
    if(!widget.isSubscriptionPackage){
      double walletBalance = Get.find<UserController>().userInfoModel!.walletBalance!;
      if(walletBalance < widget.totalPrice){
        canSelectWallet = false;
      }
      if(Get.find<OrderController>().isPartialPay){
        notHideWallet = false;
        if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'cod'){
          notHideCod = true;
          notHideDigital = false;
        } else if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'digital_payment'){
          notHideCod = false;
          notHideDigital = true;
        } else if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'both'){
          notHideCod = true;
          notHideDigital = true;
        }
      }
    }

  }
  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 550,
      child: GetBuilder<OrderController>(
        builder: (orderController) {
          return GetBuilder<AuthController>(
            builder: (authController) {
              return Column(mainAxisSize: MainAxisSize.min, children: [

                ResponsiveHelper.isDesktop(context) ? Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 30, width: 30,
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
                      child: const Icon(Icons.clear),
                    ),
                  ),
                ) : const SizedBox(),

                Container(
                  width: 550,
                  height: !ResponsiveHelper.isDesktop(context)
                      ? orderController.subscriptionOrder ? context.height * 0.35 : Get.find<SplashController>().configModel!.activePaymentMethodList!.length > 4 ? context.height * 0.8 : context.height * 0.6
                      : context.height * 0.55,
                  margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
                        : const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                  ),
                  child: Column(
                    children: [
                      !ResponsiveHelper.isDesktop(context) ? Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 4, width: 35,
                          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
                        ),
                      ) : const SizedBox(),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Align(alignment: Alignment.center, child: Text('payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                            !widget.isSubscriptionPackage && notHideCod ? Text('choose_payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)) : const SizedBox(),
                            SizedBox(height: !widget.isSubscriptionPackage && notHideCod ? Dimensions.paddingSizeExtraSmall : 0),

                            !widget.isSubscriptionPackage && notHideCod ? Text(
                              'click_one_of_the_option_below'.tr,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                            ) : const SizedBox(),
                            SizedBox(height: !widget.isSubscriptionPackage && notHideCod ? Dimensions.paddingSizeLarge : 0),

                            !widget.isSubscriptionPackage ? Row(children: [
                              Get.find<LocationController>().getUserAddress()!.zoneData![0].cod! && notHideCod ? Expanded(
                                child: PaymentButtonNew(
                                  icon: Images.codIcon,
                                  title: 'cash_on_delivery'.tr,
                                  isSelected: orderController.paymentMethodIndex == 0,
                                  onTap: () {
                                    orderController.setPaymentMethod(0);
                                  },
                                ),
                              ) : const SizedBox(),
                              SizedBox(width: widget.isWalletActive && notHideWallet && !orderController.subscriptionOrder ? Dimensions.paddingSizeLarge : 0),

                              widget.isWalletActive && notHideWallet && !orderController.subscriptionOrder ? Expanded(
                                child: PaymentButtonNew(
                                  icon: Images.partialWallet,
                                  title: 'pay_via_wallet'.tr,
                                  isSelected: orderController.paymentMethodIndex == 1,
                                  onTap: () {
                                    if(canSelectWallet) {
                                      orderController.setPaymentMethod(1);
                                    } else if(orderController.isPartialPay){
                                      showCustomSnackBar('you_can_not_user_wallet_in_partial_payment'.tr);
                                      Get.back();
                                    } else{
                                      showCustomSnackBar('your_wallet_have_not_sufficient_balance'.tr);
                                      Get.back();
                                    }
                                  },
                                ),
                              ) : const SizedBox(),

                            ]) : const SizedBox(),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            widget.isDigitalPaymentActive && notHideDigital && !orderController.subscriptionOrder ? Row(children: [
                              Text('pay_via_online'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                              Text(
                                'faster_and_secure_way_to_pay_bill'.tr,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                              ),
                            ]) : const SizedBox(),
                            SizedBox(height: /*widget.isNewPluginGetWays && */widget.isDigitalPaymentActive && notHideDigital ? Dimensions.paddingSizeLarge : 0),

                            widget.isDigitalPaymentActive && notHideDigital && !orderController.subscriptionOrder ? ListView.builder(
                                itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index){
                                  bool isSelected;
                                  if(widget.isSubscriptionPackage) {
                                    isSelected = authController.paymentIndex == 1 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == authController.digitalPaymentName;
                                  } else {
                                    isSelected = orderController.paymentMethodIndex == 2 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == orderController.digitalPaymentName;
                                  }
                                  return InkWell(
                                    onTap: (){

                                      if(widget.isSubscriptionPackage) {
                                        authController.setPaymentIndex(1);
                                        authController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                                      } else {
                                        orderController.setPaymentMethod(2);
                                        orderController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                                      child: Row(children: [
                                        Container(
                                          height: 20, width: 20,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                              border: Border.all(color: Theme.of(context).disabledColor)
                                          ),
                                          child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeDefault),

                                        CustomImage(
                                          height: 20, fit: BoxFit.contain,
                                          image: '${Get.find<SplashController>().configModel!.baseUrls!.gatewayImageUrl}/${Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImage!}',
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),

                                        Text(
                                          Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle ?? '',
                                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                        ),
                                      ]),
                                    ),
                                  );
                                }) : const SizedBox(),

                            const SizedBox(height: Dimensions.paddingSizeSmall),

                          ]),
                        ),
                      ),

                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                          child: CustomButton(
                            buttonText: 'select'.tr,
                            onPressed: () => Get.back(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]);
            }
          );
        }
      ),
    );
  }
}
