import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/repository/cart_repo.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class CartController extends GetxController implements GetxService {
  final CartRepo cartRepo;
  CartController({required this.cartRepo});

  List<CartModel> _cartList = [];

  List<CartModel> get cartList => _cartList;

  double _subTotal = 0;
  double _itemPrice = 0;
  double _itemDiscountPrice = 0;
  double _addOns = 0;
  List<List<AddOns>> _addOnsList = [];
  List<bool> _availableList = [];
  bool _addCutlery = false;
  int _notAvailableIndex = -1;
  List<String> notAvailableList = ['Remove it from my cart', 'I’ll wait until it’s restocked', 'Please cancel the order', 'Call me ASAP', 'Notify me when it’s back'];

  double get subTotal => _subTotal;
  double get itemPrice => _itemPrice;
  double get itemDiscountPrice => _itemDiscountPrice;
  double get addOns => _addOns;
  List<List<AddOns>> get addOnsList => _addOnsList;
  List<bool> get availableList => _availableList;
  bool get addCutlery => _addCutlery;
  int get notAvailableIndex => _notAvailableIndex;


  double calculationCart(){
    _itemPrice = 0 ;
    _itemDiscountPrice = 0;
    _subTotal = 0;
    _addOns = 0;
    _availableList= [];
    _addOnsList = [];
    for (var cartModel in _cartList) {
      List<AddOns> addOnList = [];
      for (var addOnId in cartModel.addOnIds!) {
        for(AddOns addOns in cartModel.product!.addOns!) {
          if(addOns.id == addOnId.id) {
            addOnList.add(addOns);
            break;
          }
        }
      }
      _addOnsList.add(addOnList);

      _availableList.add(DateConverter.isAvailable(cartModel.product!.availableTimeStarts, cartModel.product!.availableTimeEnds));

      for(int index=0; index<addOnList.length; index++) {
        _addOns = _addOns + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
      }
      _itemPrice = _itemPrice + (cartModel.price! * cartModel.quantity!);

      if(Get.find<RestaurantController>().restaurant != null && Get.find<RestaurantController>().restaurant!.discount != null) {
        double? dis = (Get.find<RestaurantController>().restaurant!.discount != null
            && DateConverter.isAvailable(Get.find<RestaurantController>().restaurant!.discount!.startTime, Get.find<RestaurantController>().restaurant!.discount!.endTime))
            ? Get.find<RestaurantController>().restaurant!.discount!.discount : cartModel.product!.discount;
        String? disType = (Get.find<RestaurantController>().restaurant!.discount != null
            && DateConverter.isAvailable(Get.find<RestaurantController>().restaurant!.discount!.startTime, Get.find<RestaurantController>().restaurant!.discount!.endTime))
            ? 'percent' : cartModel.product!.discountType;
        _itemDiscountPrice = _itemDiscountPrice + ((cartModel.price! - PriceConverter.convertWithDiscount(cartModel.price, dis, disType)!) * cartModel.quantity!);

        if (Get.find<RestaurantController>().restaurant!.discount!.maxDiscount != 0 && Get.find<RestaurantController>().restaurant!.discount!.maxDiscount! < _itemDiscountPrice) {
          _itemDiscountPrice = Get.find<RestaurantController>().restaurant!.discount!.maxDiscount!;
        }
        if (Get.find<RestaurantController>().restaurant!.discount!.minPurchase != 0 && Get.find<RestaurantController>().restaurant!.discount!.minPurchase! > (_itemPrice + _addOns)) {
          _itemDiscountPrice = 0;
        }

      }else {
        _itemDiscountPrice = _itemDiscountPrice + ((cartModel.price! - PriceConverter.convertWithDiscount(cartModel.price, cartModel.product!.discount, cartModel.product!.discountType)!) * cartModel.quantity!);
      }
    }
    _subTotal = (_itemPrice - _itemDiscountPrice) + _addOns;

    return _subTotal;
  }

  void getCartData() {
    _cartList = [];
    _cartList.addAll(cartRepo.getCartList());
    if(_cartList.isNotEmpty && _cartList[0].variations == null) {
      _cartList = [];
      cartRepo.addToCartList(_cartList);
    }
    calculationCart();
  }

  void addToCart(CartModel cartModel, int? index) {
    if(index != null && index != -1) {
      _cartList.replaceRange(index, index + 1, [cartModel]);

    }else {
      _cartList.add(cartModel);
    }
    cartRepo.addToCartList(_cartList);
    calculationCart();

    update();
  }

  void reorderAddToCart(List<CartModel> cartList) {
    clearCartList();
    _cartList.addAll(cartList);
    cartRepo.addToCartList(_cartList);
    calculationCart();

    update();
  }

  void setQuantity(bool isIncrement, CartModel cart, {int? cartIndex}) {
    int index = cartIndex ?? _cartList.indexOf(cart);
    if (isIncrement) {
      int? quantityLimit = _cartList[index].product!.quantityLimit;
      if(quantityLimit != null) {
        if(_cartList[index].quantity! >= quantityLimit && quantityLimit != 0) {
          showCustomSnackBar('${'maximum_quantity_limit'.tr} $quantityLimit', showToaster: true);
        } else {
          _cartList[index].quantity = _cartList[index].quantity! + 1;
        }
      }else {
        _cartList[index].quantity = _cartList[index].quantity! + 1;
      }
    } else {
      _cartList[index].quantity = _cartList[index].quantity! - 1;
    }
    cartRepo.addToCartList(_cartList);

    calculationCart();
    update();
  }

  void removeFromCart(int index) {
    _cartList.removeAt(index);
    cartRepo.addToCartList(_cartList);
    calculationCart();
    update();
  }

  void removeAddOn(int index, int addOnIndex) {
    _cartList[index].addOnIds!.removeAt(addOnIndex);
    cartRepo.addToCartList(_cartList);
    calculationCart();
    update();
  }

  void clearCartList() {
    _cartList = [];
    cartRepo.addToCartList(_cartList);
    calculationCart();
    update();
  }


  int isExistInCart(int? productID, int? cartIndex) {
    for(int index=0; index<_cartList.length; index++) {
      if(_cartList[index].product!.id == productID) {
        if((index == cartIndex)) {
          return -1;
        }else {
          return index;
        }
      }
    }
    return -1;
  }


  int? getCartIndex (Product product) {
    for(int index = 0; index < _cartList.length; index ++) {
      if(_cartList[index].product!.id == product.id ) {
        if(_cartList[index].product!.variations![0].multiSelect  != null){
          if(_cartList[index].product!.variations![0].multiSelect == product.variations![0].multiSelect){
            return index;
          }
        }
        else{
          return index;
        }

      }
    }
    return null;
  }

  bool existAnotherRestaurantProduct(int? restaurantID) {
    for(CartModel cartModel in _cartList) {
      if(cartModel.product!.restaurantId != restaurantID) {
        return true;
      }
    }
    return false;
  }

  void removeAllAndAddToCart(CartModel cartModel) {
    _cartList = [];
    _cartList.add(cartModel);
    cartRepo.addToCartList(_cartList);
    calculationCart();
    update();
  }

  void updateCutlery({bool isUpdate = true}){
    _addCutlery = !_addCutlery;
    if(isUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool isUpdate = true}){
    if(_notAvailableIndex == index){
      _notAvailableIndex = -1;
    }else {
      _notAvailableIndex = index;
    }
    if(isUpdate) {
      update();
    }
  }

  int cartQuantity(int productID) {
    int quantity = 0;
    for(CartModel cart in _cartList) {
      if(cart.product!.id == productID) {
        quantity += cart.quantity!;
      }
    }
    return quantity;
  }

}
