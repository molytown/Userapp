import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/bg_widget.dart';
import 'package:efood_multivendor/view/screens/auth/widget/sign_up_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
      body: SafeArea(child: BgWidget(
        child: Scrollbar(
          child: Center(
            child: Container(
              width: context.width > 700 ? 700 : context.width,
              padding: context.width > 700 ? const EdgeInsets.all(40) : const EdgeInsets.all(Dimensions.paddingSizeLarge),
              decoration: context.width > 700 ? BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ) : null,
              child: GetBuilder<AuthController>(builder: (authController) {

                return SingleChildScrollView(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                    ResponsiveHelper.isDesktop(context) ? Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.clear),
                      ),
                    ) : const SizedBox(),

                    Image.asset(Images.logo, width: 100),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('sign_up'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    const SignUpWidget(),

                  ]),
                );
              }),
            ),
          ),
        ),
      )),
    );
  }
}


