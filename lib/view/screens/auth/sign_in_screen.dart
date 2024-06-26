import 'dart:async';
import 'dart:io';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/bg_widget.dart';
import 'package:efood_multivendor/view/screens/auth/widget/sign_in_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  const SignInScreen({Key? key, required this.exitFromApp, required this.backFromThis}) : super(key: key);

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _canExit = GetPlatform.isWeb ? true : false;


  @override
  void initState() {
    super.initState();

    _phoneController.text =  Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
            return Future.value(false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
            return Future.value(false);
          }
        }else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context) ? null : !widget.exitFromApp ? AppBar(leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).textTheme.bodyLarge!.color),
        ), elevation: 0, backgroundColor: Colors.transparent) : null,
        body: SafeArea(child: BgWidget(
          child: Scrollbar(
            child: Center(
              child: Container(
                width: context.width > 700 ? 500 : context.width,
                padding: context.width > 700 ? const EdgeInsets.all(50) :  const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                margin: context.width > 700 ? const EdgeInsets.all(50) : EdgeInsets.zero,
                decoration: context.width > 700 ? BoxDecoration(
                  color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  boxShadow: ResponsiveHelper.isDesktop(context) ? null : [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
                ) : null,
                child: GetBuilder<AuthController>(builder: (authController) {

                  return Center(
                    child: SingleChildScrollView(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                        ResponsiveHelper.isDesktop(context) ? Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.clear),
                          ),
                        ) : const SizedBox(),

                        Image.asset(Images.logo, width: 100),
                        // const SizedBox(height: Dimensions.paddingSizeSmall),
                        // Image.asset(Images.logoName, width: 100),
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                        Align(
                          alignment: Alignment.topLeft,
                          child: Text('sign_in'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        SignInWidget(exitFromApp: widget.exitFromApp, backFromThis: widget.backFromThis),

                      ]),
                    ),
                  );
                }),
              ),
            ),
          ),
        )),
      ),
    );
  }

  // void _login(AuthController authController, String countryDialCode) async {
  //   String phone = _phoneController.text.trim();
  //   String password = _passwordController.text.trim();
  //   String numberWithCountryCode = countryDialCode+phone;
  //   PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
  //   numberWithCountryCode = phoneValid.phone;
  //
  //   if (phone.isEmpty) {
  //     showCustomSnackBar('enter_phone_number'.tr);
  //   }else if (!phoneValid.isValid) {
  //     showCustomSnackBar('invalid_phone_number'.tr);
  //   }else if (password.isEmpty) {
  //     showCustomSnackBar('enter_password'.tr);
  //   }else if (password.length < 6) {
  //     showCustomSnackBar('password_should_be'.tr);
  //   }else {
  //     authController.login(numberWithCountryCode, password, alreadyInApp: widget.backFromThis).then((status) async {
  //       if (status.isSuccess) {
  //         if (authController.isActiveRememberMe) {
  //           authController.saveUserNumberAndPassword(phone, password, countryDialCode);
  //         } else {
  //           authController.clearUserNumberAndPassword();
  //         }
  //         String token = status.message!.substring(1, status.message!.length);
  //         if(Get.find<SplashController>().configModel!.customerVerification! && int.parse(status.message![0]) == 0) {
  //           List<int> encoded = utf8.encode(password);
  //           String data = base64Encode(encoded);
  //           Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode, token, RouteHelper.signUp, data));
  //         }else {
  //           if(widget.backFromThis) {
  //             Get.back();
  //           }else {
  //             Get.find<LocationController>().navigateToLocationScreen('sign-in', offNamed: true);
  //           }
  //         }
  //       }else {
  //         showCustomSnackBar(status.message);
  //       }
  //     });
  //   }
  // }
}

