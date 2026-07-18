# گھر کا حساب (Ghar Ka Hisab)

مکمل آفلائن گھریلو اکاؤنٹنگ Flutter ایپلی کیشن — اردو (RTL) انٹرفیس، Material Design 3۔

## فیچرز
- مرکزی ڈیش بورڈ: موجودہ بیلنس، ماہانہ آمدنی/اخراجات/دودھ بل، واجب الادا بل، وصولی/ادائیگی باقی، دکان کرایہ کی صورتحال
- دودھ کا مکمل حساب کتاب (گاہک، یومیہ ریکارڈ، ادائیگیاں، ماہانہ گوشوارہ، PDF ایکسپورٹ)
- آمدنی اور اخراجات ماڈیول (کیٹیگری، تفصیل، ماہانہ رپورٹ)
- بل مینیجر (بجلی، گیس، پانی، انٹرنیٹ، موبائل) بمعہ لوکل نوٹیفیکیشن یاد دہانی
- ادھار لین دین (دی گئی/لی گئی رقم، جزوی ادائیگیاں، مکمل تاریخچہ)
- دکان کرایہ ماڈیول
- یومیہ/ہفتہ وار/ماہانہ/سالانہ رپورٹس بمعہ چارٹس اور PDF ایکسپورٹ
- گلوبل سرچ (گاہک، بل، دودھ ریکارڈ، آمدنی، اخراجات، ادھار)
- ڈیٹا بیس بیک اپ/بحالی
- PIN لاک اور فنگر پرنٹ تصدیق
- ڈارک موڈ

## فولڈر اسٹرکچر
```
lib/
  core/
    constants/       # رنگ، اردو الفاظ، اور عمومی مستقل قدریں
    theme/            # Material 3 تھیم (لائٹ/ڈارک)
    utils/            # فارمیٹرز اور ویلیڈیٹرز
  data/
    database/         # SQLite (sqflite) ہیلپر - تمام ٹیبلز یہاں بنتے ہیں
    models/           # ڈیٹا ماڈلز (Milk, Income, Expense, Bill, ...)
    repositories/     # ہر ماڈیول کی CRUD ریپوزیٹری
  providers/          # Provider اسٹیٹ مینجمنٹ (ChangeNotifier)
  services/           # PDF، نوٹیفیکیشن، بیک اپ، آتھ، سیٹنگز سروسز
  screens/            # ہر ماڈیول کی اسکرینز (dashboard, milk, income, ...)
  widgets/            # دوبارہ استعمال ہونے والے کسٹم ویجٹس
  main.dart           # ایپ کا داخلی نقطہ
android/              # اینڈرائیڈ پلیٹ فارم کنفیگریشن
```

## چلانے کا طریقہ

1. **Flutter SDK انسٹال کریں** (stable channel، Flutter 3.22+ تجویز کردہ):
   https://docs.flutter.dev/get-started/install

2. **پراجیکٹ فولڈر میں جائیں اور پیکجز حاصل کریں:**
   ```bash
   cd ghar_ka_hisab
   flutter pub get
   ```

3. **iOS سپورٹ درکار ہو تو** (یہ پراجیکٹ صرف Android کے لیے تیار کیا گیا ہے):
   ```bash
   flutter create --platforms=ios .
   ```
   یہ موجودہ `lib/` کوڈ کو نہیں چھیڑے گا، صرف `ios/` فولڈر شامل کرے گا۔

4. **ایپ چلائیں:**
   ```bash
   flutter run
   ```

5. **ریلیز APK بنائیں:**
   ```bash
   flutter build apk --release
   ```

## اہم نوٹس

- **فونٹ:** ایپ `google_fonts` پیکج کے ذریعے "Noto Nastaliq Urdu" فونٹ استعمال کرتی ہے۔ پہلی بار چلانے پر انٹرنیٹ درکار ہو سکتا ہے (فونٹ ڈاؤن لوڈ کے لیے)۔ مکمل آفلائن استعمال کے لیے:
  1. فونٹ فائلیں [Google Fonts](https://fonts.google.com/noto/specimen/Noto+Nastaliq+Urdu) سے ڈاؤن لوڈ کریں۔
  2. `assets/fonts/` میں رکھیں۔
  3. `pubspec.yaml` میں `fonts:` سیکشن (کمنٹ آؤٹ موجود ہے) کو فعال کریں۔
  4. `core/theme/app_theme.dart` میں `GoogleFonts.notoNastaliqUrdu...` کو `TextStyle(fontFamily: 'NotoNastaliqUrdu')` سے بدل دیں۔

- **ایپ آئیکن:** `flutter_launcher_icons` پیکج شامل کر کے اپنا آئیکن سیٹ کریں، یا `android/app/src/main/res/mipmap-*/ic_launcher.png` میں اپنی تصاویر رکھیں۔

- **لوکل نوٹیفیکیشن:** Android 12+ پر exact alarms کی اجازت درکار ہو سکتی ہے؛ manifest میں `SCHEDULE_EXACT_ALARM` پہلے سے شامل ہے۔

- **ڈیٹا بیس:** SQLite (`sqflite`) استعمال ہوتا ہے، مکمل طور پر آفلائن، ڈیٹا `ApplicationDocumentsDirectory` میں محفوظ ہوتا ہے۔

- **آرکیٹیکچر:** Clean Architecture کے اصولوں پر مبنی — UI (screens/widgets) → State (providers) → Business Logic (repositories) → Data (database/models)۔ Provider پیکج کے ذریعے اسٹیٹ مینجمنٹ کی گئی ہے۔

## استعمال شدہ پیکجز
provider, sqflite, path_provider, fl_chart, intl, pdf, printing, local_auth,
flutter_local_notifications, shared_preferences, file_picker, google_fonts, fluttertoast
