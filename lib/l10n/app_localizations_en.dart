// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get myShop => 'My Shop';

  @override
  String get home => 'Home';

  @override
  String get orders => 'Orders';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get newArrivals => 'New Arrivals';

  @override
  String get promotions => 'Promotions';

  @override
  String get popularProducts => 'Popular Products';

  @override
  String get seeAll => 'See All';

  @override
  String get productDetail => 'Product Detail';

  @override
  String get loading => 'Loading...';

  @override
  String get productNotFound => 'Product not found.';

  @override
  String get size => 'Size';

  @override
  String get color => 'Color';

  @override
  String get quantity => 'Quantity';

  @override
  String get description => 'Description';

  @override
  String get relatedProducts => 'Related Products';

  @override
  String get loginToAdd => 'Please login to add items to your cart.';

  @override
  String get addedToCart => 'Added to cart!';

  @override
  String get failedToAdd => 'Failed to add item to cart.';

  @override
  String get myCart => 'My Cart';

  @override
  String get loginToViewCart => 'Login to see your cart items.';

  @override
  String get loginOrRegister => 'Login / Register';

  @override
  String get cartIsEmpty => 'Your Cart is Empty';

  @override
  String get cartIsEmptyMessage =>
      'Looks like you haven\'t added\nanything to your cart yet.';

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String get removeItem => 'Remove Item?';

  @override
  String get removeItemConfirm =>
      'Are you sure you want to remove this item from your cart?';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get itemRemovedSuccess => 'Item removed successfully';

  @override
  String get itemRemovedFail => 'Failed to remove item';

  @override
  String get failedToUpdateQty => 'Failed to update quantity';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get shipping => 'Shipping';

  @override
  String get total => 'Total';

  @override
  String get myOrders => 'My Orders';

  @override
  String get loginToViewOrders => 'Login to see your order history.';

  @override
  String get youHaveNoOrders => 'You have no orders yet.';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get cancelOrderConfirm =>
      'Are you sure you want to cancel this order?';

  @override
  String get no => 'No';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get orderCancellationSuccess => 'Order cancellation successful';

  @override
  String get orderCancellationFail => 'Order cancellation failed';

  @override
  String orderNumber(Object transactionId) {
    return 'Order #$transactionId';
  }

  @override
  String recipient(Object name) {
    return 'Recipient: $name';
  }

  @override
  String phone(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String address(Object address) {
    return 'Address: $address';
  }

  @override
  String date(Object date) {
    return 'Date: $date';
  }

  @override
  String get orderPlacedSuccess => 'Order Placed Successfully!';

  @override
  String get thankYouPurchase => 'Thank you for your purchase.';

  @override
  String get continueShopping => 'Continue Shopping';

  @override
  String get youAreNotLoggedIn => 'You are not logged in.';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get light => 'Light';

  @override
  String get system => 'System';

  @override
  String get dark => 'Dark';

  @override
  String get english => 'English';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get logout => 'Logout';

  @override
  String get administratorAccess => 'Administrator Access';

  @override
  String get deliveryPrices => 'Delivery Prices';

  @override
  String get sendNotification => 'Send notification to all users';

  @override
  String get users => 'Users';

  @override
  String get categories => 'Categories';

  @override
  String get attributes => 'Attributes';

  @override
  String get logos => 'Logos';

  @override
  String get products => 'Products';

  @override
  String get earnings => 'Earnings';

  @override
  String get pendingOrders => 'Pending Orders';

  @override
  String get ordersInProgress => 'Orders In Progress';

  @override
  String get settings => 'Settings';

  @override
  String get done => 'Done';

  @override
  String get remove_item_title => 'Remove Item';

  @override
  String get remove_item_message =>
      'Are you sure you want to remove this item from your cart?';

  @override
  String get item_removed_success => 'Item removed successfully';

  @override
  String get item_removed_failed => 'Failed to remove item';

  @override
  String get update_quantity_failed => 'Failed to update quantity';

  @override
  String get no_name => 'No name';

  @override
  String get proceed_to_checkout => 'Proceed to Checkout';

  @override
  String get empty_cart_title => 'Your cart is empty';

  @override
  String get empty_cart_message => 'Looks like you haven’t added anything yet.';

  @override
  String get login_prompt => 'Please log in to continue';
}
