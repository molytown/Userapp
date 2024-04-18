import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/response/order_details_model.dart';
import 'package:efood_multivendor/data/model/response/order_model.dart';
import 'package:efood_multivendor/data/model/response/subscription_schedule_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/bg_widget.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/web_page_title_widget.dart';
import 'package:efood_multivendor/view/screens/order/widget/bottom_view_widget.dart';
import 'package:efood_multivendor/view/screens/order/widget/order_info_section.dart';
import 'package:efood_multivendor/view/screens/order/widget/order_pricing_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  const OrderDetailsScreen({Key? key, required this.orderModel, required this.orderId}) : super(key: key);

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> with WidgetsBindingObserver {

  final ScrollController scrollController = ScrollController();

  void _loadData() async {
    await Get.find<OrderController>().trackOrder(widget.orderId.toString(), widget.orderModel, false);
    if(widget.orderModel == null) {
      await Get.find<SplashController>().getConfigData();
    }
    Get.find<OrderController>().getOrderCancelReasons();
    Get.find<OrderController>().getOrderDetails(widget.orderId.toString());
    if(Get.find<OrderController>().trackModel != null){
      Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel!, orderId: widget.orderId.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadData();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel!, orderId: widget.orderId.toString());
    }else if(state == AppLifecycleState.paused){
      Get.find<OrderController>().cancelTimer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    Get.find<OrderController>().cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.orderModel == null) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
          return true;
        } else {
          Get.back();
          return true;
        }
      },
      child: GetBuilder<OrderController>(builder: (orderController) {
          double? deliveryCharge = 0;
          double itemsPrice = 0;
          double? discount = 0;
          double? couponDiscount = 0;
          double? tax = 0;
          double addOns = 0;
          double? dmTips = 0;
          double additionalCharge = 0;
          bool showChatPermission = true;
          bool? taxIncluded = false;
          OrderModel? order = orderController.trackModel;
          bool subscription = false;
          List<String> schedules = [];
          if(orderController.orderDetails != null && order != null) {
            subscription = order.subscription != null;

            if(subscription) {
              if(order.subscription!.type == 'weekly') {
                List<String> weekDays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
                for(SubscriptionScheduleModel schedule in orderController.schedules!) {
                  schedules.add('${weekDays[schedule.day!].tr} (${DateConverter.convertTimeToTime(schedule.time!)})');
                }
              }else if(order.subscription!.type == 'monthly') {
                for(SubscriptionScheduleModel schedule in orderController.schedules!) {
                  schedules.add('${'day_capital'.tr} ${schedule.day} (${DateConverter.convertTimeToTime(schedule.time!)})');
                }
              }else {
                schedules.add(DateConverter.convertTimeToTime(orderController.schedules![0].time!));
              }
            }
            if(order.orderType == 'delivery') {
              deliveryCharge = order.deliveryCharge;
              dmTips = order.dmTips;
            }
            couponDiscount = order.couponDiscountAmount;
            discount = order.restaurantDiscountAmount;
            tax = order.totalTaxAmount;
            taxIncluded = order.taxStatus;
            additionalCharge = order.additionalCharge!;
            for(OrderDetailsModel orderDetails in orderController.orderDetails!) {
              for(AddOn addOn in orderDetails.addOns!) {
                addOns = addOns + (addOn.price! * addOn.quantity!);
              }
              itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
            }
            if(order.restaurant != null) {
              if (order.restaurant!.restaurantModel == 'commission') {
                showChatPermission = true;
              } else if (order.restaurant!.restaurantSubscription != null &&
                  order.restaurant!.restaurantSubscription!.chat == 1) {
                showChatPermission = true;
              } else {
                showChatPermission = false;
              }
            }
          }
          double subTotal = itemsPrice + addOns;
          double total = itemsPrice + addOns - discount! + (taxIncluded! ? 0 : tax!) + deliveryCharge! - couponDiscount! + dmTips! + additionalCharge;

        return Scaffold(
            appBar: CustomAppBar(title: subscription ? 'subscription_details'.tr : 'order_details'.tr, onBackPressed: () {
              if(widget.orderModel == null) {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              }else {
                Get.back();
              }
            }),
            endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
            body: SafeArea(
              child: BgWidget(child: (order != null && orderController.orderDetails != null) ? Column(children: [

                WebScreenTitleWidget(title: subscription ? 'subscription_details'.tr : 'order_details'.tr),

                Expanded(child: Scrollbar(controller: scrollController, child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: scrollController,
                  child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth,
                    child: ResponsiveHelper.isDesktop(context) ? Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Expanded(flex: 6, child: OrderInfoSection(order: order, orderController: orderController, schedules: schedules, showChatPermission: showChatPermission)),
                        const SizedBox(width: Dimensions.paddingSizeLarge),

                        Expanded(flex: 4,child: OrderPricingSection(
                          itemsPrice: itemsPrice, addOns: addOns, order: order, subTotal: subTotal, discount: discount,
                          couponDiscount: couponDiscount, tax: tax!, dmTips: dmTips, deliveryCharge: deliveryCharge,
                          total: total, orderController: orderController, orderId: widget.orderId,
                        ))

                      ]),
                    ) : Column(children: [

                      OrderInfoSection(order: order, orderController: orderController, schedules: schedules, showChatPermission: showChatPermission),

                      OrderPricingSection(
                        itemsPrice: itemsPrice, addOns: addOns, order: order, subTotal: subTotal, discount: discount,
                        couponDiscount: couponDiscount, tax: tax!, dmTips: dmTips, deliveryCharge: deliveryCharge,
                        total: total, orderController: orderController, orderId: widget.orderId,
                      ),

                    ]),
                  )),
                ))),

                !ResponsiveHelper.isDesktop(context) ? BottomViewWidget(orderController: orderController, order: order, orderId: widget.orderId, total: total) : const SizedBox(),


              ]) : const Center(child: CircularProgressIndicator()),),
            )

        );
      }),
    );
  }
}