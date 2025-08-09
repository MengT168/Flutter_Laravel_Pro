// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get myShop => 'ហាងរបស់ខ្ញុំ';

  @override
  String get home => 'ទំព័រដើម';

  @override
  String get orders => 'ការបញ្ជាទិញ';

  @override
  String get cart => 'កន្ត្រកទំនិញ';

  @override
  String get profile => 'គណនី';

  @override
  String get newArrivals => 'ទំនិញថ្មីៗ';

  @override
  String get promotions => 'ប្រូម៉ូសិន';

  @override
  String get popularProducts => 'ផលិតផលពេញនិយម';

  @override
  String get seeAll => 'មើលទាំងអស់';

  @override
  String get productDetail => 'ព័ត៌មានលម្អិតផលិតផល';

  @override
  String get loading => 'កំពុងផ្ទុក...';

  @override
  String get productNotFound => 'រកមិនឃើញផលិតផលទេ។';

  @override
  String get size => 'ទំហំ';

  @override
  String get color => 'ពណ៌';

  @override
  String get quantity => 'បរិមាណ';

  @override
  String get description => 'ការពិពណ៌នា';

  @override
  String get relatedProducts => 'ផលិតផលពាក់ព័ន្ធ';

  @override
  String get loginToAdd => 'សូមចូលដើម្បីបន្ថែមទំនិញទៅកន្ត្រករបស់អ្នក។';

  @override
  String get addedToCart => 'បានបន្ថែមទៅកន្ត្រក!';

  @override
  String get failedToAdd => 'ការបន្ថែមទំនិញទៅកន្ត្រកបានបរាជ័យ។';

  @override
  String get myCart => 'កន្ត្រករបស់ខ្ញុំ';

  @override
  String get loginToViewCart => 'ចូលដើម្បីមើលទំនិញក្នុងកន្ត្រករបស់អ្នក។';

  @override
  String get loginOrRegister => 'ចូល / ចុះឈ្មោះ';

  @override
  String get cartIsEmpty => 'កន្ត្រកទំនិញរបស់អ្នកនៅទទេ។';

  @override
  String get cartIsEmptyMessage =>
      'ហាក់ដូចជាអ្នកមិនទាន់បានបន្ថែម\nទំនិញចូលក្នុងកន្ត្រករបស់អ្នកនៅឡើយទេ';

  @override
  String get proceedToCheckout => 'បន្តការទូទាត់';

  @override
  String get removeItem => 'លុបទំនិញ?';

  @override
  String get removeItemConfirm =>
      'តើអ្នកប្រាកដជាចង់លុបទំនិញនេះចេញពីកន្ត្រកមែនទេ?';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get remove => 'លុប';

  @override
  String get itemRemovedSuccess => 'បានលុបទំនិញដោយជោគជ័យ';

  @override
  String get itemRemovedFail => 'ការលុបទំនិញបរាជ័យ';

  @override
  String get failedToUpdateQty => 'Failed to update quantity';

  @override
  String get subtotal => 'សរុប';

  @override
  String get shipping => 'ថ្លៃដឹកជញ្ជូន';

  @override
  String get total => 'សរុប';

  @override
  String get myOrders => 'ការបញ្ជាទិញរបស់ខ្ញុំ';

  @override
  String get loginToViewOrders => 'ចូលដើម្បីមើលប្រវត្តិបញ្ជាទិញរបស់អ្នក។';

  @override
  String get youHaveNoOrders => 'អ្នកមិនទាន់មានការបញ្ជាទិញទេ។';

  @override
  String get cancelOrder => 'បោះបង់ការបញ្ជាទិញ';

  @override
  String get cancelOrderConfirm => 'តើអ្នកប្រាកដទេថាចង់បោះបង់ការបញ្ជាទិញនេះ?';

  @override
  String get no => 'ទេ';

  @override
  String get yesCancel => 'បាទ/ចាស បោះបង់';

  @override
  String get orderCancellationSuccess => 'ការបោះបង់ការបញ្ជាទិញបានជោគជ័យ';

  @override
  String get orderCancellationFail => 'ការបោះបង់ការបញ្ជាទិញបានបរាជ័យ';

  @override
  String orderNumber(Object transactionId) {
    return 'ការបញ្ជាទិញ #\$$transactionId';
  }

  @override
  String recipient(Object name) {
    return 'អ្នកទទួល: $name';
  }

  @override
  String phone(Object phone) {
    return 'ទូរស័ព្ទ';
  }

  @override
  String address(Object address) {
    return 'អាសយដ្ឋាន';
  }

  @override
  String date(Object date) {
    return 'កាលបរិច្ឆេទ: $date';
  }

  @override
  String get orderPlacedSuccess => 'ការបញ្ជាទិញបានជោគជ័យ!';

  @override
  String get thankYouPurchase => 'សូមអរគុណសម្រាប់ការទិញរបស់អ្នក។';

  @override
  String get continueShopping => 'បន្តការទិញទំនិញ';

  @override
  String get youAreNotLoggedIn => 'អ្នកមិនបានចូលទេ។';

  @override
  String get username => 'ឈ្មោះអ្នកប្រើប្រាស់';

  @override
  String get email => 'អ៊ីមែល';

  @override
  String get dateOfBirth => 'ថ្ងៃខែឆ្នាំកំណើត';

  @override
  String get appearance => 'រូបរាង';

  @override
  String get language => 'ភាសា';

  @override
  String get light => 'ពន្លឺ';

  @override
  String get system => 'ប្រព័ន្ធ';

  @override
  String get dark => 'ងងឹត';

  @override
  String get english => 'ភាសាអង់គ្លេស';

  @override
  String get dashboard => 'ផ្ទាំងគ្រប់គ្រង';

  @override
  String get logout => 'ចាកចេញ';

  @override
  String get administratorAccess => 'ការចូលប្រើរបស់អ្នកគ្រប់គ្រង';

  @override
  String get deliveryPrices => 'តម្លៃដឹកជញ្ជូន';

  @override
  String get sendNotification => 'ផ្ញើការជូនដំណឹងទៅអ្នកប្រើប្រាស់ទាំងអស់';

  @override
  String get users => 'អ្នកប្រើប្រាស់';

  @override
  String get categories => 'ប្រភេទ';

  @override
  String get attributes => 'គុណលក្ខណៈ';

  @override
  String get logos => 'ឡូហ្គោ';

  @override
  String get products => 'ផលិតផល';

  @override
  String get earnings => 'ចំណូល';

  @override
  String get pendingOrders => 'ការបញ្ជាទិញកំពុងរង់ចាំ';

  @override
  String get ordersInProgress => 'ការបញ្ជាទិញកំពុងដំណើរការ';
}
