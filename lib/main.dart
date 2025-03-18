import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:linktobd/model/notifiation_services.dart';
import 'package:linktobd/view/add_help_issue.dart';
import 'package:linktobd/view/browse_people.dart';
import 'package:linktobd/view/create_post.dart';
import 'package:linktobd/view/help_desk.dart';
import 'package:linktobd/view/home.dart';
import 'package:linktobd/view/login.dart';
import 'package:linktobd/view/messages.dart';
import 'package:linktobd/view/notifications.dart';
import 'package:linktobd/view/profile_check.dart';
import 'package:linktobd/view/register.dart';
import 'package:linktobd/view/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:linktobd/view/init_router.dart';
import 'package:linktobd/view/platforms.dart';
import 'package:linktobd/view/my_platforms.dart';
import 'package:linktobd/view/my_profile.dart';
import 'package:linktobd/view/platform_home.dart';
import 'package:linktobd/view/feed.dart';
import 'package:linktobd/view/create_password.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:linktobd/view/single_issue.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
const primaryColor = Color(0xFFB533F1);
const secondaryColor = Color(0xFF24CF81);

@pragma('vm:entry-point')
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    // Handle background notification
  }
}

Future<void> setupLocalTimezone() async {
  tz.initializeTimeZones();
  final String timezoneName = tz.local.name;
  tz.setLocalLocation(tz.getLocation(timezoneName));
  print("Local timezone is set to: $timezoneName");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationServices notificationServices = NotificationServices();
  notificationServices.requestNotificationPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
  tz.initializeTimeZones();
  await setupLocalTimezone();
  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      print("App is in background (paused)");
    } else if (state == AppLifecycleState.resumed) {
      print("App is in foreground (resumed)");
    } else if (state == AppLifecycleState.detached) {
      print("App is detached");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      navigatorKey: navigatorKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routes: {
        '/': (context) => InitRouter(),
        '/home': (context) => Home(),
        '/login': (context) => Login(),
        '/old_sign_up': (context) => SignUp(),
        '/platforms': (context) => Platforms(),
        '/my_platforms': (context) => MyPlatforms(),
        '/platform_home': (context) => PlatformHome(),
        '/feed': (context) => Feed(),
        '/messages': (context) => Messages(),
        '/my_profile': (context) => MyProfile(),
        '/create_password': (context) => CreatePassword(),
        '/create_post': (context) => CreatePost(),
        '/browse_people': (context) => BrowsePeople(keyIndex: 0),
        '/notifications': (context) => Notifications(),
        '/sign_up': (context) => RegisterPage(),
        '/profile_check': (context) => ProfileCheck(),
        '/help_desk': (context) => HelpDesk(),
        '/single_issue': (context) => SingleIssue()
      },
    );
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    elevation: 0.0,
    centerTitle: false,
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 16.0, // Adjust the size as needed
      fontWeight: FontWeight.w500,
    ),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  colorScheme: ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    elevation: 0.0,
    centerTitle: false,
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 16.0, // Adjust the size as needed
      fontWeight: FontWeight.w500,
    ),
  ),
);

final supportedLocales = const [
  Locale("af"),
  Locale("am"),
  Locale("ar"),
  Locale("az"),
  Locale("be"),
  Locale("bg"),
  Locale("bn"),
  Locale("bs"),
  Locale("ca"),
  Locale("cs"),
  Locale("da"),
  Locale("de"),
  Locale("el"),
  Locale("en"),
  Locale("es"),
  Locale("et"),
  Locale("fa"),
  Locale("fi"),
  Locale("fr"),
  Locale("gl"),
  Locale("ha"),
  Locale("he"),
  Locale("hi"),
  Locale("hr"),
  Locale("hu"),
  Locale("hy"),
  Locale("id"),
  Locale("is"),
  Locale("it"),
  Locale("ja"),
  Locale("ka"),
  Locale("kk"),
  Locale("km"),
  Locale("ko"),
  Locale("ku"),
  Locale("ky"),
  Locale("lt"),
  Locale("lv"),
  Locale("mk"),
  Locale("ml"),
  Locale("mn"),
  Locale("ms"),
  Locale("nb"),
  Locale("nl"),
  Locale("nn"),
  Locale("no"),
  Locale("pl"),
  Locale("ps"),
  Locale("pt"),
  Locale("ro"),
  Locale("ru"),
  Locale("sd"),
  Locale("sk"),
  Locale("sl"),
  Locale("so"),
  Locale("sq"),
  Locale("sr"),
  Locale("sv"),
  Locale("ta"),
  Locale("tg"),
  Locale("th"),
  Locale("tk"),
  Locale("tr"),
  Locale("tt"),
  Locale("uk"),
  Locale("ug"),
  Locale("ur"),
  Locale("uz"),
  Locale("vi"),
  Locale("zh"),
];
