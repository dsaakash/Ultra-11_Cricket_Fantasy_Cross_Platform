import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTeamScreen extends StatefulWidget {
  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  List<Map<String, dynamic>> allPlayerList = [];
  bool isDataLoading = true;
  String team1ImageUrl = '';
  String team2ImageUrl = '';
  int wkCount = 0;
  int batCount = 0;
  int bowlCount = 0;
  int arCount = 0;
String country1Flag = '';
String country2Flag = '';
String country1Name = '';
String country2Name = '';
String time = '';
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cid = prefs.getString('cid');
    String? matchId = prefs.getString('matchId');
   


   country1Flag = prefs.getString('country1Flag') ?? ''; // Assign from shared preferences
   country1Name = prefs.getString('country1Name') ?? ''; 
   country2Flag = prefs.getString('country2Flag') ?? '';
   country2Name = prefs.getString('country2Name') ?? '';
   time  = prefs.getString('time') ?? '';


   





    if (cid != null && matchId != null) {
      final List<Map<String, dynamic>> players = await getPlayers(cid, matchId);

      final response = await getMatchDetails(cid, matchId);

      setState(() {
        allPlayerList = players;
        isDataLoading = false;
        if (response != null) {
          team1ImageUrl = response['squad'][0]['team']['logo_url'] ?? '';
          team2ImageUrl = response['squad'][1]['team']['logo_url'] ?? '';
        }

        // Count players in each category
        wkCount = players.where((player) => (player['playing_role'] ?? '').toLowerCase() == "wk").length;
        batCount = players.where((player) => (player['playing_role'] ?? '').toLowerCase() == "bat").length;
        bowlCount = players.where((player) => (player['playing_role'] ?? '').toLowerCase() == "bowl").length;
        arCount = players.where((player) => (player['playing_role'] ?? '').toLowerCase() == "all").length;
      });
    }
  }

  Future<List<Map<String, dynamic>>> getPlayers(cid, matchId) async {
    final List<Map<String, dynamic>> players = [];

    final String query =
        "https://rest.entitysport.com/v2/competitions/$cid/squads/$matchId?token=4c5b78057cd282704f2a9dd8ea556ee2";

    final Map<String, dynamic> headers = {
      "Content-Type": "application/json",
    };

    try {
      final response = await Dio().get(
        query,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final List<dynamic>? squads = response.data?['response']['squads'];

        if (squads != null) {
          for (var squad in squads) {
            final List<dynamic>? playersList = squad['players'];
            if (playersList != null) {
              players.addAll(playersList.cast<Map<String, dynamic>>());
            }
          }
        }
      }

      return players;
    } catch (e) {
      print("Error fetching player data: $e");
      return players; // Return an empty list in case of an error
    }
  }

  Future<Map<String, dynamic>?> getMatchDetails(cid, matchId) async {
    final String query =
        "https://rest.entitysport.com/v2/match/squads/$matchId?token=4c5b78057cd282704f2a9dd8ea556ee2";

    final Map<String, dynamic> headers = {
      "Content-Type": "application/json",
    };

    try {
      final response = await Dio().get(
        query,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? matchDetails = response.data?['response'];

        return matchDetails;
      }

      return null;
    } catch (e) {
      print("Error fetching match details: $e");
      return null;
    }
  }

 @override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 4, // Number of tabs (wk, bat, bowl, AR)
    child: Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(country1Name, style: TextStyle(fontSize: 14)),
                Text(country2Name, style: TextStyle(fontSize: 14)),
                Text(time, style: TextStyle(fontSize: 12)),
              ],
            ),
            Image.network(
              country1Flag,
              height: 40,
              width: 40,
            ),
            Image.network(
              country2Flag,
              height: 40,
              width: 40,
            ),
          ],
        ),
        bottom: TabBar(
          tabs: [
            Tab(text: "wk (${wkCount.toString()})"),
            Tab(text: "bat (${batCount.toString()})"),
            Tab(text: "bowl (${bowlCount.toString()})"),
            Tab(text: "AR (${arCount.toString()})"),
          ],
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isDataLoading,
        child: Column(
          children: [
            // Team logos section (if needed)
            // You can add any other content here
            Expanded(
              child: isDataLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : TabBarView(
                      children: [
                        playerListView("wk"),
                        playerListView("bat"),
                        playerListView("bowl"),
                        playerListView("all"),
                      ],
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}


 Widget playerListView(String role) {
  // Filter players based on the selected role
  List<Map<String, dynamic>> filteredPlayers = allPlayerList.where((player) {
    return (player['playing_role'] ?? '').toLowerCase() == role.toLowerCase();
  }).toList();

  return filteredPlayers.isEmpty
      ? Center(
          child: Text("No $role players available."),
        )
      : ListView.builder(
          itemCount: filteredPlayers.length,
          itemBuilder: (context, index) {
            final player = filteredPlayers[index];
            final logoUrl = player['logo_url'] as String?;
            final fantasyPlayerRating = player['fantasy_player_rating'];

            return Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Row(
                  children: [
                    Text(player['short_name'] ?? ''),
                    SizedBox(width: 15), // Add spacing between Short Name and Nationality
                    Text("${player['nationality'] ?? ''}"),
                    SizedBox(width: 15), // Add spacing between Nationality and Fantasy Rating
                    Text("$fantasyPlayerRating"),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // You can add more details here if needed.
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // if (logoUrl != null) // Show logo if logoUrl is not null
                    //   Image.network(
                    //     logoUrl,
                    //     height: 50,
                    //     width: 50,
                    //   ),
                  ],
                ),
              ),
            );
          },
        );
}
}