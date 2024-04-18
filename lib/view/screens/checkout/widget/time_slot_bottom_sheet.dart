import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimeSlotBottomSheet extends StatelessWidget {
  final bool tomorrowClosed;
  final bool todayClosed;
  const TimeSlotBottomSheet({Key? key, required this.tomorrowClosed, required this.todayClosed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Container(
      width: context.width,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            !ResponsiveHelper.isDesktop(context) ? Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: ()=> Get.back(),
                child: Container(
                  height: 4, width: 35,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ) : const SizedBox(),

            Flexible(
              child: SingleChildScrollView(
                padding: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
                child: GetBuilder<OrderController>(
                    builder: (orderController) {
                      return GetBuilder<RestaurantController>(
                        builder: (restaurantController) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                            SizedBox(
                              width: isDesktop ? 200 : double.infinity,
                              child: Row(children: [
                                Expanded(
                                  child: tobView(context:context, title: 'today'.tr, isSelected: orderController.selectedDateSlot == 0, onTap: (){
                                    orderController.updateDateSlot(0);
                                  }),
                                ),

                                Expanded(
                                  child: tobView(context:context, title: 'tomorrow'.tr, isSelected: orderController.selectedDateSlot == 1, onTap: (){
                                    orderController.updateDateSlot(1);
                                  }),
                                ),
                              ]),
                            ),
                            SizedBox(height: isDesktop ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge),

                            ((orderController.selectedDateSlot == 0 && todayClosed) || (orderController.selectedDateSlot == 1 && tomorrowClosed))
                              ? Center(child: Text('restaurant_is_closed'.tr ))
                                : orderController.timeSlots != null
                              ? orderController.timeSlots!.isNotEmpty ? GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 5 : 3,
                                  mainAxisSpacing: Dimensions.paddingSizeSmall,
                                  crossAxisSpacing: Dimensions.paddingSizeExtraSmall,
                                  childAspectRatio: isDesktop ? 3.5 : 3
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: orderController.timeSlots!.length,
                                itemBuilder: (context, index){
                                  String time = (index == 0 && orderController.selectedDateSlot == 0
                                      && restaurantController.isRestaurantOpenNow(restaurantController.restaurant!.active!, restaurantController.restaurant!.schedules)
                                      ? 'now'.tr : '${DateConverter.dateToTimeOnly(orderController.timeSlots![index].startTime!)} '
                                      '- ${DateConverter.dateToTimeOnly(orderController.timeSlots![index].endTime!)}');
                                  return SlotWidget(
                                    title: time,
                                    isSelected: orderController.selectedTimeSlot == index,
                                    onTap: () {
                                      orderController.updateTimeSlot(index);
                                      orderController.setPreferenceTimeForView(time);
                                      orderController.showHideTimeSlot();
                                    },
                                  );
                            }) : Center(child: Text('no_slot_available'.tr)) : const Center(child: CircularProgressIndicator()),

                          ]);
                        }
                      );
                    }
                ),
              ),
            ),

           !isDesktop ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeSmall),
              child: Row(children: [
                Expanded(
                  child: CustomButton(
                    buttonText: 'cancel'.tr,
                    color: Theme.of(context).disabledColor,
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: CustomButton(
                    buttonText: 'schedule'.tr,
                    onPressed: () => Get.back(),
                  ),
                ),
              ]),
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget tobView({required BuildContext context, required String title, required bool isSelected, required Function() onTap}){
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(title, style: isSelected ? robotoBold.copyWith(color: Theme.of(context).primaryColor) : robotoMedium),
          Divider(color: isSelected ? Theme.of(context).primaryColor : ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).disabledColor, thickness: isSelected ? 2 : 1),
        ],
      ),
    );
  }
}
