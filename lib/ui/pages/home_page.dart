import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:aws_quiz_app/models/daily_record.dart';
import 'package:aws_quiz_app/models/provider.dart';
import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/pages/daily_record_page.dart';
import 'package:aws_quiz_app/ui/pages/select_exam_page.dart';
import 'package:aws_quiz_app/ui/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class HomePage extends StatefulWidget {
  final List<CloudProvider> providers;
  final List<DailyRecord> records;
  HomePage({Key? key, required this.providers, required this.records})
    : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<DailyRecord> _selectedDate = [];
  final _weekdays = ["MON", "TUE", "WED", "THU", "FRY", "SAT", "SUN"];
  List<DailyRecord> records = [];
  String _today = "";
  @override
  initState() {
    super.initState();
    initializeDateFormatting('ja');
    var formater = new DateFormat('yyyy-MM-dd', "ja_JP");
    final DateTime _now = DateTime.now();
    _today = formater.format(_now);
    records = widget.records;
  }

  @override
  Widget build(BuildContext context) {
    // final UserState userState = Provider.of<UserState>(context);
    // userState.setToken("token");
    return Scaffold(
      appBar: AppBar(title: Text('Certified Quiz'), elevation: 0),
      body: new RefreshIndicator(
        onRefresh: _onRefresh,
        child: Stack(
          children: <Widget>[
            ClipPath(
              clipper: WaveClipperTwo(),
              child: Container(
                decoration: BoxDecoration(
                  color: BACK_COLOR,
                ),
                height: 260,
              ),
            ),
            CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: _buildProviderSliverGrid(context),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  sliver: _buildCalenderHeaderSilverGrid(context),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  sliver: _buildCalendarSilverGrid(context),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 60.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderSliverGrid(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(),
        childAspectRatio: 1.0,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      delegate: SliverChildBuilderDelegate(
        _buildProviderItem,
        childCount: widget.providers.length,
      ),
    );
  }

  int getCrossAxisCount() {
    return MediaQuery.of(context).size.width > 1000
        ? 7
        : MediaQuery.of(context).size.width > 600
        ? 5
        : 3;
  }

  Widget _buildProviderItem(BuildContext context, int index) {
    final UserState userState = Provider.of<UserState>(context);
    CloudProvider provider = widget.providers[index];
    return MaterialButton(
      elevation: 1.0,
      highlightElevation: 1.0,
      padding: EdgeInsets.all(10),
      minWidth: 0,
      onPressed: () async {
        final userPool = CognitoUserPool(
          'ap-northeast-1_vBeE6Wnhx',
          '62ftnu091n05q6qgqin8174vj1',
        );
        final cognitoUser = CognitoUser('zag61728@gmail.com', userPool);
        final authDetails = AuthenticationDetails(
          username: 'zag61728@gmail.com',
          password: 'Szkeigan2811!#%',
        );
        CognitoUserSession? session;
        try {
          session = await cognitoUser.authenticateUser(authDetails);
        } on CognitoUserNewPasswordRequiredException {
          // handle New Password challenge
        } on CognitoUserMfaRequiredException {
          // handle SMS_MFA challenge
        } on CognitoUserSelectMfaTypeException {
          // handle SELECT_MFA_TYPE challenge
        } on CognitoUserMfaSetupException {
          // handle MFA_SETUP challenge
        } on CognitoUserTotpRequiredException {
          // handle SOFTWARE_TOKEN_MFA challenge
        } on CognitoUserCustomChallengeException {
          // handle CUSTOM_CHALLENGE challenge
        } on CognitoUserConfirmationNecessaryException {
          // handle User Confirmation Necessary
        } on CognitoClientException {
          // handle Wrong Username and Password and Cognito Client
        } catch (e) {
          print(e);
        }
        if (session == null) return;
        final token = session.getIdToken().getJwtToken();
        if (token != null) {
          userState.setToken(token);
        }

        _startPressed(context, provider);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.grey.shade800,
      textColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.zero,
        child: AutoSizeText(
          provider.displayName,
          style: TextStyle(fontWeight: FontWeight.w800),
          minFontSize: 20.0,
          textAlign: TextAlign.center,
          maxLines: 3,
          wrapWords: false,
        ),
      ),
    );
  }

  Widget _buildCalenderHeaderSilverGrid(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 2.0,
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
      ),
      delegate: SliverChildBuilderDelegate(
        _buildCalendarHeader,
        childCount: _weekdays.length,
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context, int index) {
    return Card(
      shadowColor: Colors.blueGrey[900],
      color: Colors.blue[700],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        child: Container(
          padding: EdgeInsets.all(4.0),
          alignment: Alignment.topCenter,
          width: 60.0,
          child: Text(
            _weekdays[index],
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600 ? 18.0 : 10.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSilverGrid(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.95,
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
      ),
      delegate: SliverChildBuilderDelegate(
        _buildCalendarItem,
        childCount: records.length,
      ),
    );
  }

  Widget _buildCalendarItem(BuildContext context, int index) {
    DailyRecord record = records[index];
    return Card(
      shadowColor: Colors.blueGrey[900],
      elevation: 4.0,
      color: _selectedDate.contains(record) ? Colors.blue[100] : Colors.white,
      child: TextButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          minimumSize: WidgetStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          // _selectedDate.add(record);
          if (record.answerDate.compareTo(_today) < 1) {
            final UserState userState = Provider.of<UserState>(
              context,
              listen: false,
            );

            _dailyPressed(context, record, userState.token);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(0.0),
                alignment: Alignment.topCenter,
                width: 60.0,
                child: Text(
                  record.answerDate.substring(5),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600
                        ? 16.0
                        : 10.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.all(0.0),
                alignment: Alignment.topCenter,
                // width: 40.0,
                child: Text(
                  (record.answerDate.compareTo(_today) == 1)
                      ? ""
                      : record.correctCount.toString() +
                            "/" +
                            record.executeCount.toString(),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600
                        ? 18.0
                        : 11.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
              // Container(
              //   padding: EdgeInsets.all(0.0),
              //   child: Text(
              //       (record.answerDate.compareTo(_today) == 1)
              //           ? ""
              //           : record.point.toString(),
              //       style: TextStyle(
              //           fontSize: 11.0,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.orange)),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  _startPressed(BuildContext context, CloudProvider provider) async {
    showLoading(context);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SelectExamPage(provider: provider)),
    );
  }

  _dailyPressed(BuildContext context, DailyRecord record, String token) async {
    List<Question> questions = await searchDayHistory(
      record.answerDate,
      context,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DailyRecordPage(questions: questions, record: record),
      ),
    );
  }

  Future<void> _onRefresh() async {
    records = await DailyRecord.readyDailyRecords();
    setState(() => {});
  }
}
