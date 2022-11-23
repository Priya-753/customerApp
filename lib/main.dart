import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_customer_app/firebase_options.dart';
import 'package:flutter_customer_app/nas/model_view/auth_model_view.dart';
import 'package:flutter_customer_app/nas/model_view/google_drive_model_view.dart';
import 'package:flutter_customer_app/nas/model_view/misc_model_view.dart';
import 'package:flutter_customer_app/nas/model_view/reference_data_model_view.dart';
import 'package:flutter_customer_app/nas/model_view/transaction_model_view.dart';
import 'package:flutter_customer_app/nas/view/screens/accounts_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/admin_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/credit_discount_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/login_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/transactions_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/welocome_screen.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) {
    runApp(const NasCustomerApp());
  });
}

class NasCustomerApp extends StatefulWidget {
  static const Color darkGreen = Color(0xFF1E533A);
  static const Color darkBlue = Color(0xFF234060);
  static const Color darkBlueInvalid = Color(0xAA234060);
  static const Color sandal = Color(0xFFE8E4C6);
  static const Color red = Color(0xFFB00020);

  const NasCustomerApp({Key? key}) : super(key: key);

  @override
  State<NasCustomerApp> createState() => _NasCustomerAppState();
}

class _NasCustomerAppState extends State<NasCustomerApp>
    with TickerProviderStateMixin {
  final Future<FirebaseApp> _fbApp =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AuthModelView()),
          ChangeNotifierProvider.value(value: ReferenceDataModelView()),
          ChangeNotifierProvider.value(value: TransactionModelView()),
          ChangeNotifierProvider.value(value: DriveModelView()),
          ChangeNotifierProvider.value(value: MiscModelView()),
        ],
        child: FutureBuilder(
            future: _fbApp,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return snapshot.hasData
                  ? MaterialApp(
                      builder: (context, widget) => ResponsiveWrapper.builder(
                            ClampingScrollWrapper.builder(context, widget!),
                        defaultScale: true,
                        minWidth: 480,
                        backgroundColor: NasCustomerApp.sandal,
                        defaultName: MOBILE,
                            breakpoints: const [
                              ResponsiveBreakpoint.autoScaleDown(350, name: MOBILE),
                              ResponsiveBreakpoint.resize(450, name: MOBILE),
                              ResponsiveBreakpoint.autoScale(540, name: MOBILE),
                              ResponsiveBreakpoint.autoScale(600, name: TABLET),
                              ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                              ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                              ResponsiveBreakpoint.autoScale(2460, name: "4K"),
                            ]
                          ),
                      initialRoute: WelcomeScreen.id,
                      routes: {
                        WelcomeScreen.id: (context) => const WelcomeScreen(),
                        LoginScreen.id: (context) => const LoginScreen(),
                        AdminScreen.id: (context) => const AdminScreen(),
                        AccountsScreen.id: (context) => const AccountsScreen(),
                        TransactionScreen.id: (context) =>
                            const TransactionScreen(),
                        CreditDiscountScreen.id: (context) =>
                            const CreditDiscountScreen()
                      },
                      theme: themeData)
                  : Container(
                      color: NasCustomerApp.sandal,
                      child: const Center(
                          child: CircularProgressIndicator(
                        color: NasCustomerApp.darkGreen,
                      )),
                    );
            }));
  }
}
