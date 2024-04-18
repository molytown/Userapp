import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MogoCodeDialog extends StatelessWidget {
  final Function(AddressModel address) onGetAddress;
  const MogoCodeDialog({Key? key, required this.onGetAddress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(width: 500, child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Image.asset(Images.logo, width: 100, height: 100),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Text(
              'mogo_code'.tr, textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Text(
              'enter_a_mogo_code_to_get_the_exact_location'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          MyTextField(
            controller: controller,
            hintText: 'mogo_code'.tr,
            inputAction: TextInputAction.done,
            fillColor: Theme.of(context).hintColor.withOpacity(0.1),
          ),
          const SizedBox(height: 30),

          GetBuilder<LocationController>(builder: (locationController) {
            return locationController.isLoading ? const Center(child: CircularProgressIndicator()) : Row(children: [
              Expanded(child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).disabledColor.withOpacity(0.3), minimumSize: const Size(Dimensions.webMaxWidth, 40), padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                ),
                child: Text(
                  'cancel'.tr, textAlign: TextAlign.center,
                  style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              )),
              const SizedBox(width: Dimensions.paddingSizeLarge),

              Expanded(child: CustomButton(
                buttonText: 'continue'.tr,
                onPressed: () async {
                  if(controller.text.trim().isEmpty) {
                    showCustomSnackBar('enter_mogo_code'.tr);
                  }else {
                    AddressModel? address = await locationController.getAddressByCode(controller.text.trim());
                    if(address != null) {
                      onGetAddress(address);
                    }
                  }
                },
                radius: Dimensions.radiusSmall, height: 40,
              )),
            ]);
          }),
          SizedBox(height: Get.find<AuthController>().isLoggedIn() ? Dimensions.paddingSizeLarge : 0),

          Get.find<AuthController>().isLoggedIn() ? CustomButton(
            buttonText: 'create_new_mogo_code'.tr,
            onPressed: () {
              Get.back();
              Get.toNamed(RouteHelper.getAddAddressRoute(false, 0));
            },
          ) : const SizedBox(),

        ]),
      )),
    );
  }
}
