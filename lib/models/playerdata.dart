class PlayerData {
  String? status;
  Response? response;
  String? etag;
  String? modified;
  String? datetime;
  String? apiVersion;

  PlayerData(
      {this.status,
      this.response,
      this.etag,
      this.modified,
      this.datetime,
      this.apiVersion});

  PlayerData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    response = json['response'] != null
        ? new Response.fromJson(json['response'])
        : null;
    etag = json['etag'];
    modified = json['modified'];
    datetime = json['datetime'];
    apiVersion = json['api_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.response != null) {
      data['response'] = this.response!.toJson();
    }
    data['etag'] = this.etag;
    data['modified'] = this.modified;
    data['datetime'] = this.datetime;
    data['api_version'] = this.apiVersion;
    return data;
  }
}

class Response {
  String? squadType;
  List<Squads>? squads;

  Response({this.squadType, this.squads});

  Response.fromJson(Map<String, dynamic> json) {
    squadType = json['squad_type'];
    if (json['squads'] != null) {
      squads = <Squads>[];
      json['squads'].forEach((v) {
        squads!.add(new Squads.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['squad_type'] = this.squadType;
    if (this.squads != null) {
      data['squads'] = this.squads!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Squads {
  String? teamId;
  String? title;
  Team? team;
  List<Players>? players;
  List<LastMatchPlayed>? lastMatchPlayed;

  Squads(
      {this.teamId, this.title, this.team, this.players, this.lastMatchPlayed});

  Squads.fromJson(Map<String, dynamic> json) {
    teamId = json['team_id'];
    title = json['title'];
    team = json['team'] != null ? new Team.fromJson(json['team']) : null;
    if (json['players'] != null) {
      players = <Players>[];
      json['players'].forEach((v) {
        players!.add(new Players.fromJson(v));
      });
    }
    if (json['last_match_played'] != null) {
      lastMatchPlayed = <LastMatchPlayed>[];
      json['last_match_played'].forEach((v) {
        lastMatchPlayed!.add(new LastMatchPlayed.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['team_id'] = this.teamId;
    data['title'] = this.title;
    if (this.team != null) {
      data['team'] = this.team!.toJson();
    }
    if (this.players != null) {
      data['players'] = this.players!.map((v) => v.toJson()).toList();
    }
    if (this.lastMatchPlayed != null) {
      data['last_match_played'] =
          this.lastMatchPlayed!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Team {
  int? tid;
  String? title;
  String? abbr;
  String? altName;
  String? type;
  String? thumbUrl;
  String? logoUrl;
  String? country;
  String? sex;

  Team(
      {this.tid,
      this.title,
      this.abbr,
      this.altName,
      this.type,
      this.thumbUrl,
      this.logoUrl,
      this.country,
      this.sex});

  Team.fromJson(Map<String, dynamic> json) {
    tid = json['tid'];
    title = json['title'];
    abbr = json['abbr'];
    altName = json['alt_name'];
    type = json['type'];
    thumbUrl = json['thumb_url'];
    logoUrl = json['logo_url'];
    country = json['country'];
    sex = json['sex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tid'] = this.tid;
    data['title'] = this.title;
    data['abbr'] = this.abbr;
    data['alt_name'] = this.altName;
    data['type'] = this.type;
    data['thumb_url'] = this.thumbUrl;
    data['logo_url'] = this.logoUrl;
    data['country'] = this.country;
    data['sex'] = this.sex;
    return data;
  }
}

class Players {
  int? pid;
  String? title;
  String? shortName;
  String? firstName;
  String? lastName;
  String? middleName;
  String? birthdate;
  String? birthplace;
  String? country;
  List<Null>? primaryTeam;
  String? logoUrl;
  String? playingRole;
  String? battingStyle;
  String? bowlingStyle;
  String? fieldingPosition;
  int? recentMatch;
  int? recentAppearance;
  double? fantasyPlayerRating;
  String? altName;
  String? facebookProfile;
  String? twitterProfile;
  String? instagramProfile;
  String? debutData;
  String? thumbUrl;
  String? nationality;

  Players(
      {this.pid,
      this.title,
      this.shortName,
      this.firstName,
      this.lastName,
      this.middleName,
      this.birthdate,
      this.birthplace,
      this.country,
      this.primaryTeam,
      this.logoUrl,
      this.playingRole,
      this.battingStyle,
      this.bowlingStyle,
      this.fieldingPosition,
      this.recentMatch,
      this.recentAppearance,
      this.fantasyPlayerRating,
      this.altName,
      this.facebookProfile,
      this.twitterProfile,
      this.instagramProfile,
      this.debutData,
      this.thumbUrl,
      this.nationality});

  Players.fromJson(Map<String, dynamic> json) {
    pid = json['pid'];
    title = json['title'];
    shortName = json['short_name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    middleName = json['middle_name'];
    birthdate = json['birthdate'];
    birthplace = json['birthplace'];
    country = json['country'];
    // if (json['primary_team'] != null) {
    //   primaryTeam = <Null>[];
    //   json['primary_team'].forEach((v) {
    //     primaryTeam!.add(new Null.fromJson(v));
    //   });
    // }
    logoUrl = json['logo_url'];
    playingRole = json['playing_role'];
    battingStyle = json['batting_style'];
    bowlingStyle = json['bowling_style'];
    fieldingPosition = json['fielding_position'];
    recentMatch = json['recent_match'];
    recentAppearance = json['recent_appearance'];
    fantasyPlayerRating = json['fantasy_player_rating'];
    altName = json['alt_name'];
    facebookProfile = json['facebook_profile'];
    twitterProfile = json['twitter_profile'];
    instagramProfile = json['instagram_profile'];
    debutData = json['debut_data'];
    thumbUrl = json['thumb_url'];
    nationality = json['nationality'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pid'] = this.pid;
    data['title'] = this.title;
    data['short_name'] = this.shortName;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['middle_name'] = this.middleName;
    data['birthdate'] = this.birthdate;
    data['birthplace'] = this.birthplace;
    data['country'] = this.country;
    // if (this.primaryTeam != null) {
    //   data['primary_team'] = this.primaryTeam!.map((v) => v.toJson()).toList();
    // }
    data['logo_url'] = this.logoUrl;
    data['playing_role'] = this.playingRole;
    data['batting_style'] = this.battingStyle;
    data['bowling_style'] = this.bowlingStyle;
    data['fielding_position'] = this.fieldingPosition;
    data['recent_match'] = this.recentMatch;
    data['recent_appearance'] = this.recentAppearance;
    data['fantasy_player_rating'] = this.fantasyPlayerRating;
    data['alt_name'] = this.altName;
    data['facebook_profile'] = this.facebookProfile;
    data['twitter_profile'] = this.twitterProfile;
    data['instagram_profile'] = this.instagramProfile;
    data['debut_data'] = this.debutData;
    data['thumb_url'] = this.thumbUrl;
    data['nationality'] = this.nationality;
    return data;
  }
}

class LastMatchPlayed {
  String? playerId;
  String? title;

  LastMatchPlayed({this.playerId, this.title});

  LastMatchPlayed.fromJson(Map<String, dynamic> json) {
    playerId = json['player_id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['player_id'] = this.playerId;
    data['title'] = this.title;
    return data;
  }
}
