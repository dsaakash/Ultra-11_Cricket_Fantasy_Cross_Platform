import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CreateTeamScreen(),
    );
  }
}

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
  Map<String, bool> playerPlayingStatus = {};

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
    country1Name = prefs.getString('country1Name')?.toUpperCase() ?? '';
    country2Flag = prefs.getString('country2Flag') ?? '';
    country2Name = prefs.getString('country2Name')?.toUpperCase() ?? '';
    time = prefs.getString('time') ?? '';

    if (cid != null && matchId != null) {
      final List<Map<String, dynamic>> players = await getPlayers(cid, matchId);
      final response = await getMatchDetails(matchId);

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

            // Update playing status for each player
            for (var player in allPlayerList) {
              final isPlaying = playing11.contains(player);
              playerPlayingStatus[player['short_name']] = isPlaying;
            }
          });
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getPlayers(String cid, String matchId) async {
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

  Future<Map<String, dynamic>?> getMatchDetails(String matchId) async {
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

  Future<Map<String, dynamic>?> getPlaying11(String matchId) async {
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
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
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
                                playerListView("wk", "Pick 1 Wicket-keeper"),
                                playerListView("bat", "Pick 3-5 Batsmen"),
                                playerListView("bowl", "Pick 3-5 Bowlers"),
                                playerListView("all", "Pick 1-3 All-rounders"),
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
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Continue button logic here
                },
                child: Text("Continue"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (selectedPlayers.length == 11) {
                      return Colors.blue; // Enable when 11 players are selected
                    }
                    return Colors.grey; // Disable when not all players are selected
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget playerListView(String role, String header) {
    List<Map<String, dynamic>> filteredPlayers = allPlayerList.where((player) {
      return (player['playing_role'] ?? '').toLowerCase() == role.toLowerCase();
    }).toList();

    return filteredPlayers.isEmpty
        ? Center(
            child: Text("No $role players available."),
          )
        : Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(header, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Players')),
                    DataColumn(label: Text('Points')),
                    DataColumn(label: Text('Credits')),
                    DataColumn(label: Text('Select')),
                  ],
                  dataRowHeight: 60,
                  columnSpacing: 10,
                  rows: filteredPlayers.map((player) {
                    final logoUrl = player['logo_url'] as String?;
                    final fantasyPlayerRating = player['fantasy_player_rating'];
                    final isPlayerSelected = selectedPlayers.contains(player);

                    return DataRow(
                      selected: isPlayerSelected, // Set the selected property based on whether the player is selected
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  player['short_name'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: 10, width: 10),
                              Text(
                                playerPlayingStatus[player['short_name']] == true ? "Playing" : "Not Playing",
                                style: TextStyle(
                                  color: playerPlayingStatus[player['short_name']] == true
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text("0.0")),
                        DataCell(Text("$fantasyPlayerRating")),
                        // The "+" button for player selection goes here
                        DataCell(
                          IconButton(
                            icon: Icon(isPlayerSelected ? Icons.remove : Icons.add),
                            onPressed: () {
                              togglePlayerSelection(player);
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
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
            subtitle: Text(player['nationality']?.toUpperCase() ?? ''),
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
