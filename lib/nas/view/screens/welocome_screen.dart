import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:flutter_customer_app/nas/model/auth_token.dart';
import 'package:flutter_customer_app/nas/model_view/misc_model_view.dart';
import 'package:flutter_customer_app/nas/model_view/reference_data_model_view.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';
import 'package:flutter_customer_app/nas/utilities/date_utils.dart';
import 'package:flutter_customer_app/nas/utilities/exception.dart';
import 'package:flutter_customer_app/nas/utilities/sqlite.dart';
import 'package:flutter_customer_app/nas/view/screens/accounts_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/login_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/sign_up_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/transactions_screen.dart';
import 'package:flutter_customer_app/nas/view/widgets/dialogs/failure_dialog.dart';
import 'package:flutter_customer_app/nas/view/widgets/dialogs/update_app_dialog.dart';
import 'package:jiffy/jiffy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:responsive_framework/responsive_framework.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoginRequired = true;
  bool _showLoginAndSignUp = false;
  late String _platformVersion;
  late FirebaseMessaging _messaging;
  bool _updateRequired = true;
  bool _updateOptional = true;
  bool _isVersionCheckComplete = false;

  @override
  void initState() {
    super.initState();
    getAppVersions();
  }

  Future<void> getAppVersions() async {
    await Provider.of<MiscModelView>(context, listen: false)
        .getVersionFromServer();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    setState(() {
      _platformVersion = version;
    });

    ApiResponse versionsResponse =
        Provider.of<MiscModelView>(context, listen: false).response;

    if (versionsResponse.status == Status.completed) {
      dynamic versions = versionsResponse.data;
      if (_platformVersion.compareTo(versions['app_version']) >= 0) {
        setState(() {
          _updateRequired = false;
          _updateOptional = false;
          _isVersionCheckComplete = true;
        });
      } else if (_platformVersion.compareTo(versions['app_version']) < 0 &&
          _platformVersion.compareTo(versions['min_version']) >= 0) {
        setState(() {
          _updateRequired = false;
          _updateOptional = true;
          _isVersionCheckComplete = true;
        });
      } else if (_platformVersion.compareTo(versions['app_version']) < 0 &&
          _platformVersion.compareTo(versions['min_version']) < 0) {
        setState(() {
          _updateRequired = true;
          _updateOptional = false;
          _isVersionCheckComplete = true;
        });
      }
    }

    await isLoginRequired();
  }

  Future<void> isLoginRequired() async {
    bool isLoginRequired = true;
    try {
      await SQLite.openDb();

      List authTokenJson = await SQLite.get(SQLite.database, authTokenTableName, 'id', 1);
      AuthToken authToken = AuthToken.fromJson(authTokenJson[0]);
      Jiffy fromDate = DateUtilities.getJiffyFromDateTime(DateTime.now());
      Jiffy toDate = DateUtilities.getJiffyFromMillis(authToken.createdTime);

      if (DateUtilities.difference(fromDate, toDate, Units.MONTH) > 6) {
        isLoginRequired = true;
      } else {
        isLoginRequired = false;
      }
    } on NoSuchDataException {
      isLoginRequired = true;
    } on MissingPluginException {
      isLoginRequired = true;
    } on Exception {
      isLoginRequired = true;
    }

    if (!isLoginRequired) {
      await fetchAllReferenceData();
      await setUpFirebase();
    }

    setState(() {
      _isLoginRequired = isLoginRequired;
      _showLoginAndSignUp = isLoginRequired;
    });

    log.info("Is Login Required? " + isLoginRequired.toString());
  }

  Future<void> fetchAllReferenceData() async {
    await Provider.of<ReferenceDataModelView>(context, listen: false)
        .fetchCustomer();
    await Provider.of<ReferenceDataModelView>(context, listen: false)
        .fetchLocations();
    await Provider.of<ReferenceDataModelView>(context, listen: false)
        .fetchCompanies();
  }

  Future<void> setUpFirebase() async {
    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await Provider.of<MiscModelView>(context, listen: false)
          .updateFirebaseToken(newToken);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        log.info("INITIAL MESSAGE");
        if (message.data['Firebase Message Type'] == '4') {
          Navigator.of(context).pushNamed(TransactionScreen.id);
        }
      }
    });

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log.info('User granted permission');

      var androiInit =
          const AndroidInitializationSettings('@mipmap/ic_launcher'); //for logo
      var iosInit = const IOSInitializationSettings();
      var initSetting =
          InitializationSettings(android: androiInit, iOS: iosInit);
      var androidDetails = const AndroidNotificationDetails('1', 'channelName');
      var iosDetails = const IOSNotificationDetails();
      var generalNotificationDetails =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      FlutterLocalNotificationsPlugin fltNotification =
          FlutterLocalNotificationsPlugin();
      fltNotification.initialize(initSetting,
          onSelectNotification: (String? payload) async {
        log.info("PAYLOAD...");
        log.info(payload);
        if (payload == '4') {
          Navigator.of(context).pushNamed(TransactionScreen.id);
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log.info('Firebase message data: ${message.data}');

        if (message.notification != null) {
          log.info(
              'Firebase message also a notification: ${message.notification}');

          RemoteNotification? notification = message.notification;
          AndroidNotification? android = message.notification?.android;
          if (notification != null && android != null) {
            fltNotification.show(notification.hashCode, notification.title,
                notification.body, generalNotificationDetails,
                payload: message.data['Firebase Message Type']);
          }
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log.info("BACKGROUND MESSAGE CLICKED");
        if (message.data['Firebase Message Type'] == '4') {
          Navigator.of(context).pushNamed(TransactionScreen.id);
        }
      });
    } else {
      log.info('User declined or has not accepted permission');
    }
  }

  tile(
      {Color? color,
      String? imagePath,
      double scale = 1.0,
      Alignment alignment = Alignment.bottomCenter}) {
    if (imagePath != null) {
      return Container(
        height: MediaQuery.of(context).size.height / 14,
        width: MediaQuery.of(context).size.width / 7,
        decoration: BoxDecoration(
          color: color,
          image: DecorationImage(
            image: AssetImage(imagePath),
            scale: scale,
            alignment: alignment,
          ),
        ),
      );
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 14,
        width: MediaQuery.of(context).size.width / 7,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ApiResponse apiResponse =
        Provider
            .of<ReferenceDataModelView>(context, listen: false)
            .response;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isVersionCheckComplete && (_updateRequired || _updateOptional)) {
        showDialog<String>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) =>
                UpdateDialog(
                    dialogTitle: const Text("Update!"),
                    dialogDescription: const Text(
                        "Please update the app to enjoy all the features"),
                    updateOptional: _updateOptional,
                    isLoginRequired: _isLoginRequired));
      } else if (!_isLoginRequired) {
        switch (apiResponse.status) {
          case Status.initial:
          case Status.loading:
            break;
          case Status.completed:
            Navigator.pop(context);
            Navigator.pushNamed(context, AccountsScreen.id);
            break;
          case Status.error:
            showDialog<String>(
                context: context,
                builder: (BuildContext context) =>
                    FailureDialog(
                        dialogTitle: Text(apiResponse.message!),
                        dialogDescription: Text(
                            apiResponse.message.toString())));
            break;
        }
      }
    });

    Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  tile(),
                  tile(),
                  tile(
                      color: primaryColor,
                      imagePath: 'assets/images/carrot.png',
                      scale: 15,
                      alignment: const Alignment(-0.6, 1)),
                  tile(),
                  tile(
                      color: primaryColor,
                      imagePath: 'assets/images/circle1.png',
                      alignment: const Alignment(-1, -1)),
                  tile(),
                  tile(
                      color: primaryColor,
                      imagePath: 'assets/images/circle2.png',
                      alignment: const Alignment(2, -1)),
                ],
              ),
              Row(
                children: [
                  tile(),
                  tile(),
                  tile(),
                  tile(
                      color: primaryColor,
                      imagePath: 'assets/images/tractor.png',
                      scale: 10),
                  tile(),
                  tile(
                      color: primaryColor,
                      imagePath: 'assets/images/triangle.png'),
                  tile(),
                ],
              ),
              Row(
                children: [
                  tile(),
                  tile(),
                  tile(),
                  tile(),
                  tile(
                      color: primaryColor,
                      imagePath: 'assets/images/spade.png',
                      scale: 10,
                      alignment: const Alignment(0, 0)),
                  tile(),
                  tile(
                      color: primaryColor,
                      imagePath: 'assets/images/circle3.png',
                      scale: 0.5,
                      alignment: const Alignment(-1, -1)),
                ],
              ),
              Row(
                children: [
                  tile(),
                  tile(),
                  tile(),
                  tile(),
                  tile(),
                  tile(
                      color: primaryColor,
                      imagePath: 'assets/images/farmer.png',
                      scale: 0.1),
                  tile(),
                ],
              ),
              Row(
                children: [
                  tile(),
                  tile(),
                  tile(),
                  tile(),
                  tile(),
                  tile(),
                  tile(
                      color: primaryColor,
                      imagePath: 'assets/images/water_can.png',
                      scale: 0.25),
                ],
              ),
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 200.0,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text('National Agro Services',
                          style: ResponsiveValue(
                            context,
                            defaultValue: Theme.of(context).textTheme.headline4,
                            valueWhen: [
                              Condition.smallerThan(
                                name: TABLET,
                                value: Theme.of(context).textTheme.headline3,
                              )
                            ],
                          ).value,
                          textAlign: TextAlign.start),
                      ResponsiveRowColumn(
                        rowMainAxisAlignment: MainAxisAlignment.center,
                        columnPadding: const EdgeInsets.all(10),
                        layout: ResponsiveWrapper.of(context).screenWidth < ResponsiveWrapper.of(context).screenHeight
                            ? ResponsiveRowColumnType.COLUMN
                            : ResponsiveRowColumnType.ROW,
                        children: [
                      _showLoginAndSignUp
                          ? ResponsiveRowColumnItem(child: Padding(
                            padding: const EdgeInsets.fromLTRB(0,0,5.0,5.0),
                            child: TextButton(
                              child: Text('Sign Up',
                                  style: ResponsiveValue(
                                    context,
                                    defaultValue: Theme.of(context).textTheme.bodyText1,
                                    valueWhen: [
                                      Condition.smallerThan(
                                        name: TABLET,
                                        value: Theme.of(context).textTheme.bodyText2,
                                      )
                                    ],
                                  ).value),
                              onPressed: () {
                                showModalBottomSheet(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                                    ),
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => Padding(
                                      padding: MediaQuery.of(context)
                                          .viewInsets,
                                      child: const SignUpScreen(),
                                    ));
                              },
                            ),
                          )) : const ResponsiveRowColumnItem(child: SizedBox(
                        height: 5.0,
                      )),
                          _showLoginAndSignUp
                              ? ResponsiveRowColumnItem(child: TextButton(
                            child: Text('Log In',
                                style: ResponsiveValue(
                                  context,
                                  defaultValue: Theme.of(context).textTheme.bodyText1,
                                  valueWhen: [
                                    Condition.smallerThan(
                                      name: TABLET,
                                      value: Theme.of(context).textTheme.bodyText2,
                                    )
                                  ],
                                ).value),
                            onPressed: () {
                              showModalBottomSheet(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                                  ),
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => Padding(
                                    padding: MediaQuery.of(context)
                                        .viewInsets,
                                    child: const LoginScreen(),
                                  ));
                            },
                          )) : const ResponsiveRowColumnItem(child: SizedBox(
                            height: 5.0,
                          ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
