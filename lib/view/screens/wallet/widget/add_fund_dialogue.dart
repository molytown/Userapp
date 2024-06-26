import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/wallet_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AddFundDialogue extends StatefulWidget {
  const AddFundDialogue({Key? key}) : super(key: key);

  @override
  State<AddFundDialogue> createState() => _AddFundDialogueState();
}

class _AddFundDialogueState extends State<AddFundDialogue> {
  final TextEditingController inputAmountController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isDigitalPaymentActive = false;

  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().isTextFieldEmpty('', isUpdate: false);
    Get.find<WalletController>().changeDigitalPaymentName('', isUpdate: false);
    isDigitalPaymentActive = Get.find<SplashController>().configModel!.digitalPayment ?? false;

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: (){
              Get.back();
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor.withOpacity(0.5),
              ),
              padding: const EdgeInsets.all(3),
              child: const Icon(Icons.clear),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        GetBuilder<WalletController>(
          builder: (walletController) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).cardColor,
              ),
              width: context.width * 0.9,
              height: walletController.amountEmpty && inputAmountController.text.isNotEmpty && Get.find<SplashController>().configModel!.activePaymentMethodList!.isNotEmpty
                  && isDigitalPaymentActive ? context.height * 0.5 : context.height * 0.34,
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(
                children: [

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text('add_fund_to_wallet'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text('add_fund_form_secured_digital_payment_gateways'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  CustomTextField(
                    hintText: 'enter_amount'.tr,
                    inputType: TextInputType.number,
                    focusNode: focusNode,
                    inputAction: TextInputAction.done,
                    controller: inputAmountController,
                    textAlign: TextAlign.center,
                    onChanged: (String value){
                      try{
                        if(double.parse(value) > 0){
                          walletController.isTextFieldEmpty(value);
                        }
                      }catch(e) {
                        // showCustomSnackBar('invalid_input'.tr);
                        walletController.isTextFieldEmpty('');
                      }
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  walletController.amountEmpty && isDigitalPaymentActive ? Row(children: [
                    Text('payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Expanded(child: Text('faster_and_secure_way_to_pay_bill'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor))),
                  ]) : const SizedBox(),

                  isDigitalPaymentActive ? Flexible(
                    child: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [

                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        walletController.amountEmpty ? ListView.builder(
                            itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              bool isSelected = Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == walletController.digitalPaymentName;
                              return InkWell(
                                onTap: (){
                                  walletController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
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
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                      ]),
                    ),
                  ) : Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Text('digital_payment_is_not_active'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                  ),

                  CustomButton(
                    buttonText: 'add_fund'.tr,
                    isLoading: walletController.isLoading,
                    onPressed: !isDigitalPaymentActive ? null : (){
                      if(inputAmountController.text.isEmpty){
                        showCustomSnackBar('please_provide_transfer_amount'.tr);
                      }else if(inputAmountController.text == '0'){
                        showCustomSnackBar('you_can_not_add_zero_amount_in_wallet'.tr);
                      }else if(walletController.digitalPaymentName == ''){
                        showCustomSnackBar('please_select_payment_method'.tr);
                      }else{
                        double amount = double.parse(inputAmountController.text.replaceAll(Get.find<LocationController>().getUserAddress()!.zoneData![0].zoneCurrency!, ''));
                        walletController.addFundToWallet(amount, walletController.digitalPaymentName!);
                      }
                    },
                  ),
                ],
              ),
            );
          }
        )
      ]),
    );
  }
}
