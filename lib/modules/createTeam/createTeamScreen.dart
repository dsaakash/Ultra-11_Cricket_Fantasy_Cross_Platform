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
  List<Map<String, dynamic>> playing11 = [];
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

  Set<Map<String, dynamic>> selectedPlayers = Set<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cid = prefs.getString('cid');
    String? matchId = prefs.getString('matchId');

    country1Flag = prefs.getString('country1Flag') ?? '';
    country1Name = prefs.getString('country1Name') ?? '';
    country2Flag = prefs.getString('country2Flag') ?? '';
    country2Name = prefs.getString('country2Name') ?? '';
    time = prefs.getString('time') ?? '';

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

        wkCount = players.where((player) => (player['playing_role'] ?? '').toLowerCase() == "wk").length;
        batCount = players.where((player) => (player['playing_role'] ?? '').toLowerCase() == "bat").length;
        bowlCount = players.where((player) => (player['playing_role'] ?? '').toLowerCase() == "bowl").length;
        arCount = players.where((player) => (player['playing_role'] ?? '').toLowerCase() == "all").length;
      });

      if (matchId != null) {
        final playing11Response = await getPlaying11(matchId);

        if (playing11Response != null) {
          setState(() {
            playing11 = playing11Response['players'] ?? [];
          });
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getPlayers(cid, matchId) async {
    final List<Map<String, dynamic>> players = [];
    final String query = "https://rest.entitysport.com/v2/competitions/$cid/squads/$matchId?token=4c5b78057cd282704f2a9dd8ea556ee2";
    final Map<String, dynamic> headers = {"Content-Type": "application/json"};

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
      return players;
    }
  }

  Future<Map<String, dynamic>?> getMatchDetails(cid, matchId) async {
    final String query = "https://rest.entitysport.com/v2/match/squads/$matchId?token=4c5b78057cd282704f2a9dd8ea556ee2";
    final Map<String, dynamic> headers = {"Content-Type": "application/json"};

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

  Future<Map<String, dynamic>?> getPlaying11(matchId) async {
    final String query = "https://rest.entitysport.com/v2/matches/$matchId/squads?token=4c5b78057cd282704f2a9dd8ea556ee2";
    final Map<String, dynamic> headers = {"Content-Type": "application/json"};

    try {
      final response = await Dio().get(
        query,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? playing11Response = response.data?['response'];

        return playing11Response;
      }

      return null;
    } catch (e) {
      print("Error fetching playing 11: $e");
      return null;
    }
  }

  void togglePlayerSelection(Map<String, dynamic> player) {
    setState(() {
      if (selectedPlayers.contains(player)) {
        selectedPlayers.remove(player);
      } else {
        if (selectedPlayers.length < 11) {
          selectedPlayers.add(player);
        }
      }
    });
  }

 @override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 4,
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
        // bottom: TabBar(
        //   tabs: [
        //     Tab(text: "wk (${wkCount.toString()})"),
        //     Tab(text: "bat (${batCount.toString()})"),
        //     Tab(text: "bowl (${bowlCount.toString()})"),
        //     Tab(text: "AR (${arCount.toString()})"),
        //   ],
        // ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isDataLoading,
        child: Column(
          children: [
            Expanded(
              child: isDataLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                       TabBar(
  labelColor: Colors.black, // Set the text color of the selected (active) tab to black
  unselectedLabelColor: Colors.grey, // Set the text color of unselected (inactive) tabs to grey or any color you prefer
  tabs: [
    Tab(text: "WK (${wkCount.toString()})"),
    Tab(text: "BAT (${batCount.toString()})"),
    Tab(text: "BOWL (${bowlCount.toString()})"),
    Tab(text: "AR (${arCount.toString()})"),
  ],
),
                        Expanded(
                          child: TabBarView(
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
            if (selectedPlayers.length == 11)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviewScreen(selectedPlayers: selectedPlayers),
                    ),
                  );
                },
                child: Text("Preview"),
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget playerListView(String role) {
  List<Map<String, dynamic>> filteredPlayers = allPlayerList.where((player) {
    return (player['playing_role'] ?? '').toLowerCase() == role.toLowerCase();
  }).toList();

  return filteredPlayers.isEmpty
    ? Center(
        child: Text("No $role players available."),
      )
    : ListView(
      shrinkWrap: true, // Add this line
      children: filteredPlayers.map((player) {
        final logoUrl = player['logo_url'] as String?;
        final fantasyPlayerRating = player['fantasy_player_rating'];
        final isPlaying = playing11.contains(player);
        final isPlayerSelected = selectedPlayers.contains(player);
        final playingStatus = isPlaying ? "Playing 11" : "Not Playing";
        final textColor = isPlaying ? Colors.green : Colors.red;
        final selectButtonText = isPlayerSelected ? "Deselect" : "Select";

        return Card(
          margin: EdgeInsets.all(8.0),
          color: isPlayerSelected ? Colors.blue : isPlaying ? Colors.green : Colors.white,
          child: ListTile(
            title: Row(
              children: [
                Text(player['short_name'] ?? ''),
                SizedBox(width: 15),
                Text("${player['nationality'] ?? ''}"),
                SizedBox(width: 15),
                Text("$fantasyPlayerRating"),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playingStatus,
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    togglePlayerSelection(player);
                  },
                  child: Text(selectButtonText),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      isPlayerSelected ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                // if (logoUrl != null)
                //   Image.network(
                //     logoUrl,
                //     logoUrl,
                //     height: 50,
                //     width: 50,
                //   ),
              ],
            ),
          ),
        );
      }).toList(),
    );
}
}

class PreviewScreen extends StatelessWidget {
  final Set<Map<String, dynamic>> selectedPlayers;

  PreviewScreen({required this.selectedPlayers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selected Players"),
      ),
      body: ListView(
        children: selectedPlayers.map((player) {
          return ListTile(
            title: Text(player['short_name'] ?? ''),
            subtitle: Text(player['nationality'] ?? ''),
            trailing: Image.network(
              player['logo_url'] ?? '',
              height: 50,
              width: 50,
            ),
          );
        }).toList(),
      ),
    );
  }
}
