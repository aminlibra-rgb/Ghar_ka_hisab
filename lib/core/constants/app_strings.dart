/// ایپ میں استعمال ہونے والے تمام اردو الفاظ ایک جگہ
/// تاکہ آئندہ ترجمہ یا تبدیلی آسان ہو۔
class AppStrings {
  AppStrings._();

  static const String appName = 'گھر کا حساب';

  // Dashboard
  static const String dashboard = 'ڈیش بورڈ';
  static const String currentBalance = 'موجودہ بیلنس';
  static const String monthlyIncome = 'ماہانہ آمدنی';
  static const String monthlyExpense = 'ماہانہ اخراجات';
  static const String monthlyMilkBill = 'ماہانہ دودھ بل';
  static const String pendingBills = 'واجب الادا بل';
  static const String pendingReceivables = 'وصولی باقی';
  static const String pendingPayables = 'ادائیگی باقی';
  static const String shopRentStatus = 'دکان کرایہ کی صورتحال';
  static const String quickActions = 'فوری اعمال';
  static const String overview = 'مجموعی جائزہ';

  // Navigation / Modules
  static const String milk = 'دودھ کا حساب';
  static const String income = 'آمدنی';
  static const String expense = 'اخراجات';
  static const String bills = 'بل';
  static const String borrowLend = 'ادھار لین دین';
  static const String shopRent = 'دکان کرایہ';
  static const String reports = 'رپورٹس';
  static const String search = 'تلاش';
  static const String backup = 'بیک اپ';
  static const String settings = 'ترتیبات';

  // Common actions
  static const String add = 'شامل کریں';
  static const String edit = 'ترمیم کریں';
  static const String delete = 'حذف کریں';
  static const String save = 'محفوظ کریں';
  static const String cancel = 'منسوخ کریں';
  static const String update = 'اپڈیٹ کریں';
  static const String confirm = 'تصدیق کریں';
  static const String close = 'بند کریں';
  static const String exportPdf = 'PDF بنائیں';
  static const String noData = 'کوئی ریکارڈ موجود نہیں';
  static const String deleteConfirmTitle = 'کیا آپ واقعی حذف کرنا چاہتے ہیں؟';
  static const String deleteConfirmBody = 'یہ عمل واپس نہیں ہو سکتا۔';
  static const String savedSuccessfully = 'کامیابی سے محفوظ ہو گیا';
  static const String deletedSuccessfully = 'کامیابی سے حذف ہو گیا';
  static const String pleaseEnterValidAmount = 'براہ کرم درست رقم درج کریں';
  static const String pleaseEnterTitle = 'براہ کرم عنوان درج کریں';
  static const String pleaseSelectDate = 'براہ کرم تاریخ منتخب کریں';

  // Milk module
  static const String milkPricePerLiter = 'دودھ کی قیمت فی لیٹر';
  static const String customers = 'گاہک';
  static const String addCustomer = 'نیا گاہک شامل کریں';
  static const String customerName = 'گاہک کا نام';
  static const String quantityLiters = 'مقدار (لیٹر)';
  static const String dailyTotal = 'یومیہ کل';
  static const String monthlyBill = 'ماہانہ بل';
  static const String recordPayment = 'ادائیگی درج کریں';
  static const String remainingBalance = 'باقی رقم';
  static const String monthlyStatement = 'ماہانہ گوشوارہ';
  static const String searchByMonth = 'مہینہ کے مطابق تلاش کریں';

  // Income
  static const String title = 'عنوان';
  static const String amount = 'رقم';
  static const String category = 'قسم';
  static const String date = 'تاریخ';
  static const String notes = 'تفصیل';
  static const String incomeCategorySalary = 'تنخواہ';
  static const String incomeCategoryBusiness = 'کاروبار';
  static const String incomeCategoryRent = 'کرایہ';
  static const String incomeCategoryOther = 'دیگر';

  // Expense categories
  static const String expenseCategoryGrocery = 'گروسری';
  static const String expenseCategoryElectricity = 'بجلی';
  static const String expenseCategoryGas = 'گیس';
  static const String expenseCategoryWater = 'پانی';
  static const String expenseCategoryInternet = 'انٹرنیٹ';
  static const String expenseCategoryFuel = 'پیٹرول';
  static const String expenseCategoryMedical = 'ادویات';
  static const String expenseCategoryShopping = 'خریداری';
  static const String expenseCategoryEducation = 'تعلیم';
  static const String expenseCategoryOther = 'دیگر';

  // Bills
  static const String billName = 'بل کا نام';
  static const String totalAmount = 'کل رقم';
  static const String paidAmount = 'ادا شدہ رقم';
  static const String remainingAmount = 'باقی رقم';
  static const String dueDate = 'آخری تاریخ';
  static const String paymentDate = 'ادائیگی کی تاریخ';
  static const String status = 'حالت';
  static const String statusPaid = 'ادا شدہ';
  static const String statusPending = 'باقی';
  static const String billTypeElectricity = 'بجلی';
  static const String billTypeGas = 'گیس';
  static const String billTypeWater = 'پانی';
  static const String billTypeInternet = 'انٹرنیٹ';
  static const String billTypeMobile = 'موبائل';
  static const String billTypeOther = 'دیگر';

  // Borrow / Lend
  static const String moneyGiven = 'دی گئی رقم (قرض)';
  static const String moneyReceived = 'لی گئی رقم (قرض)';
  static const String personName = 'شخص کا نام';
  static const String phoneNumber = 'فون نمبر';
  static const String partialPayment = 'جزوی ادائیگی';
  static const String history = 'مکمل تاریخچہ';

  // Rent
  static const String monthlyRent = 'ماہانہ کرایہ';
  static const String paymentHistory = 'ادائیگی کی تاریخ';

  // Reports
  static const String dailyReport = 'یومیہ رپورٹ';
  static const String weeklyReport = 'ہفتہ وار رپورٹ';
  static const String monthlyReport = 'ماہانہ رپورٹ';
  static const String yearlyReport = 'سالانہ رپورٹ';

  // Settings
  static const String darkMode = 'ڈارک موڈ';
  static const String currency = 'کرنسی';
  static const String pinLock = 'پن لاک';
  static const String fingerprintAuth = 'فنگر پرنٹ تصدیق';
  static const String changePin = 'پن تبدیل کریں';
  static const String backupDatabase = 'ڈیٹا بیس بیک اپ کریں';
  static const String restoreDatabase = 'ڈیٹا بیس بحال کریں';
  static const String about = 'ایپ کے بارے میں';

  // Currency
  static const String currencySymbol = 'روپے';
  static const String rs = 'Rs';
}
