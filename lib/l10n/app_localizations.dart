import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @myShop.
  ///
  /// In en, this message translates to:
  /// **'My Shop'**
  String get myShop;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get newArrivals;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @popularProducts.
  ///
  /// In en, this message translates to:
  /// **'Popular Products'**
  String get popularProducts;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @productDetail.
  ///
  /// In en, this message translates to:
  /// **'Product Detail'**
  String get productDetail;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found.'**
  String get productNotFound;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @relatedProducts.
  ///
  /// In en, this message translates to:
  /// **'Related Products'**
  String get relatedProducts;

  /// No description provided for @loginToAdd.
  ///
  /// In en, this message translates to:
  /// **'Please login to add items to your cart.'**
  String get loginToAdd;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart!'**
  String get addedToCart;

  /// No description provided for @failedToAdd.
  ///
  /// In en, this message translates to:
  /// **'Failed to add item to cart.'**
  String get failedToAdd;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @loginToViewCart.
  ///
  /// In en, this message translates to:
  /// **'Login to see your cart items.'**
  String get loginToViewCart;

  /// No description provided for @loginOrRegister.
  ///
  /// In en, this message translates to:
  /// **'Login / Register'**
  String get loginOrRegister;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your Cart is Empty'**
  String get cartIsEmpty;

  /// No description provided for @cartIsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Looks like you haven\'t added\nanything to your cart yet.'**
  String get cartIsEmptyMessage;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove Item?'**
  String get removeItem;

  /// No description provided for @removeItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this item from your cart?'**
  String get removeItemConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @itemRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item removed successfully'**
  String get itemRemovedSuccess;

  /// No description provided for @itemRemovedFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove item'**
  String get itemRemovedFail;

  /// No description provided for @failedToUpdateQty.
  ///
  /// In en, this message translates to:
  /// **'Failed to update quantity'**
  String get failedToUpdateQty;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @loginToViewOrders.
  ///
  /// In en, this message translates to:
  /// **'Login to see your order history.'**
  String get loginToViewOrders;

  /// No description provided for @youHaveNoOrders.
  ///
  /// In en, this message translates to:
  /// **'You have no orders yet.'**
  String get youHaveNoOrders;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get cancelOrderConfirm;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @orderCancellationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order cancellation successful'**
  String get orderCancellationSuccess;

  /// No description provided for @orderCancellationFail.
  ///
  /// In en, this message translates to:
  /// **'Order cancellation failed'**
  String get orderCancellationFail;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{transactionId}'**
  String orderNumber(Object transactionId);

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient: {name}'**
  String recipient(Object name);

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String phone(Object phone);

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address: {address}'**
  String address(Object address);

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String date(Object date);

  /// No description provided for @orderPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order Placed Successfully!'**
  String get orderPlacedSuccess;

  /// No description provided for @thankYouPurchase.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your purchase.'**
  String get thankYouPurchase;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @youAreNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in.'**
  String get youAreNotLoggedIn;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @administratorAccess.
  ///
  /// In en, this message translates to:
  /// **'Administrator Access'**
  String get administratorAccess;

  /// No description provided for @deliveryPrices.
  ///
  /// In en, this message translates to:
  /// **'Delivery Prices'**
  String get deliveryPrices;

  /// No description provided for @sendNotification.
  ///
  /// In en, this message translates to:
  /// **'Send notification to all users'**
  String get sendNotification;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @attributes.
  ///
  /// In en, this message translates to:
  /// **'Attributes'**
  String get attributes;

  /// No description provided for @logos.
  ///
  /// In en, this message translates to:
  /// **'Logos'**
  String get logos;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @pendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get pendingOrders;

  /// No description provided for @ordersInProgress.
  ///
  /// In en, this message translates to:
  /// **'Orders In Progress'**
  String get ordersInProgress;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @remove_item_title.
  ///
  /// In en, this message translates to:
  /// **'Remove Item'**
  String get remove_item_title;

  /// No description provided for @remove_item_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this item from your cart?'**
  String get remove_item_message;

  /// No description provided for @item_removed_success.
  ///
  /// In en, this message translates to:
  /// **'Item removed successfully'**
  String get item_removed_success;

  /// No description provided for @item_removed_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove item'**
  String get item_removed_failed;

  /// No description provided for @update_quantity_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update quantity'**
  String get update_quantity_failed;

  /// No description provided for @no_name.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get no_name;

  /// No description provided for @proceed_to_checkout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceed_to_checkout;

  /// No description provided for @empty_cart_title.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get empty_cart_title;

  /// No description provided for @empty_cart_message.
  ///
  /// In en, this message translates to:
  /// **'Looks like you haven’t added anything yet.'**
  String get empty_cart_message;

  /// No description provided for @login_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue'**
  String get login_prompt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
