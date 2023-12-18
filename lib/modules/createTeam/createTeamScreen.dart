import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:ui';

class Player {
  final String name;
  final bool playing11;
  final String team;
  Player({required this.name, required this.playing11, required this.team});
}


class PlayerRole {
  Map<String, dynamic> player;
  String role;

  PlayerRole({required this.player, this.role = ''});
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
          if (matchId != null) {
            final playing11Response = await getPlaying11(matchId);
            if (playing11Response != null) {
              setState(() {
                playing11 = playing11Response;
                playersIsPlayingOrNot = playing11Response;
              });
            }
          }
          checkIfPlayersAndPlayingState();
        } on DioError catch (e) {
          print("DioException 1 : $e");
        } catch (e) {
          print("Error fetching data: 2  $e");
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

  void checkIfPlayersAndPlayingState() {
    for (var i = 0; i < playersTeamOne.length; i++) {
      var playerTeamOne = playersTeamOne[i];
      var pidTeamOne = playerTeamOne['pid'];
      var isPlayingTeamOne = playersIsPlayingOrNot.any((playingPlayer) =>
          playingPlayer['player_id'] == pidTeamOne.toString() &&
          playingPlayer['playing11'] == 'true');
      playerTeamOne['isPlaying'] = isPlayingTeamOne;
    }
    for (var i = 0; i < playersTeamTwo.length; i++) {
      var playerTeamTwo = playersTeamTwo[i];
      var pidTeamTwo = playerTeamTwo['pid'];
      var isPlayingTeamTwo = playersIsPlayingOrNot.any((playingPlayer) =>
          playingPlayer['player_id'] == pidTeamTwo.toString() &&
          playingPlayer['playing11'] == 'true');
      playerTeamTwo['isPlaying'] = isPlayingTeamTwo;
    }
  }

  Widget _buildPlayerAvatar(Map<String, dynamic> player) {
    final logoUrl = player['logo_url'] as String?;
    final defaultImage = AssetImage('assets/playerImage.png');
    final imageUrl = logoUrl ?? '';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerDetailsScreen(player: player),
          ),
        );
      },
      child: Column(
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
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.grey[300],
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
    final bool isPlayerDataAvailable =
        playersData.any((data) => data['pid'] == playerName);
    if (!isPlayerDataAvailable) {
      return false;
    }
    final bool isInPlaying11 = playersPlayingData
        .any((playingPlayer) => playingPlayer['player_id'] == playerName);
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
  int selectedPlayerCount = 0;

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
                              playerListView("all", "All-rounders (Pick 1-3)"),
                              playerListView("bowl", "Bowlers (Pick 3-5)"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviewScreen(
                        selectedPlayers: selectedPlayers,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  child: Text(
                    "Preview",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: selectedPlayers.length == 11 ? 1.0 : 0.5,
                child: ElevatedButton(
                  onPressed: selectedPlayers.length == 11
                      ? ()  {
                          // Your code when the "Continue" button is pressed
                          print(selectedPlayers);


                           Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SelectCaptainScreen(
                                        selectedPlayers: selectedPlayers.toList(), // Convert Set to List
                                      ),
                                    ),
                                  );
 
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20.0,
                    ),
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Column(
            children: [
              Visibility(
                visible: selectedPlayers.length != 11,
                child: Text(
                  '${selectedPlayers.length} players selected',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: ElevatedButton(
                  onPressed: selectedPlayers.length == 11
                      ? null
                      : () {
                          // Your code when the button is pressed
                         
                         
                        },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20.0,
                    ),
                    child: Text(
                      "Select Captains",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
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
}



class SelectCaptainScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedPlayers;

  SelectCaptainScreen({required this.selectedPlayers});

  final AssetImage defaultImage = AssetImage('assets/playerImage.png');

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> playersByRole = _groupAndSortPlayers(selectedPlayers);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20.0,
              child: Marquee(
                text: 'Select Captain, Vice Captain, Deputy Captain, and Assistant Captain',
                style: TextStyle(fontSize: 14),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                blankSpace: 20.0,
                velocity: 100.0,
                pauseAfterRound: Duration(seconds: 1),
                startPadding: 10.0,
                accelerationDuration: Duration(seconds: 1),
                accelerationCurve: Curves.linear,
                decelerationDuration: Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              ),
            ),
            SizedBox(
              height: 20.0,
              child: Marquee(
                text: "C gets 2x points, VC gets 1.5x points",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 59, 255, 121)),
                scrollAxis: Axis.horizontal,
                blankSpace: 20.0,
                velocity: 100.0,
                pauseAfterRound: Duration(seconds: 1),
              ),
            ),
            SizedBox(
              height: 20.0,
              child: Marquee(
                text: "DC gets 1x points, AC gets 0.5x points",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 59, 255, 137)),
                scrollAxis: Axis.horizontal,
                blankSpace: 20.0,
                velocity: 100.0,
                pauseAfterRound: Duration(seconds: 1),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          ...playersByRole.entries.expand((entry) {
            return [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _getRoleDisplayName(entry.key),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ...entry.value.map((player) => PlayerCard(
                    player: player,
                    defaultImage: defaultImage,
                  )),
            ];
          }).toList(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement preview logic
                  },
                  child: const Text("Preview"),
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement save team logic
                  },
                  child: const Text("Save Team"),
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupAndSortPlayers(List<Map<String, dynamic>> players) {
    Map<String, List<Map<String, dynamic>>> playersByRole = {};
    for (var player in players) {
      String role = player['playing_role'] ?? 'Unknown';
      if (!playersByRole.containsKey(role)) {
        playersByRole[role] = [];
      }
      playersByRole[role]!.add(player);
    }

    const roleOrder = ['wk', 'bat', 'bowl', 'all'];
    Map<String, List<Map<String, dynamic>>> sortedPlayersByRole = {};
    for (var role in roleOrder) {
      if (playersByRole.containsKey(role)) {
        sortedPlayersByRole[role] = playersByRole[role]!;
      }
    }
    return sortedPlayersByRole;
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'wk':
        return 'Wicketkeepers';
      case 'bat':
        return 'Batsmen';
      case 'bowl':
        return 'Bowlers';
      case 'all':
        return 'All-Rounders';
      default:
        return 'Other';
    }
  }
}

class PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final ImageProvider defaultImage;

  PlayerCard({required this.player, required this.defaultImage});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensure the row items are spaced out
          children: [
            CircleAvatar(
              backgroundImage: player['image_url'] != null && player['image_url'].isNotEmpty
                  ? NetworkImage(player['image_url'])
                  : defaultImage,
              radius: 30,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(player['short_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(player['playing_role'] ?? ''),
                ],
              ),
            ),
            Text('0.0'),
            RoleButton(label: 'C'), // Size parameter removed
            RoleButton(label: 'VC'),
            RoleButton(label: 'DC'),
            RoleButton(label: 'AC'),
          ],
        ),
      ),
    );
  }
}

class RoleButton extends StatelessWidget {
  final String label;

  RoleButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Implement role assignment logic for C, VC, DC, AC
      },
      child: Text(label, style: TextStyle(fontSize: 12)), // Smaller font size
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
        onPrimary: Colors.white,
        shape: CircleBorder(),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Smaller padding
        minimumSize: Size(30, 30), // Minimum size of the button
      ),
    );
  }
}



class PlayerDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> player;

  PlayerDetailsScreen({required this.player});

  @override
  Widget build(BuildContext context) {
    final logoUrl = player['logo_url'] as String?;
    final defaultImage = AssetImage('assets/playerImage.png');
    final imageUrl = logoUrl ?? '';

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              player['short_name'] as String), // Ensure short_name is a String
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
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
                    SizedBox(width: 16),
                    Text(
                      player['title'] as String, // Ensure title is a String
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildPlayerDetailTile(
                          'Birthdate:', player['birthdate'].toString()),
                      _buildPlayerDetailTile(
                          'Batting Style:', player['batting_style']),
                      _buildPlayerDetailTile(
                          'Bowling Style:', player['bowling_style']),
                      _buildPlayerDetailTile(
                          'Fielding Position:', player['fielding_position']),
                      _buildPlayerDetailTile(
                          'Recent Match:', player['recent_match']),
                      _buildPlayerDetailTile(
                          'Recent Appearance:', player['recent_appearance']),
                      _buildPlayerDetailTile('Fantasy Player Rating:',
                          player['fantasy_player_rating'].toString()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerDetailTile(String label, dynamic value) {
    // Check if value is not null and is of type String
    final displayValue = (value != null && value is String) ? value : 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Text(displayValue),
        ],
      ),
    );
  }
}

class PreviewScreen extends StatelessWidget {
  final Set<Map<String, dynamic>> selectedPlayers;
  final AssetImage defaultImage = AssetImage('assets/playerImage.png');
  final double playgroundRadius = 180.0;
  final double angleIncrement = 2 * math.pi / 11;

  PreviewScreen({required this.selectedPlayers});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double screenWidth = mediaQueryData.size.width;
    final double screenHeight = mediaQueryData.size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Selected Players"),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/cricketGround.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          _buildPlayerGroup(
            selectedPlayers,
            'wk',
            screenWidth,
            screenHeight,
            angleIncrement,
          ),
          _buildPlayerGroup(
            selectedPlayers,
            'bat',
            screenWidth,
            screenHeight,
            angleIncrement,
          ),
          _buildPlayerGroup(
            selectedPlayers,
            'all',
            screenWidth,
            screenHeight,
            angleIncrement,
          ),
          _buildPlayerGroup(
            selectedPlayers,
            'bowl',
            screenWidth,
            screenHeight,
            angleIncrement,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerGroup(
    Set<Map<String, dynamic>> players,
    String playingRole,
    double screenWidth,
    double screenHeight,
    double angleIncrement,
  ) {
    List<Map<String, dynamic>> playersInGroup = players
        .where((player) =>
            (player['playing_role'] ?? '').toLowerCase() == playingRole)
        .toList();

    double radius =
        screenHeight < screenWidth ? screenHeight * 0.25 : screenWidth * 0.25;

    double top;

    switch (playingRole.toLowerCase()) {
      case 'wk':
        top = screenHeight * 0.25 - radius;
        break;
      case 'bat':
        top = screenHeight * 0.35 - radius;
        break;
      case 'bowl':
        top = screenHeight * 0.65 - radius;
        break;
      case 'all':
        top = screenHeight * 0.75 - radius;
        break;
      default:
        // Handle other playing roles if needed
        top = screenHeight * 0.5 - radius;
    }

    double totalWidth =
        playersInGroup.length * 40.0; // Adjust the width as needed

    double left = screenWidth * 0.44 - totalWidth / 2;

    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Text(
            getPlayingRoleTitle(
                playingRole), // Define getPlayingRoleTitle function
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < playersInGroup.length; i++)
                Row(
                  children: [
                    _buildPlayerMarker(
                      playersInGroup.elementAt(i),
                      i,
                      angleIncrement * i,
                      screenWidth,
                      screenHeight,
                    ),
                    SizedBox(width: 8.0), // Adjust the spacing between players
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }





  String getPlayingRoleTitle(String playingRole) {
    switch (playingRole.toLowerCase()) {
      case 'wk':
        return 'Wicket Keepers';
      case 'bat':
        return 'Batsman';
      case 'bowl':
        return 'Bowlers';
      case 'all':
        return 'All-rounders';
      default:
        return 'Other Players';
    }
  }

  Widget _buildPlayerMarker(
    Map<String, dynamic> player,
    int index,
    double angle,
    double screenWidth,
    double screenHeight,
  ) {
    double radius =
        screenHeight < screenWidth ? screenHeight * 0.4 : screenWidth * 0.4;
    double top = radius * math.sin(angle) + screenHeight * 0.5;
    double left = radius * math.cos(angle) + screenWidth * 0.5;

    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Image.network(
            player['logo_url'] ?? '',
            height: 30,
            width: 30,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
              return Image(image: defaultImage, height: 30, width: 30);
            },
          ),
          SizedBox(height: 4),
          Text(player['short_name'] ?? ''),
        ],
      ),
    );
  }
}