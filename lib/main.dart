import 'package:aws_quiz_app/models/daily_record.dart';
import 'package:aws_quiz_app/models/provider.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  final providers = await getCloudProviders();
  final records = await DailyRecord.readyDailyRecords();
  runApp(MyApp(providers: providers, records: records));
}

class UserState extends ChangeNotifier {
  String token = '';

  void setToken(String token) {
    this.token = token;
    // notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final List<CloudProvider> providers;
  final List<DailyRecord> records;

  MyApp({super.key, required this.providers, required this.records});

  // const MyApp({Key key}) : super(key: key);
  final UserState userState = UserState();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserState>(
      create: (context) => UserState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'aws_quiz_app_3',
        theme: ThemeData(
          primarySwatch: Colors.red,
          fontFamily: "NotoScansJP",
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            textTheme: ButtonTextTheme.primary,
          ),
        ),
        home: HomePage(providers: providers, records: records),
      ),
    );
  }
}
