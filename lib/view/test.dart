// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:linktobd/model/notifiation_services.dart';
// import 'package:linktobd/view/add_help_issue.dart';
// import 'package:linktobd/view/browse_people.dart';
// import 'package:linktobd/view/create_post.dart';
// import 'package:linktobd/view/help_desk.dart';
// import 'package:linktobd/view/home.dart';
// import 'package:linktobd/view/login.dart';
// import 'package:linktobd/view/messages.dart';
// import 'package:linktobd/view/notifications.dart';
// import 'package:linktobd/view/profile_check.dart';
// import 'package:linktobd/view/register.dart';
// import 'package:linktobd/view/sign_up.dart';
// import 'package:flutter/material.dart';
// import 'package:linktobd/view/init_router.dart';
// import 'package:linktobd/view/platforms.dart';
// import 'package:linktobd/view/my_platforms.dart';
// import 'package:linktobd/view/my_profile.dart';
// import 'package:linktobd/view/platform_home.dart';
// import 'package:linktobd/view/feed.dart';
// import 'package:linktobd/view/create_password.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:linktobd/view/single_issue.dart';
// import 'firebase_options.dart';
// import 'package:timezone/data/latest.dart' as tzdata;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// // Define a global RouteObserver
// final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
//
// const primaryColor = Color(0xFFB533F1);
// const secondaryColor = Color(0xFF24CF81);
//
// @pragma('vm:entry-point')
// Future _firebaseBackgroundMessage(RemoteMessage message) async {
//   if(message.notification != null){
//     // print('notification received ${message.notification!.body}');
//   }
// }
//
// Future<void> setupLocalTimezone() async {
//   final String timezoneName = await FlutterNativeTimezone.getLocalTimezone();
//   tz.setLocalLocation(tz.getLocation(timezoneName));
//   print("Local timezone is set to: $timezoneName");
// }
//
// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   NotificationServices notificationServices = NotificationServices();
//   notificationServices.requestNotificationPermission();
//   FirebaseMessaging.onBackgroundMessage((message) => _firebaseBackgroundMessage(message));
//   tzdata.initializeTimeZones();
//   await setupLocalTimezone();
//   return runApp(MaterialApp(
//     navigatorObservers: [routeObserver],
//     navigatorKey: navigatorKey,
//     theme: lightTheme,
//     darkTheme: darkTheme,
//     themeMode: ThemeMode.system,
//     supportedLocales: supportedLocales,
//     localizationsDelegates: const [
//       CountryLocalizations.delegate,
//       GlobalMaterialLocalizations.delegate,
//       GlobalWidgetsLocalizations.delegate,
//     ],
//     routes: {
//       '/' : (context) => InitRouter(),
//       '/home' : (context) => Home(),
//       '/login' : (context) => Login(),
//       '/old_sign_up' : (context) => SignUp(),
//       '/platforms' : (context) => Platforms(),
//       '/my_platforms' : (context) => MyPlatforms(),
//       '/platform_home' : (context) => PlatformHome(),
//       '/feed' : (context) => Feed(),
//       '/messages' : (context) => Messages(),
//       '/my_profile' : (context) => MyProfile(),
//       '/create_password' : (context) => CreatePassword(),
//       '/create_post' : (context) => CreatePost(),
//       '/browse_people' : (context) => BrowsePeople(keyIndex: 0),
//       '/notifications' : (context) => Notifications(),
//       '/sign_up' : (context) => RegisterPage(),
//       '/profile_check' : (context) => ProfileCheck(),
//       '/help_desk' : (context) => HelpDesk(),
//       '/add_help_issue' : (context) => AddHelpIssue(),
//       '/single_issue' : (context) => SingleIssue()
//     },
//   ));
// }
//
//
//
//
// final lightTheme = ThemeData(
//   brightness: Brightness.light,
//   primaryColor: primaryColor,
//   colorScheme: ColorScheme.light(
//     primary: primaryColor,
//     secondary: secondaryColor,
//   ),
//   scaffoldBackgroundColor: Colors.white,
//   appBarTheme: AppBarTheme(
//     elevation: 0.0,
//     centerTitle: false,
//   ),
//   textTheme: TextTheme(
//     titleLarge: TextStyle(
//       fontSize: 16.0, // Adjust the size as needed
//       fontWeight: FontWeight.w500,
//     ),
//   ),
//   // Other theming data for light theme goes here
// );
//
// final darkTheme = ThemeData(
//   brightness: Brightness.dark,
//   primaryColor: primaryColor,
//   colorScheme: ColorScheme.dark(
//     primary: primaryColor,
//     secondary: secondaryColor,
//   ),
//   scaffoldBackgroundColor: Colors.black,
//   appBarTheme: AppBarTheme(
//     elevation: 0.0,
//     centerTitle: false,
//   ),
//   textTheme: TextTheme(
//     titleLarge: TextStyle(
//       fontSize: 16.0, // Adjust the size as needed
//       fontWeight: FontWeight.w500,
//     ),
//   ),
//   // Other theming data for dark theme goes here
// );
//
//
// final supportedLocales = const [
//   Locale("af"),
//   Locale("am"),
//   Locale("ar"),
//   Locale("az"),
//   Locale("be"),
//   Locale("bg"),
//   Locale("bn"),
//   Locale("bs"),
//   Locale("ca"),
//   Locale("cs"),
//   Locale("da"),
//   Locale("de"),
//   Locale("el"),
//   Locale("en"),
//   Locale("es"),
//   Locale("et"),
//   Locale("fa"),
//   Locale("fi"),
//   Locale("fr"),
//   Locale("gl"),
//   Locale("ha"),
//   Locale("he"),
//   Locale("hi"),
//   Locale("hr"),
//   Locale("hu"),
//   Locale("hy"),
//   Locale("id"),
//   Locale("is"),
//   Locale("it"),
//   Locale("ja"),
//   Locale("ka"),
//   Locale("kk"),
//   Locale("km"),
//   Locale("ko"),
//   Locale("ku"),
//   Locale("ky"),
//   Locale("lt"),
//   Locale("lv"),
//   Locale("mk"),
//   Locale("ml"),
//   Locale("mn"),
//   Locale("ms"),
//   Locale("nb"),
//   Locale("nl"),
//   Locale("nn"),
//   Locale("no"),
//   Locale("pl"),
//   Locale("ps"),
//   Locale("pt"),
//   Locale("ro"),
//   Locale("ru"),
//   Locale("sd"),
//   Locale("sk"),
//   Locale("sl"),
//   Locale("so"),
//   Locale("sq"),
//   Locale("sr"),
//   Locale("sv"),
//   Locale("ta"),
//   Locale("tg"),
//   Locale("th"),
//   Locale("tk"),
//   Locale("tr"),
//   Locale("tt"),
//   Locale("uk"),
//   Locale("ug"),
//   Locale("ur"),
//   Locale("uz"),
//   Locale("vi"),
//   Locale("zh")
// ];
























// ...................;

//import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DbManager {
//   static Database? _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await initDB();
//     return _database!;
//   }
//
//   Future<Database> initDB() async {
//     String path = join(await getDatabasesPath(), 'app_database.db');
//     Database db = await openDatabase(path, version: 1, onCreate: _createTables);
//     return db;
//   }
//
//
//   void _createTables(Database db, int version) async {
//     // This method should handle creating initial tables if needed
//   }
//
//   Future<void> ensureTableExists(DbTable table) async {
//     // print(table.columnsSql);
//     final db = await database;
//     var tableExists = Sqflite.firstIntValue(await db.rawQuery(
//         'SELECT COUNT(*) FROM sqlite_master WHERE type = ? AND name = ?',
//         ['table', table.tableName]
//     )) ?? 0;
//
//     if (tableExists == 0) {
//       await db.execute('CREATE TABLE ${table.tableName} (${table.columnsSql})');
//     }
//   }
//
//   Future<void> sync(DbTable table, {String whereMatch = 'uuid'}) async {
//     final db = await database;
//     if (table.rows == null) return;
//
//     for (var row in table.rows!) {
//       // Checking if row exists by UUID
//       var existingRows = await db.query(
//           table.tableName,
//           where: '$whereMatch = ?',
//           whereArgs: [row['$whereMatch']]
//       );
//
//       if (row.containsKey('remove') && row['remove'] == 1) {
//         // Delete the row if 'remove' flag is set and row exists
//         if (existingRows.isNotEmpty) {
//           await db.delete(table.tableName, where: 'uuid = ?', whereArgs: [row['uuid']]);
//         }
//       } else {
//         if (existingRows.isNotEmpty) {
//           // Update the row if it exists
//           await db.update(
//               table.tableName,
//               row,
//               where: '$whereMatch = ?',
//               whereArgs: [row['$whereMatch']]
//           );
//         } else {
//           // Insert the new row if it does not exist
//           await db.insert(table.tableName, row, conflictAlgorithm: ConflictAlgorithm.replace);
//         }
//       }
//     }
//   }
//
//
//   Future<List<Map<String, dynamic>>> getData(String tableName, String orderByColumn, {String? where, List<dynamic>? whereArgs}) async {
//     final db = await database;
//     return await db.query(
//         tableName,
//         where: where,
//         whereArgs: whereArgs,
//         orderBy: '$orderByColumn DESC',
//         limit: 100
//     );
//   }
//   // Future<List<Map<String, dynamic>>> getData(String tableName, String orderByColumn) async {
//   //   final db = await database;
//   //   return await db.query(
//   //       tableName,
//   //       orderBy: '$orderByColumn DESC',
//   //       limit: 100
//   //   );
//   // }
//
//   Future<void> dropTable(String tableName) async {
//     final db = await database;
//     await db.execute('DROP TABLE IF EXISTS $tableName');
//   }
//
//   Future<void> clearTable(String tableName) async {
//     final db = await database;
//     await db.delete(tableName);
//   }
//
//   Future<void> insertRows(DbTable table) async {
//     final db = await database;
//     for (var row in table.rows ?? []) {
//       await db.insert(table.tableName, row, conflictAlgorithm: ConflictAlgorithm.replace);
//     }
//   }
//
//   Future<void> updateRows(String tableName, Map<String, dynamic> values, String where, List<dynamic> whereArgs) async {
//     final db = await database;
//     await db.update(tableName, values, where: where, whereArgs: whereArgs);
//   }
//
//   Future<void> deleteRows(String tableName, String where, List<dynamic> whereArgs) async {
//     final db = await database;
//     await db.delete(tableName, where: where, whereArgs: whereArgs);
//   }
// }
//
// class DbTable {
//   final String tableName;
//   final List<String> columns;
//   final List<Map<String, dynamic>>? rows;
//
//   DbTable({required this.tableName, required this.columns, this.rows});
//
//   String get columnsSql => columns.map((column) {
//     if (column == 'id') {
//       return '$column INTEGER PRIMARY KEY AUTOINCREMENT';
//     } else {
//       return '$column TEXT';
//     }
//   }).join(', ');
// }
