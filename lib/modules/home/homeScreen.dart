// ignore_for_file: unnecessary_null_comparison, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tempalteflutter/api/apiProvider.dart';
import 'package:tempalteflutter/constance/constance.dart';
// import 'package:tempalteflutter/constance/sharedPreferences.dart';
import 'package:tempalteflutter/constance/themes.dart';
import 'package:tempalteflutter/models/scheduleResponseData.dart';
import 'package:tempalteflutter/modules/contests/contestsScreen.dart';
import 'package:tempalteflutter/models/userData.dart';
import 'package:tempalteflutter/modules/drawer/drawer.dart';
import 'package:tempalteflutter/modules/notification/notificationScreen.dart';
import 'package:tempalteflutter/utils/avatarImage.dart';
import 'package:tempalteflutter/validator/validator.dart';
import 'package:http/http.dart' as http;








class HomeScreen extends StatefulWidget {
  final void Function()? menuCallBack;

  const HomeScreen({Key? key, this.menuCallBack}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  var sheduallist = <ShedualData>[];
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoginProsses = false;
  late UserData userData;
  var responseData;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);

    allmatches();

    super.initState();
  }


  



  



//-----------------------------------------------All matches APi -----------------------------------//

Future<void> allmatches() async {
  try {
    setState(() {
      isLoginProsses = true; // Show the loader
    });

    final liveMatchesUrl = "https://rest.entitysport.com/v2/matches/?status=3&token=4c5b78057cd282704f2a9dd8ea556ee2";
    final upcomingMatchesUrl = "https://rest.entitysport.com/v2/matches/?status=1&token=4c5b78057cd282704f2a9dd8ea556ee2";
    final completedMatchesUrl = "https://rest.entitysport.com/v2/matches/?status=2&token=4c5b78057cd282704f2a9dd8ea556ee2";

    final liveMatchesResponse = await http.get(Uri.parse(liveMatchesUrl), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    });

    final upcomingMatchesResponse = await http.get(Uri.parse(upcomingMatchesUrl), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    });

    final completedMatchesResponse = await http.get(Uri.parse(completedMatchesUrl), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    });

    if (liveMatchesResponse.statusCode == 200 &&
        upcomingMatchesResponse.statusCode == 200 &&
        completedMatchesResponse.statusCode == 200) {
      final liveMatchesBody = json.decode(liveMatchesResponse.body);
      final upcomingMatchesBody = json.decode(upcomingMatchesResponse.body);
      final completedMatchesBody = json.decode(completedMatchesResponse.body);

      if (liveMatchesBody.containsKey('response') && liveMatchesBody['response'].containsKey('items') &&
          upcomingMatchesBody.containsKey('response') && upcomingMatchesBody['response'].containsKey('items') &&
          completedMatchesBody.containsKey('response') && completedMatchesBody['response'].containsKey('items')) {
        setState(() {
          // Combine live, upcoming, and completed matches data
          responseData = [
            ...liveMatchesBody['response']['items'],
            ...upcomingMatchesBody['response']['items'],
            ...completedMatchesBody['response']['items']
          ];
          isLoginProsses = false;
        });
      } else {
        print('No response available in the JSON for matches.');
      }
    } else {
      // Handle errors here
      print('Failed to fetch matches. Status codes: ${liveMatchesResponse.statusCode}, ${upcomingMatchesResponse.statusCode}, ${completedMatchesResponse.statusCode}');
      setState(() {
        isLoginProsses = false;
      });
      throw Exception('Failed to fetch matches.');
    }
  } catch (error) {
    // Handle exceptions or errors here
    setState(() {
      isLoginProsses = false;
    });
    print('Error: $error');
    throw Exception('Failed to fetch matches.');
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: AllCoustomTheme.getThemeData().primaryColor,
        ),
        SafeArea(
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AllCoustomTheme.getThemeData().primaryColor,
              title: Text(
                'Matches',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            drawer: AppDrawer(
              mySettingClick: () {},
              referralClick: () {},
            ),
            key: _scaffoldKey,
            backgroundColor: AllCoustomTheme.getThemeData().backgroundColor,
            body: RefreshIndicator(
              displacement: 100,
              key: _refreshIndicatorKey,
              onRefresh: () async {
                await allmatches();
              },
              child: ModalProgressHUD(
                inAsyncCall: isLoginProsses,
                color: Colors.transparent,
                progressIndicator: CircularProgressIndicator(
                  strokeWidth: 2.0,
                ),
                child: Stack(
                  children: <Widget>[
                    CustomScrollView(
                      physics: BouncingScrollPhysics(),
                      slivers: <Widget>[
                        SliverList(
                          delegate: new SliverChildBuilderDelegate(
                            (context, index) => listItems(),
                            childCount: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget drawerButton() {
    return InkWell(
      onTap: openDrawer,
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: AllCoustomTheme.getThemeData().scaffoldBackgroundColor,
            radius: 16,
            child: AvatarImage(
              imageUrl: 'https://www.menshairstylesnow.com/wp-content/uploads/2018/03/Hairstyles-for-Square-Faces-Slicked-Back-Undercut.jpg',
              isCircle: true,
              radius: 28,
              sizeValue: 28,
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Icon(
            Icons.sort,
            size: 30,
          )
        ],
      ),
    );
  }

  Widget notificationButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationScreen(),
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12),
        child: Icon(
          Icons.notifications,
          color: AllCoustomTheme.getReBlackAndWhiteThemeColors(),
        ),
      ),
    );
  }

  Widget sliverText() {
    return FlexibleSpaceBar(
      centerTitle: false,
      titlePadding: EdgeInsetsDirectional.only(start: 16, bottom: 8, top: 0),
      title: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Upcoming Matches',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showInSnackBar(String value) {
    var snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: new Text(
        value,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: ConstanceData.SIZE_TITLE14,
          color: AllCoustomTheme.getReBlackAndWhiteThemeColors(),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

 Widget listItems() {
  if (responseData == null) {
    return Container();
  }

  

  final matchCards = responseData.map<Widget>((match) {
    final title = match['title'];
    final country1 = match['teama'];
    final country2 = match['teamb'];

    // Check if the required data is not null
    if (title != null && country1 != null && country2 != null) {
      // final country1Name = country1['name'];
      final country1Name = country1['short_name'];
      // final country2Name = country2['name'];
      final country2Name = country2['short_name'];
      final teamA = country1;
      final teamB = country2;

      List<Widget> teamWidgets = [];

      if (teamA != null && teamB != null) {
        final allTeams = [teamA, teamB];

        for (var team in allTeams) {
         // final name = team['name'];
          final shortName = team['short_name'];
          final img = team['logo_url'];
          teamWidgets.add(
            SingleChildScrollView(
              child: Column(
                children: [
                 // Text('Name: $name'),
                  Text('Shortname: $shortName'),
                  if (img != null) Image.network(img),
                ],
              ),
            ),
          );
        }
      } else {
        teamWidgets.add(Text('No teamInfo available for this match.'));
      }

      final country1Flag = country1Name != null ? country1['logo_url'] : null;
      final country2Flag = country2Name != null ? country2['logo_url'] : null;

      final price = "₹2 Lakhs"; // You may extract the price from the data.
      // final time = match['date_start'];
      final time = match['date_start_ist'];
      final cid = match['competition']['cid'];

      if (country1Name != null && country2Name != null) {
        return MatchesList(
          matchId: match['match_id'].toString(),
          titel: title,
          country1Name: country1Name,
          country2Name: country2Name,
          country1Flag: country1Flag,
          country2Flag: country2Flag,
          price: price,
          time: time,
          cid: match['competition']['cid'].toString(),
        );
      }
    }

    // Handle null values or incomplete data
    return Container(); // You can return an empty container or a placeholder
  }).toList();

  return Column(children: matchCards);
}


  void openDrawer() {
    widget.menuCallBack!();
  }
}
class MatchesList extends StatefulWidget {
  final String? titel;
  final String? country1Name;
  final String? country1Flag;
  final String? country2Name;
  final String? country2Flag;
  final String? time;
  final String? price;
  final String? matchId; // Add matchId
  final String? cid; // Add competitionId

  const MatchesList({
    Key? key,
    this.titel,
    this.country1Name,
    this.country2Name,
    this.time,
    this.price,
    this.country1Flag,
    this.country2Flag,
    this.matchId, // Include matchId in the constructor
    this.cid, // Include competitionId in the constructor
  }) : super(key: key);

  @override
  _MatchesListState createState() => _MatchesListState();
}

class _MatchesListState extends State<MatchesList> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        print(widget.cid);
        print(widget.matchId);
        // Get an instance of SharedPreferences
SharedPreferences prefs = await SharedPreferences.getInstance();

// Store a key-value pair in SharedPreferences
prefs.setString('cid', widget.cid!);
prefs.setString('matchId', widget.matchId!);
prefs.setString('country1Flag',widget.country1Flag!);
prefs.setString('country1Name',widget.country1Name!);

prefs.setString('time',widget.time!);



prefs.setString('country2Flag',widget.country2Flag!);
prefs.setString('country2Name',widget.country2Name!);

// prefs.setString('country2Flag',widget.country2Flag!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContestsScreen(
              country1Flag: widget.country1Flag,
              country2Flag: widget.country2Flag,
              country1Name: widget.country1Name,
              country2Name: widget.country2Name,
              price: widget.price,
              time: widget.time,
              titel: widget.titel,
              cid: widget.cid,
              matchId: widget.matchId,

            ),
          ),
        );
      },
      onLongPress: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (
            BuildContext context,
          ) =>
              UnderGroundDrawer(
            country1Flag: widget.country1Flag!,
            country2Flag: widget.country2Flag!,
            country1Name: widget.country1Name!,
            country2Name: widget.country2Name!,
            price: widget.price!,
            time: widget.time!,
            titel: widget.titel!,
          ),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.titel!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2, // Limit title to 2 lines
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      Image.asset(
                        ConstanceData.lineups,
                        height: 14,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Icons.notification_add_outlined,
                        size: 16,
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1.3,
                  ),
                  Row(
                    children: [
                      Text(
                        widget.country1Name!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                     
                      Expanded(child: SizedBox()),
                      Text(
                        widget.country2Name!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: Image.network(widget.country1Flag!),
                      ),

                      Container(
                        child: Text(
                          widget.time!,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: ConstanceData.SIZE_TITLE12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        child: Image.network(widget.country2Flag!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AllCoustomTheme.isLight ? HexColor("#f5f5f5") : Theme.of(context).disabledColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 3, left: 3),
                        child: Text(
                          "Mega",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: ConstanceData.SIZE_TITLE12,
                            color: Colors.green,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.price!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: ConstanceData.SIZE_TITLE12,
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Image.asset(
                      ConstanceData.tv,
                      height: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UnderGroundDrawer extends StatefulWidget {
  final String? titel;
  final String? country1Name;
  final String? country1Flag;
  final String? country2Name;
  final String? country2Flag;
  final String? time;
  final String? price;

  const UnderGroundDrawer({
    Key? key,
    this.titel,
    this.country1Name,
    this.country1Flag,
    this.country2Name,
    this.country2Flag,
    this.time,
    this.price,
  }) : super(key: key);

  @override
  _UnderGroundDrawerState createState() => _UnderGroundDrawerState();
}

class _UnderGroundDrawerState extends State<UnderGroundDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        children: <Widget>[
          matchSchedulData(),
          Divider(
            height: 1,
          ),
          Expanded(
            child: matchInfoList(),
          ),
        ],
      ),
    );
  }

  Widget matchInfoList() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 16, left: 16, top: 10, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        'Match',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getTextThemeColors(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Text(
                        widget.country1Name! + " vs " + widget.country2Name!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getBlackAndWhiteThemeColors(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.only(right: 16, left: 16, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        'Series',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getTextThemeColors(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Text(
                        widget.titel!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getBlackAndWhiteThemeColors(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.only(right: 16, left: 16, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        'Start Date',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getTextThemeColors(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Text(
                        widget.time!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getBlackAndWhiteThemeColors(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.only(right: 16, left: 16, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        'Start Time',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getTextThemeColors(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Text(
                        '15:00:00',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getBlackAndWhiteThemeColors(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.only(right: 16, left: 16, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        'Venue',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getTextThemeColors(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Text(
                        'India',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getBlackAndWhiteThemeColors(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.only(right: 16, left: 16, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        'Umpires',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getTextThemeColors(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Text(
                        'Martine',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getBlackAndWhiteThemeColors(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.only(right: 16, left: 16, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        'Referee',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getTextThemeColors(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Text(
                        'Charls piter',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getBlackAndWhiteThemeColors(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.only(right: 16, left: 16, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        'Match Format',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getTextThemeColors(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Text(
                        'Match Formate',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getBlackAndWhiteThemeColors(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.only(right: 16, left: 16, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        'Location',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getTextThemeColors(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Text(
                        'India',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getBlackAndWhiteThemeColors(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider()
            ],
          ),
        );
      },
    );
  }

  Widget matchSchedulData() {
    return Container(
      padding: EdgeInsets.all(10),
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                child: Container(
                  width: 50,
                  height: 50,
                  child: Image.network(widget.country1Flag!),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: 4),
            child: new Text(
              widget.country1Name!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: AllCoustomTheme.getThemeData().primaryColor,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            child: Text(
              'vs',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: ConstanceData.SIZE_TITLE14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            child: new Text(
              widget.country2Name!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: AllCoustomTheme.getThemeData().primaryColor,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 4),
            child: Container(
              child: Container(
                width: 50,
                height: 50,
                child: Image.network(widget.country2Flag!),
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Text(
            widget.time!,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: HexColor(
                '#AAAFBC',
              ),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

enum AppBarBehavior { normal, pinned, floating, snapping }