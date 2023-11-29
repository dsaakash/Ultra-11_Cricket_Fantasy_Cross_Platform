import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Player {
  final String name;
  final bool playing11;
  final String team;
  Player({required this.name, required this.playing11, required this.team});
}

class CreateTeamScreen extends StatefulWidget {
  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  List<Map<String, dynamic>> allPlayerList = [];
  List<Map<String, dynamic>> playing11 = [];
  List playersData = [];
  List playersPlayingData = [];
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

  // Modifications
  List playersTeamOne = [];
  List playersTeamTwo = [];
  List playersIsPlayingOrNot = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cid = prefs.getString('cid');
      String? matchId = prefs.getString('matchId');
      country1Flag = prefs.getString('country1Flag') ?? '';
      country1Name = prefs.getString('country1Name')?.toUpperCase() ?? '';
      country2Flag = prefs.getString('country2Flag') ?? '';
      country2Name = prefs.getString('country2Name')?.toUpperCase() ?? '';
      time = prefs.getString('time') ?? '';

      if (cid != null && matchId != null) {
        try {
          final List<Map<String, dynamic>> players =
              await getPlayers(cid, matchId);
          final response = await getMatchDetails(matchId);

          print(" --------- 1 ");

          setState(() {
            allPlayerList = players;
            isDataLoading = false;
            if (response != null) {
              team1ImageUrl = response['squad'][0]['team']['logo_url'] ?? '';
              team2ImageUrl = response['squad'][1]['team']['logo_url'] ?? '';
            }
            wkCount = players
                .where((player) =>
                    (player['playing_role'] ?? '').toLowerCase() == "wk")
                .length;
            batCount = players
                .where((player) =>
                    (player['playing_role'] ?? '').toLowerCase() == "bat")
                .length;
            arCount = players
                .where((player) =>
                    (player['playing_role'] ?? '').toLowerCase() == "all")
                .length;
            bowlCount = players
                .where((player) =>
                    (player['playing_role'] ?? '').toLowerCase() == "bowl")
                .length;
          });
          print(" --------- 11 ");
          if (matchId != null) {
            print(" --------- 111 ");
            final playing11Response = await getPlaying11(matchId);
            print(" --------- 1111 ");
            if (playing11Response != null) {
              setState(() {
                playing11 = playing11Response;
                print(playing11);
                playersIsPlayingOrNot = playing11Response;
                print(playersIsPlayingOrNot);
                // for (var player in allPlayerList) {
                //   final isPlaying = playing11.any((playingPlayer) =>
                //       playingPlayer['name'] == player['name']);
                //   playerPlayingStatus[player['name']] = isPlaying;
                // }
              });
            }
          }
          checkIfPlayersAndPlayingState();
        } on DioError catch (e) {
          print("DioException 1 : $e");
          // Handle DioError
        } catch (e) {
          print("Error fetching data: 2  $e");
          // Handle other errors
        }
      }
    } on DioError catch (e) {
      print("DioException 3 : $e");
    } catch (e) {
      print("Error fetching data 4 : $e");
    }
  }

  Future<List<Map<String, dynamic>>> getPlayers(
      String cid, String matchId) async {
    final List<Map<String, dynamic>> players = [];
    final String query =
        "https://rest.entitysport.com/v2/competitions/$cid/squads/$matchId?token=4c5b78057cd282704f2a9dd8ea556ee2";
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
            setState(() {
              playersTeamOne =
                  response.data?['response']['squads'][0]['players'];
              playersTeamTwo =
                  response.data?['response']['squads'][1]['players'];
            });
            final List<dynamic>? playersList = squad['players'];
            if (playersList != null) {
              playersData = playersList;
              players.addAll(playersList.map((dynamic item) {
                return item as Map<String, dynamic>;
              }).toList());
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
    final String query =
        "https://rest.entitysport.com/v2/match/squads/$matchId?token=4c5b78057cd282704f2a9dd8ea556ee2";
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

  Future<List<Map<String, dynamic>>?> getPlaying11(String matchId) async {
    final String query =
        "https://rest.entitysport.com/v2/matches/$matchId/squads?token=4c5b78057cd282704f2a9dd8ea556ee2";
    final Map<String, dynamic> headers = {"Content-Type": "application/json"};
    try {
      final response = await Dio().get(
        query,
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseData = response.data?['response'];
        final List<Map<String, dynamic>> playing11Response = [];
        if (responseData != null) {
          for (var teamKey in ['teama', 'teamb']) {
            playersPlayingData = responseData[teamKey]?['squads'];
            final List<dynamic>? squads = responseData[teamKey]?['squads'];
            if (squads != null) {
              playing11Response.addAll(List<Map<String, dynamic>>.from(squads));
            }
          }
          return playing11Response;
        }
      } else {
        print("Error: ${response.statusCode}, ${response.statusMessage}");
      }
      return null;
    } catch (e) {
      print("Error fetching playing 11: $e");
      return null;
    }
  }

  // checkIfPlayersAndPlayingState() {
  //   print("====================== START =====================");
  //   print(playersTeamOne);
  //   print(playersTeamTwo);
  //   print(playersIsPlayingOrNot);
  //   // playersIsPlayingOrNot = [];
  //   // Iterate through playersTeamOne
  //   for (var i = 0; i < playersTeamOne.length; i++) {
  //     var playerTeamOne = playersTeamOne[i];
  //     var pidTeamOne = playerTeamOne['pid'];

  //     // Set isPlaying to true for the first player (for testing purposes)
  //     // var isPlayingTeamOne = i == 0;

  //     // Check if pidTeamOne is in playersIsPlayingOrNot
  //     var isPlayingTeamOne = playersIsPlayingOrNot
  //         .any((player) => player['player_id'] == pidTeamOne);

  //     // Add the isPlaying property to the player object
  //     playerTeamOne['isPlaying'] = isPlayingTeamOne;

  //     // Print the result
  //     print('Player with pid $pidTeamOne is playing: $isPlayingTeamOne');
  //   }

  //   // Iterate through playersTeamTwo
  //   for (var i = 0; i < playersTeamTwo.length; i++) {
  //     var playerTeamTwo = playersTeamTwo[i];
  //     var pidTeamTwo = playerTeamTwo['pid'];

  //     // Check if pidTeamTwo is in playersIsPlayingOrNot
  //     var isPlayingTeamTwo = playersIsPlayingOrNot
  //         .any((player) => player['player_id'] == pidTeamTwo);

  //     // Add the isPlaying property to the player object
  //     playerTeamTwo['isPlaying'] = isPlayingTeamTwo;

  //     // Print the result
  //     print('Player with pid $pidTeamTwo is playing: $isPlayingTeamTwo');
  //   }
  //   print("====================== STOP =====================");
  // }

  void checkIfPlayersAndPlayingState() {
  print("====================== START =====================");

  // Iterate through playersTeamOne
  for (var i = 0; i < playersTeamOne.length; i++) {
    var playerTeamOne = playersTeamOne[i];
    var pidTeamOne = playerTeamOne['pid'];

    // Check if pidTeamOne is in isplaying data and if the player is in playing eleven
    var isPlayingTeamOne = playersIsPlayingOrNot
        .any((playingPlayer) => playingPlayer['player_id'] == pidTeamOne.toString() && playingPlayer['playing11'] == 'true');

    // Add the isPlaying property to the player object
    playerTeamOne['isPlaying'] = isPlayingTeamOne;

    // Print the result
    print('Player with pid $pidTeamOne is playing: $isPlayingTeamOne');
  }

  // Iterate through playersTeamTwo
  for (var i = 0; i < playersTeamTwo.length; i++) {
    var playerTeamTwo = playersTeamTwo[i];
    var pidTeamTwo = playerTeamTwo['pid'];

    // Check if pidTeamTwo is in isplaying data and if the player is in playing eleven
    var isPlayingTeamTwo = playersIsPlayingOrNot
        .any((playingPlayer) => playingPlayer['player_id'] == pidTeamTwo.toString() && playingPlayer['playing11'] == 'true');

    // Add the isPlaying property to the player object
    playerTeamTwo['isPlaying'] = isPlayingTeamTwo;

    // Print the result
    print('Player with pid $pidTeamTwo is playing: $isPlayingTeamTwo');
  }

  print("====================== STOP =====================");
}


  Widget _buildPlayerAvatar(Map<String, dynamic> player) {
    final logoUrl = player['logo_url'] as String?;
    final defaultImage = AssetImage('assets/playerImage.png');
    final imageUrl = logoUrl ?? '';

    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.transparent,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Image(image: defaultImage);
                  },
                )
              : Image(image: defaultImage),
        ),
        SizedBox(height: 4),
        Text(
          player['isPlaying'] == true ? "Playing" : "Not Playing",
          style: TextStyle(
            color: player['isPlaying'] == true ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
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
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.grey[300], // Light Grey Background
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      header,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Player')),
                      DataColumn(label: Text('Points')),
                      DataColumn(label: Text('Credits')),
                      DataColumn(label: Text('Select')),
                    ],
                    dataRowHeight: 80,
                    columnSpacing: 10,
                    rows: filteredPlayers.map((player) {
                      final fantasyPlayerRating =
                          player['fantasy_player_rating'];
                      final isPlayerSelected = selectedPlayers.contains(player);
                      return DataRow(
                        selected: isPlayerSelected,
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                _buildPlayerAvatar(player),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    player['short_name'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          playerPlayingStatus[player['pid']] ==
                                                  true
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text("0.0")),
                          DataCell(Text("$fantasyPlayerRating")),
                          DataCell(
                            IconButton(
                              icon: Icon(
                                  isPlayerSelected ? Icons.remove : Icons.add),
                              color: playerPlayingStatus[player['pid']] == true
                                  ? Colors.green
                                  : Colors.red,
                              onPressed: () {
                                togglePlayerSelection(player);
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
  }

  Future<bool> getPlayingStatus(Map<String, dynamic> player) async {
    final String playerName = player['pid'].toString();
    // Check if player data is available
    final bool isPlayerDataAvailable =
        playersData.any((data) => data['pid'] == playerName);

    if (!isPlayerDataAvailable) {
      // Player data is not available, return false
      return false;
    }

    // Assuming playing11 is a list of Map<String, dynamic> containing playing 11 data
    final bool isInPlaying11 = playersPlayingData
        .any((playingPlayer) => playingPlayer['player_id'] == playerName);

    // Return true if the player is present in playing11
    return isInPlaying11;
  }

  void togglePlayerSelection(Map<String, dynamic> player) {
    setState(() {
      if (selectedPlayers.contains(player)) {
        selectedPlayers.remove(player);
      } else {
        if (player['playing_role'] == "wk" &&
            selectedPlayers.where((p) => p['playing_role'] == "wk").length <
                2) {
          selectedPlayers.add(player);
        } else if (player['playing_role'] == "bat" &&
            selectedPlayers.where((p) => p['playing_role'] == "bat").length <
                5) {
          selectedPlayers.add(player);
        } else if (player['playing_role'] == "all" &&
            selectedPlayers.where((p) => p['playing_role'] == "all").length <
                3) {
          selectedPlayers.add(player);
        } else if (player['playing_role'] == "bowl" &&
            selectedPlayers.where((p) => p['playing_role'] == "bowl").length <
                5) {
          selectedPlayers.add(player);
        }
      }
      if (selectedPlayers.length > 11) {
        // Display a prompt when more than 11 players are selected
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Player Limit Exceeded"),
              content: Text(
                  "You can select a maximum of 11 players. Choose your team wisely."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              Tab(text: "WK"),
                              Tab(text: "BAT"),
                              Tab(text: "AR"),
                              Tab(text: "BOWL"),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                playerListView("wk", "Wicket-keepers (Pick 2)"),
                                playerListView("bat", "Batsmen (Pick 3-5)"),
                                playerListView(
                                    "all", "All-rounders (Pick 1-3)"),
                                playerListView("bowl", "Bowlers (Pick 3-5)"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PreviewScreen(selectedPlayers: selectedPlayers),
                  ),
                );
              },
              child: Text("Preview"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (selectedPlayers.length == 11) {
                  // Continue button logic here
                }
              },
              child: Text("Continue"),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (selectedPlayers.length == 11) {
                    return Colors.blue;
                  }
                  return Colors.grey;
                }),
              ),
            ),
          ],
        ),
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
