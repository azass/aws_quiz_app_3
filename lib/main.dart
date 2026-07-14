import 'package:aws_quiz_app/models/daily_record.dart';
import 'package:aws_quiz_app/models/provider.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

List<CloudProvider> providers;
List<DailyRecord> records;

Future<void> main() async {
  providers = await getCloudProviders();
  records = await DailyRecord.readyDailyRecords();
  runApp(MyApp());
}

class UserState extends ChangeNotifier {
  String token;

  void setToken(String token) {
    this.token = token;
    // notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  // const MyApp({Key key}) : super(key: key);
  final UserState userState = UserState();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserState>(
        create: (context) => UserState(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cloud Quiz',
          theme: ThemeData(
              primarySwatch: Colors.red,
              fontFamily: "NotoScansJP",
              buttonTheme: ButtonThemeData(
                  buttonColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  textTheme: ButtonTextTheme.primary)),
          home: HomePage(
            providers: providers,
            records: records,
          ),
        ));
  }
}
