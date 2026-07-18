/// ڈیٹا بیس ٹیبل کے نام اور شیئرڈ پریفرنس کیز
class AppConstants {
  AppConstants._();

  // Database
  static const String dbName = 'ghar_ka_hisab.db';
  static const int dbVersion = 1;

  static const String tableMilkRecords = 'milk_records';
  static const String tableCustomers = 'customers';
  static const String tableMilkPayments = 'milk_payments';
  static const String tableIncome = 'income';
  static const String tableExpense = 'expense';
  static const String tableBills = 'bills';
  static const String tableBorrowLend = 'borrow_lend';
  static const String tableBorrowLendPayments = 'borrow_lend_payments';
  static const String tableRent = 'rent';
  static const String tableRentPayments = 'rent_payments';
  static const String tableSettings = 'app_settings';

  // Shared preferences keys
  static const String prefDarkMode = 'pref_dark_mode';
  static const String prefPin = 'pref_pin';
  static const String prefPinEnabled = 'pref_pin_enabled';
  static const String prefFingerprintEnabled = 'pref_fingerprint_enabled';
  static const String prefMilkPrice = 'pref_milk_price';
  static const String prefCurrency = 'pref_currency';
  static const String prefFirstRun = 'pref_first_run';

  // Borrow/Lend types
  static const String typeGiven = 'given'; // میں نے دیا (وصولی باقی)
  static const String typeReceived = 'received'; // میں نے لیا (ادائیگی باقی)

  // Bill status
  static const String statusPaid = 'paid';
  static const String statusPending = 'pending';

  // Notification IDs base
  static const int billNotificationIdBase = 1000;
  static const int rentNotificationId = 9000;
}
