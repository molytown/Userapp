import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/html_type.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class HtmlButtonDialog extends StatelessWidget {
  const HtmlButtonDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<HtmlType> pages = [HtmlType.privacyPolicy, HtmlType.termsAndCondition, HtmlType.aboutUs];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(width: 500, child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 1/1,
              mainAxisSpacing: Dimensions.paddingSizeSmall, crossAxisSpacing: Dimensions.paddingSizeSmall,
            ),
            itemCount: pages.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Get.back();
                  if(pages[index] == HtmlType.privacyPolicy) {
                    Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy'));
                  }else if(pages[index] == HtmlType.termsAndCondition) {
                    Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition'));
                  }else {
                    Get.toNamed(RouteHelper.getHtmlRoute('about-us'));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    pages[index] == HtmlType.privacyPolicy ? 'privacy_policy'.tr : pages[index]
                        == HtmlType.termsAndCondition ? 'terms_conditions'.tr : 'about_us'.tr,
                    style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        )),
      ),
    );
  }
}
