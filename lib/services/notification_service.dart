import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../data/models/bill_model.dart';
import '../core/constants/app_constants.dart';

/// مقامی اطلاعات (Local Notifications) کی سروس
/// بلوں اور کرایہ کی آخری تاریخ سے پہلے یاد دہانی بھیجتی ہے۔
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // Android 13+ notification permission
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> scheduleBillReminder(BillModel bill) async {
    if (bill.id == null) return;
    await init();

    // آخری تاریخ سے ایک دن پہلے صبح 9 بجے یاد دہانی
    final reminderDate = bill.dueDate.subtract(const Duration(days: 1));
    final scheduledTime = DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 9, 0);

    if (scheduledTime.isBefore(DateTime.now())) return;

    final notificationId = AppConstants.billNotificationIdBase + bill.id!;

    await _plugin.zonedSchedule(
      notificationId,
      'بل کی یاد دہانی',
      '${bill.billName} کی ادائیگی کی آخری تاریخ کل ہے - رقم: Rs ${bill.remainingAmount.toStringAsFixed(0)}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bill_reminders',
          'بل کی یاد دہانیاں',
          channelDescription: 'بلوں کی آخری تاریخ سے پہلے اطلاع',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelBillReminder(int billId) async {
    await _plugin.cancel(AppConstants.billNotificationIdBase + billId);
  }

  Future<void> scheduleRentReminder(DateTime dueDate, double remainingAmount) async {
    await init();
    final reminderDate = dueDate.subtract(const Duration(days: 1));
    final scheduledTime = DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 9, 0);
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      AppConstants.rentNotificationId,
      'دکان کرایہ یاد دہانی',
      'دکان کے کرایہ کی ادائیگی کی آخری تاریخ کل ہے - باقی رقم: Rs ${remainingAmount.toStringAsFixed(0)}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rent_reminders',
          'کرایہ کی یاد دہانیاں',
          channelDescription: 'دکان کرایہ کی آخری تاریخ سے پہلے اطلاع',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showInstantNotification(String title, String body) async {
    await init();
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'عمومی اطلاعات',
          importance: Importance.defaultImportance,
        ),
      ),
    );
  }
}
