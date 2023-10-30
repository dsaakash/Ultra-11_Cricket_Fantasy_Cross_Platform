import 'dart:async';
import 'dart:convert';
import 'package:tempalteflutter/models/DrawerInfoResponceData.dart';
import 'package:tempalteflutter/models/appVersionResponce.dart';
import 'package:tempalteflutter/models/bankListResponseData.dart';
import 'package:tempalteflutter/models/bankinfoResponce.dart';
import 'package:tempalteflutter/models/contestsResponseData.dart';
import 'package:tempalteflutter/models/notification.dart';
import 'package:tempalteflutter/models/panCardResponse.dart';
import 'package:tempalteflutter/models/scheduleResponseData.dart';
import 'package:tempalteflutter/models/squadsResponseData.dart';
import 'package:tempalteflutter/models/teamResponseData.dart';
import 'package:tempalteflutter/models/transactionResponse.dart';

class ApiProvider {
  Future<ScheduleResponseData> postScheduleList() async {
    return ScheduleResponseData.fromJson(jsonDecode(
        '{"success":1,"message":" Data Get successfully","shedual_data":[{"match_id":38529,"match":"India vs South Africa","pre_squad":"true","competition_id":111320,"series_name":"ICC Cricket World Cup","date_start":"2019-09-05","time_start":"15:00:00","lineups_out":"true","team_logo":{"a":{"team_id":25,"color_code":"","name":"India","short_name":"IND","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/25.png"},"b":{"team_id":19,"color_code":null,"name":"South Africa","short_name":"SA","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/19.png"}}},{"match_id":38535,"match":"Australia vs India","pre_squad":"true","competition_id":111320,"series_name":"ICC Cricket World Cup","date_start":"2019-09-09","time_start":"15:00:00","lineups_out":"true","team_logo":{"a":{"team_id":5,"color_code":null,"name":"Australia","short_name":"AUS","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/5.png"},"b":{"team_id":25,"color_code":"","name":"India","short_name":"IND","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/25.png"}}},{"match_id":38544,"match":"Bangladesh vs West Indies","pre_squad":"true","competition_id":111320,"series_name":"ICC Cricket World Cup","date_start":"2019-09-17","time_start":"15:00:00","lineups_out":"true","team_logo":{"a":{"team_id":23,"color_code":null,"name":"Bangladesh","short_name":"BAN","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/23.png"},"b":{"team_id":17,"color_code":null,"name":"West Indies","short_name":"WI","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/17.png"}}},{"match_id":38529,"match":"India vs South Africa","pre_squad":"true","competition_id":111320,"series_name":"ICC Cricket World Cup","date_start":"2019-09-05","time_start":"15:00:00","lineups_out":"true","team_logo":{"a":{"team_id":25,"color_code":"","name":"India","short_name":"IND","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/25.png"},"b":{"team_id":19,"color_code":null,"name":"South Africa","short_name":"SA","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/19.png"}}},{"match_id":38529,"match":"India vs South Africa","pre_squad":"true","competition_id":111320,"series_name":"ICC Cricket World Cup","date_start":"2019-09-05","time_start":"15:00:00","lineups_out":"true","team_logo":{"a":{"team_id":25,"color_code":"","name":"India","short_name":"IND","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/25.png"},"b":{"team_id":19,"color_code":null,"name":"South Africa","short_name":"SA","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/19.png"}}},{"match_id":38529,"match":"India vs South Africa","pre_squad":"true","competition_id":111320,"series_name":"ICC Cricket World Cup","date_start":"2019-09-05","time_start":"15:00:00","lineups_out":"true","team_logo":{"a":{"team_id":25,"color_code":"","name":"India","short_name":"IND","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/25.png"},"b":{"team_id":19,"color_code":null,"name":"South Africa","short_name":"SA","logo_url":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/team\/19.png"}}}]}'));
  }

  Future<ContestsLeagueResponseData> postContestList() async {
    var resData = ContestsLeagueResponseData();
    var contestsLeagueCategoryListResponseData = <ContestsLeagueCategoryListResponseData>[];
    try {
      resData.teamlist = <String>[];

      dynamic responseData = new JsonDecoder().convert(
          '{"leagues":{ "Head-to-Head": [{"league_id":"855","league_key":"067fc4176ab7","league_name":null,"entry_fees":"575","total_team":"2","remaining_team":"0","total_winer":"1","match_key":"38529","main_league_id":"31","created_time":"2019-06-27 11:24:32","updated_time":"2019-08-02 01:17:04","is_delete":"0","is_active":"1","is_full":"1","is_refund":"0","is_result":"0","team_player":"11","CategoryId":"1","total_wining_amount":"1000","is_private":"0","prize_pool":"","league_winer":[{"league_winer_id":"300332","league_id":"31","postion":"1","price":"1000.00"}],"league_member":null}]}}');
      if (responseData['categorylist'] != null && responseData['categorylist'] != '' && responseData['leagues'] != null) {
        if (responseData['teamlist'] != null && responseData['teamlist'] != '') {
          var tlist = <String>[];
          tlist = responseData['teamlist'].split(',');
          if (tlist.length > 0) {
            resData.teamlist = tlist;
          } else {
            resData.teamlist = [];
          }
        } else {
          resData.teamlist = [];
        }
        if (responseData['totalcontest'] != null && responseData['totalcontest'] != '') {
          resData.totalcontest = int.tryParse('${responseData['totalcontest'] ?? 0}')!;
        } else {
          resData.totalcontest = 0;
        }
        var categoryTxt = responseData['categorylist'] as String;
        var descriptionTxt = responseData['descriptionlist'] as String;
        var categorylistTxtList = categoryTxt.split(',');
        var descriptionlistTxtList = descriptionTxt.split(',');
        var count = -1;
        categorylistTxtList.forEach((categorytext) {
          count += 1;
          for (var key in responseData['leagues'].keys) {
            if (key == categorytext) {
              var contestsLeagueCategoryList = ContestsLeagueCategoryListResponseData();
              final List<dynamic> dataList = responseData['leagues'][categorytext];
              print(dataList);
              var contestsLeagueListData = <ContestsLeagueListData>[];
              dataList.forEach((data) {
                var leagueData = ContestsLeagueListData.fromJson(data);
                var leagueWiner = <LeagueWiner>[];
                leagueData.leagueWiner!.forEach((leagueWinerData) {
                  if (leagueWinerData.leagueId == leagueData.mainLeagueId) {
                    leagueWiner.add(leagueWinerData);
                  }
                });
                leagueData.leagueWiner = leagueWiner;
                if (leagueData.isFull == '1') {
                  contestsLeagueListData.add(leagueData);
                } else {
                  contestsLeagueListData.add(leagueData);
                }
              });
              print(contestsLeagueListData.length);
              if (contestsLeagueListData.length > 0) {
                contestsLeagueCategoryList.categoryName = categorytext;
                contestsLeagueCategoryList.categoryDescription = descriptionlistTxtList[count];
                contestsLeagueCategoryList.contestsCategoryLeagueListData = contestsLeagueListData;
                contestsLeagueCategoryListResponseData.add(contestsLeagueCategoryList);
              }
            }
          }
        });
        resData.contestsCategoryLeagueListData = contestsLeagueCategoryListResponseData;
      }
    } catch (e) {
      print(e);
    }
    return resData;
  }

  Future<SquadsResponseData> getTeamData() async {
    SquadsResponseData responseData;

    responseData = SquadsResponseData.fromJson(jsonDecode(

      '{"success":1,"message":"Player data get successfully.","player_list":[{"pid":159,"title":"title","short_name":"shortname","first_name":"Quinton","last_name":"Kock","middle_name":"de","birthdate":"1992-12-17","birthplace":"","country":"za","playing_role":"wk","batting_style":"LHB","bowling_style":"","fielding_position":"","team_name":"SA","fantasy_player_rating":10,"nationality":"South Africa","team_id":19,"playing11":"true"}]}'));
    // #    '{"success":1,"message":"Player data get successfully.","player_list":[{"pid":159,"title":"Quinton de Kock","short_name":"Q de Kock","first_name":"Quinton","last_name":"Kock","middle_name":"de","birthdate":"1992-12-17","birthplace":"","country":"za","playing_role":"wk","batting_style":"LHB","bowling_style":"","fielding_position":"","team_name":"SA","fantasy_player_rating":10,"nationality":"South Africa","team_id":19,"playing11":"true"},{"pid":161,"title":"Hashim Amla","short_name":"HM Amla","first_name":"Hashim","last_name":"Amla","middle_name":"Mahomed","birthdate":"1983-03-31","birthplace":"","country":"za","playing_role":"bat","batting_style":"Right-hand bat","bowling_style":"Right-arm offbreak","fielding_position":"","team_name":"SA","fantasy_player_rating":9,"nationality":"South Africa","team_id":19,"playing11":"true"},{"pid":163,"title":"Faf du Plessis","short_name":"F du Plessis","first_name":"Francois","last_name":"Plessis","middle_name":"du","birthdate":"1984-07-13","birthplace":"","country":"za","playing_role":"bat","batting_style":"Right-hand bat","bowling_style":"Legbreak","fielding_position":"","team_name":"SA","fantasy_player_rating":10,"nationality":"South Africa","team_id":19,"playing11":"true"},{"pid":167,"title":"David Miller","short_name":"DA Miller","first_name":"David","last_name":"Miller","middle_name":"Andrew","birthdate":"1989-06-10","birthplace":"","country":"za","playing_role":"bat","batting_style":"LHB","bowling_style":"Right-arm offbreak","fielding_position":"","team_name":"SA","fantasy_player_rating":8,"nationality":"South Africa","team_id":19,"playing11":"true"},{"pid":169,"title":"Jean-Paul","short_name":"JP","first_name":"Jean-Paul","last_name":"Duminy","middle_name":"","birthdate":"1984-04-14","birthplace":"","country":"za","playing_role":"all","batting_style":"LHB","bowling_style":"Right-arm offbreak","fielding_position":"","team_name":"SA","fantasy_player_rating":8,"nationality":"South Africa","team_id":19,"playing11":"true"},{"pid":175,"title":"Dale Steyn","short_name":"DW Steyn","first_name":"Dale","last_name":"Steyn","middle_name":"Willem","birthdate":"1983-06-27","birthplace":"","country":"za","playing_role":"bowl","batting_style":"Right-hand bat","bowling_style":"Right-arm fast","fielding_position":"","team_name":"SA","fantasy_player_rating":8,"nationality":"South Africa","team_id":19,"playing11":"false"},{"pid":177,"title":"Imran Tahir","short_name":"Imran Tahir","first_name":"Mohammad","last_name":"Tahir","middle_name":"Imran","birthdate":"1979-03-27","birthplace":"","country":"za","playing_role":"bowl","batting_style":"Right-hand bat","bowling_style":"Legbreak googly","fielding_position":"","team_name":"SA","fantasy_player_rating":9,"nationality":"South Africa","team_id":19,"playing11":"true"},{"pid":1953,"title":"Kagiso Rabada","short_name":"K Rabada","first_name":"Kagiso","last_name":"Rabada","middle_name":"","birthdate":"1995-05-25","birthplace":"","country":"za","playing_role":"bowl","batting_style":"LHB","bowling_style":"Right-arm fast","fielding_position":"","team_name":"SA","fantasy_player_rating":9,"nationality":"South Africa","team_id":19,"playing11":"true"},{"pid":46117,"title":"Aiden Markram","short_name":"AK Markram","first_name":"Aiden","last_name":"Markram","middle_name":"Kyle","birthdate":"1994-10-04","birthplace":"","country":"za","playing_role":"bat","batting_style":"Right-hand bat","bowling_style":"Right-arm offbreak","fielding_position":"","team_name":"SA","fantasy_player_rating":8,"nationality":"South Africa","team_id":19,"playing11":"false"},{"pid":46126,"title":"Tabraiz Shamsi","short_name":"T Shamsi","first_name":"Tabraiz","last_name":"Shamsi","middle_name":"","birthdate":"1990-02-18","birthplace":"","country":"za","playing_role":"bowl","batting_style":"Right-hand bat","bowling_style":"Slow left-arm chinaman","fielding_position":"","team_name":"SA","fantasy_player_rating":8,"nationality":"South Africa","team_id":19,"playing11":"true"},{"pid":46131,"title":"Lungi Ngidi","short_name":"L Ngidi","first_name":"Lungisani","last_name":"Ngidi","middle_name":"","birthdate":"1996-03-29","birthplace":"","country":"za","playing_role":"bowl","batting_style":"Right-hand bat","bowling_style":"Right-arm fast","fielding_position":"","team_name":"SA","fantasy_player_rating":8,"nationality":"South Africa","team_id":19,"playing11":"false"},{"pid":46135,"title":"Rassie van der","short_name":"HE van der Dussen","first_name":"Hendrik","last_name":"Dussen","middle_name":"Erasmus van der","birthdate":"1989-02-07","birthplace":"","country":"za","playing_role":"bat","batting_style":"Right-hand bat","bowling_style":"Legbreak","fielding_position":"","team_name":"SA","fantasy_player_rating":8,"nationality":"South Africa","team_id":19,"playing11":"true"},{"pid":52988,"title":"Dwaine Pretorius","short_name":"D Pretorius","first_name":"Dwaine","last_name":"Pretorius","middle_name":"","birthdate":"1989-03-29","birthplace":"","country":"za","playing_role":"all","batting_style":"Right-hand bat","bowling_style":"Right-arm medium-fast","fielding_position":"","team_name":"SA","fantasy_player_rating":8,"nationality":"South Africa","team_id":19,"playing11":"false"},{"pid":53000,"title":"Andile","short_name":"AL Phehlukwayo","first_name":"Andile","last_name":"Phehlukwayo","middle_name":"Lucky","birthdate":"1996-03-03","birthplace":"","country":"za","playing_role":"all","batting_style":"LHB","bowling_style":"Right-arm fast-medium","fielding_position":"","team_name":"SA","fantasy_player_rating":8,"nationality":"South Africa","team_id":19,"playing11":"true"},{"pid":642,"title":"Chris Morris","short_name":"CH Morris","first_name":"Christopher","last_name":"Morris","middle_name":"Henry","birthdate":"1987-04-30","birthplace":"","country":"za","playing_role":"all","batting_style":"Right-hand bat","bowling_style":"Right-arm fast-medium","fielding_position":"","team_name":"SA","fantasy_player_rating":8,"nationality":"South Africa","team_id":19,"playing11":"true"},{"pid":115,"title":"Rohit Sharma","short_name":"RG Sharma","first_name":"Rohit","last_name":"Sharma","middle_name":"Gurunath","birthdate":"1987-04-30","birthplace":"","country":"in","playing_role":"bat","batting_style":"Right-hand bat","bowling_style":"Right-arm offbreak","fielding_position":"","team_name":"IND","fantasy_player_rating":10,"nationality":"India","team_id":25,"playing11":"true"},{"pid":117,"title":"Shikhar Dhawan","short_name":"S Dhawan","first_name":"Shikhar","last_name":"Dhawan","middle_name":"","birthdate":"1985-12-05","birthplace":"","country":"in","playing_role":"bat","batting_style":"LHB","bowling_style":"Right-arm offbreak","fielding_position":"","team_name":"IND","fantasy_player_rating":9,"nationality":"India","team_id":25,"playing11":"true"},{"pid":119,"title":"Virat Kohli","short_name":"V Kohli","first_name":"Virat","last_name":"Kohli","middle_name":"","birthdate":"1988-11-05","birthplace":"","country":"in","playing_role":"bat","batting_style":"Right-hand bat","bowling_style":"Right-arm medium","fielding_position":"","team_name":"IND","fantasy_player_rating":10,"nationality":"India","team_id":25,"playing11":"true"},{"pid":123,"title":"MS Dhoni","short_name":"MS Dhoni","first_name":"Mahendra","last_name":"Dhoni","middle_name":"Singh","birthdate":"1981-07-07","birthplace":"","country":"in","playing_role":"wk","batting_style":"Right-hand bat","bowling_style":"Right-arm medium","fielding_position":"","team_name":"IND","fantasy_player_rating":8,"nationality":"India","team_id":25,"playing11":"true"},{"pid":125,"title":"Ravindra Jadeja","short_name":"RA Jadeja","first_name":"Ravindrasinh","last_name":"Jadeja","middle_name":"Anirudhsinh","birthdate":"1988-12-06","birthplace":"","country":"in","playing_role":"all","batting_style":"LHB","bowling_style":"Slow left-arm orthodox","fielding_position":"","team_name":"IND","fantasy_player_rating":8,"nationality":"India","team_id":25,"playing11":"false"},{"pid":131,"title":"Shami","short_name":"M Shami","first_name":"Mohammed","last_name":"Ahmed","middle_name":"Shami","birthdate":"1990-09-03","birthplace":"","country":"in","playing_role":"bowl","batting_style":"Right-hand bat","bowling_style":"Right-arm fast-medium","fielding_position":"","team_name":"IND","fantasy_player_rating":8,"nationality":"India","team_id":25,"playing11":"false"},{"pid":434,"title":"Bhuvneshwar","short_name":"B Kumar","first_name":"Bhuvneshwar","last_name":"Singh","middle_name":"Kumar","birthdate":"1990-02-05","birthplace":"","country":"in","playing_role":"bowl","batting_style":"Right-hand bat","bowling_style":"Right-arm medium","fielding_position":"","team_name":"IND","fantasy_player_rating":8,"nationality":"India","team_id":25,"playing11":"true"},{"pid":607,"title":"Jasprit Bumrah","short_name":"JJ Bumrah","first_name":"Jasprit","last_name":"Bumrah","middle_name":"Jasbirsingh","birthdate":"1993-12-06","birthplace":"","country":"in","playing_role":"bowl","batting_style":"Right-hand bat","bowling_style":"Right-arm fast-medium","fielding_position":"","team_name":"IND","fantasy_player_rating":9,"nationality":"India","team_id":25,"playing11":"true"},{"pid":621,"title":"Kedar Jadhav","short_name":"KM Jadhav","first_name":"Kedar","last_name":"Jadhav","middle_name":"Mahadav","birthdate":"1985-03-26","birthplace":"","country":"in","playing_role":"all","batting_style":"Right-hand bat","bowling_style":"Right-arm offbreak","fielding_position":"","team_name":"IND","fantasy_player_rating":8,"nationality":"India","team_id":25,"playing11":"true"},{"pid":649,"title":"Dinesh Karthik","short_name":"KD Karthik","first_name":"Krishnakumar","last_name":"Karthik","middle_name":"Dinesh","birthdate":"1985-06-01","birthplace":"","country":"in","playing_role":"wk","batting_style":"Right-hand bat","bowling_style":"","fielding_position":"","team_name":"IND","fantasy_player_rating":8,"nationality":"India","team_id":25,"playing11":"false"},{"pid":654,"title":"Yuzvendra","short_name":"YS Chahal","first_name":"Yuzvendra","last_name":"Chahal","middle_name":"Singh","birthdate":"1990-07-23","birthplace":"","country":"in","playing_role":"bowl","batting_style":"Right-hand bat","bowling_style":"Legbreak googly","fielding_position":"","team_name":"IND","fantasy_player_rating":8,"nationality":"India","team_id":25,"playing11":"true"},{"pid":661,"title":"Lokesh Rahul","short_name":"KL Rahul","first_name":"Kannaur","last_name":"Rahul","middle_name":"Lokesh","birthdate":"1992-04-18","birthplace":"","country":"in","playing_role":"bat","batting_style":"Right-hand bat","bowling_style":"","fielding_position":"","team_name":"IND","fantasy_player_rating":8,"nationality":"India","team_id":25,"playing11":"true"},{"pid":727,"title":"Hardik Pandya","short_name":"HH Pandya","first_name":"Hardik","last_name":"Pandya","middle_name":"Himanshu","birthdate":"1993-10-11","birthplace":"","country":"in","playing_role":"all","batting_style":"Right-hand bat","bowling_style":"Right-arm medium-fast","fielding_position":"","team_name":"IND","fantasy_player_rating":9,"nationality":"India","team_id":25,"playing11":"true"},{"pid":775,"title":"Kuldeep Yadav","short_name":"KL Yadav","first_name":"Kuldeep","last_name":"Yadav","middle_name":"","birthdate":"1994-12-14","birthplace":"","country":"in","playing_role":"bowl","batting_style":"LHB","bowling_style":"Slow left-arm chinaman","fielding_position":"","team_name":"IND","fantasy_player_rating":8,"nationality":"India","team_id":25,"playing11":"true"},{"pid":49682,"title":"Vijay Shankar","short_name":"V Shankar","first_name":"Vijay","last_name":"Shankar","middle_name":"","birthdate":"1991-01-26","birthplace":"","country":"in","playing_role":"bat","batting_style":"Right-hand bat","bowling_style":"Right-arm medium","fielding_position":"","team_name":"IND","fantasy_player_rating":8,"nationality":"India","team_id":25,"playing11":"false"},{"pid":855,"title":"Beuran Hendricks","short_name":"BE Hendricks","first_name":"Beuran","last_name":"Hendricks","middle_name":"Eric","birthdate":"1990-06-08","birthplace":"","country":"za","playing_role":"bowl","batting_style":"LHB","bowling_style":"Left-arm fast-medium","fielding_position":"","team_name":"SA","fantasy_player_rating":8,"nationality":"South Africa","team_id":19,"playing11":"false"}]}'));
    // print(responseData);
    print(responseData);

    return responseData;
  }
  


  

//   Future<SquadsResponseData> getTeamData() async {
//   try {
//     // Create a Dio instance for more flexibility
//     final dio = Dio();

//     // Define the API URL
//     final apiUrl =
//         'https://rest.entitysport.com/v2/competitions/128307/squads/70577?token=4c5b78057cd282704f2a9dd8ea556ee2';

//     // Make the GET request
//     final response = await dio.get(apiUrl);

//     if (response.statusCode == 200) {
//       // Parse the JSON response
//       final jsonResponse = jsonDecode(response.data);
//       final responseData = SquadsResponseData.fromJson(jsonResponse);
//       print(responseData);

//       return responseData;
//     } else {
//       throw Exception('Failed to load team data');
//     }
//   } catch (error) {
//     throw error;
//   }
// }

  Future<GetTeamResponseData> getCreatedTeamList(String matchId) async {
    GetTeamResponseData responseData = GetTeamResponseData.fromJson(jsonDecode(
        '{"team_data":[{"team_id":"171","team_name":"Oliver Smith (T1)","captun":"S Dhawan","wise_captun":"DA Miller","wicket_keeper":"KD Karthik","bowler":"K Rabada,L Ngidi,M Shami","bastman":"V Kohli,F du Plessis,RG Sharma,S Dhawan,DA Miller","all_rounder":"CH Morris,D Pretorius","user_id":"5","created_time":"2019-06-04 09:01:29","updated_time":"0000-00-00 00:00:00","is_delete":"0","match_key":"38529","competition_id":"111320"},{"team_id":"293","team_name":"Parth (T2)","captun":"Andile","wise_captun":"Faf du Plessis","wicket_keeper":"Quinton de Kock","bowler":"Imran Tahir,Jasprit Bumrah,Tabraiz Shamsi","bastman":"Faf du Plessis,Rohit Sharma,Virat Kohli,Hashim Amla","all_rounder":"Hardik Pandya,Jean-Paul,Andile Phehl","user_id":"5","created_time":"2019-08-02 01:17:00","updated_time":"0000-00-00 00:00:00","is_delete":"0","match_key":"38529","competition_id":"111320"}],"success":1,"message":"Team data get successfully"}'));
    return responseData;
  }

  Future<UserDetail> drawerInfoList() async {
    return UserDetail.fromJson(jsonDecode(
        '{"success":"1","message":"data get successfully","data":{"balance":"736.00","deposit":"1810","cash_bonus":"0.00","wining_amount":"0.00","image":"https://www.menshairstylesnow.com/wp-content/uploads/2018/03/Hairstyles-for-Square-Faces-Slicked-Back-Undercut.jpg","email":"oliver@123@gmail.com","name":"Oliver","mobile_number":"9874563201","city":"NewYork"}}'));
  }

  Future<PanCardResponse> getPanCardResponce() async {
    return PanCardResponse.fromJson(jsonDecode(
        '{"success":"1","message":"Your Pan Card Verification Has been Approved","pancard_detail":[{"pancard_no":"11111111111111","pancard_name":"hhhhhhhhhhhhhhhhhhh","dob":"30\/05\/1990","reason":null,"pancard_photo":"http:\/\/starsportsfantasy.com\/Fantasy\/image\/user\/8308902536cfa4010e539d46185d703b.png"}]}'));
  }

  Future<BankinfoResponce> getEmailResponce() async {
    return BankinfoResponce.fromJson(jsonDecode('{"success":"1","message":"Your E-mail and Mobile Number are Verified."}'));
  }

  UserDetail getProfile() {
    return UserDetail.fromJson(jsonDecode(
        '{"success":"1","message":"data get successfully","data":{"referral_code":"KOM5AO","balance":"736.00","name":"Oliver","user_id":"7","email":"oliver123@gmail.com","mobile_number":"9856320147","cash_bonus":"0.00","is_veryfy":"1","dob":"08\/01\/2000","gender":"male","address":"","city":"NewYork","state":"NewYork","country":"US","pincode":"","image":"https://www.menshairstylesnow.com/wp-content/uploads/2018/03/Hairstyles-for-Square-Faces-Slicked-Back-Undercut.jpg","total_league":"88","total_matches":"43","total_series":"4","total_wins":"7"}}'));
  }

  Future<TransactionResponseData> getTransaction() async {
    return TransactionResponseData.fromJson(jsonDecode(
        '{"transaction":[{"transaction_id":"JV2227238657","type":"RECEIVE","remark":"Refunded","amount":"50","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"02\/07\/2019,03:07:31 PM"},{"transaction_id":"LK7422967453","type":"RECEIVE","remark":"Refunded","amount":"50","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"02\/07\/2019,03:07:28 PM"},{"transaction_id":"NC6397203818","type":"RECEIVE","remark":"Refunded","amount":"50","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"02\/07\/2019,03:07:16 PM"},{"transaction_id":"DJ4089764635","type":"RECEIVE","remark":"Refunded","amount":"50","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"02\/07\/2019,03:07:13 PM"},{"transaction_id":"QF7825656809","type":"RECEIVE","remark":"Refunded","amount":"50","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"02\/07\/2019,03:07:11 PM"},{"transaction_id":"LS6626266857","type":"RECEIVE","remark":"Refunded","amount":"50","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"02\/07\/2019,03:07:08 PM"},{"transaction_id":"AV7929975428","type":"RECEIVE","remark":"Refunded","amount":"50","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"02\/07\/2019,03:07:05 PM"},{"transaction_id":"ME7243183828","type":"PAID","remark":"Joined A Contest","amount":"58","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"30\/06\/2019,05:06:07 PM"},{"transaction_id":"GH7776615560","type":"PAID","remark":"Joined A Contest","amount":"58","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"30\/06\/2019,05:06:45 PM"},{"transaction_id":"GV9034855571","type":"PAID","remark":"Joined A Contest","amount":"900","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"30\/06\/2019,05:06:41 PM"},{"transaction_id":"XB4579439819","type":"RECEIVE","remark":"Refunded","amount":"115","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"25\/06\/2019,11:06:09 PM"},{"transaction_id":"KP3737241435","type":"RECEIVE","remark":"Refunded","amount":"115","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"25\/06\/2019,11:06:07 PM"},{"transaction_id":"DE3438815574","type":"PAID","remark":"Joined A Contest","amount":"115","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"24\/06\/2019,06:06:23 PM"},{"transaction_id":"KU7097728450","type":"PAID","remark":"Joined A Contest","amount":"115","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"24\/06\/2019,06:06:23 PM"},{"transaction_id":"SQ7412448123","type":"PAID","remark":"Joined A Contest","amount":"88","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"24\/06\/2019,06:06:44 PM"},{"transaction_id":"GE5010940081","type":"RECEIVE","remark":"Win A Contest","amount":"35","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"23\/06\/2019,11:06:06 PM"},{"transaction_id":"PW3075374052","type":"RECEIVE","remark":"Refunded","amount":"21","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"23\/06\/2019,03:06:03 PM"},{"transaction_id":"SY9332197090","type":"RECEIVE","remark":"Win A Contest","amount":"25","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"23\/06\/2019,02:06:05 AM"},{"transaction_id":"HE1707798552","type":"RECEIVE","remark":"Win A Contest","amount":"25","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,11:06:05 PM"},{"transaction_id":"NL1169956564","type":"RECEIVE","remark":"Win A Contest","amount":"25","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,11:06:05 PM"},{"transaction_id":"RX7870873782","type":"PAID","remark":"Joined A Contest","amount":"88","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,08:06:50 PM"},{"transaction_id":"ZN5980315464","type":"PAID","remark":"Joined A Contest","amount":"21","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,08:06:39 PM"},{"transaction_id":"OI9135622572","type":"PAID","remark":"Joined A Contest","amount":"21","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,08:06:19 PM"},{"transaction_id":"CS7385776626","type":"PAID","remark":"Joined A Contest","amount":"21","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,08:06:25 PM"},{"transaction_id":"BC9288073590","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"10","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,05:06:11 PM"},{"transaction_id":"IQ5032634479","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"500","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:03 PM"},{"transaction_id":"JV3740165185","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"1000","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:21 PM"},{"transaction_id":"XP5941316455","type":"PAID","remark":"Joined A Contest","amount":"15","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:33 PM"},{"transaction_id":"FT4331464135","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"15","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:58 PM"},{"transaction_id":"WJ2811948010","type":"PAID","remark":"Joined A Contest","amount":"15","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:47 PM"},{"transaction_id":"NB9709966364","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"14","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:22 PM"},{"transaction_id":"OM5198450652","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"1","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:55 PM"},{"transaction_id":"HB7414986608","type":"PAID","remark":"Joined A Contest","amount":"15","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:29 PM"},{"transaction_id":"UR3032993520","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"15","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:26 PM"},{"transaction_id":"AJ3667587296","type":"PAID","remark":"Joined A Contest","amount":"15","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:08 PM"},{"transaction_id":"KG8216533423","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"15","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:00 PM"},{"transaction_id":"CZ8848824762","type":"PAID","remark":"Joined A Contest","amount":"15","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:44 PM"},{"transaction_id":"NM3572820811","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"15","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:52 PM"},{"transaction_id":"UK3881680134","type":"PAID","remark":"Joined A Contest","amount":"15","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:53 PM"},{"transaction_id":"GM9525167163","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"5","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,12:06:12 PM"},{"transaction_id":"SX6822138376","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"10","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,11:06:37 AM"},{"transaction_id":"NK1202699811","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"10","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,11:06:01 AM"},{"transaction_id":"FT9399216294","type":"RECEIVE","remark":"ADD INTO WALLET","amount":"200","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,11:06:45 AM"},{"transaction_id":"TW3387639164","type":"RECEIVE","remark":"Win A Contest","amount":"150","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"22\/06\/2019,02:06:12 AM"},{"transaction_id":"CL8415145004","type":"PAID","remark":"Joined A Contest","amount":"88","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"21\/06\/2019,05:06:14 PM"},{"transaction_id":"QG6673107195","type":"PAID","remark":"Joined A Contest","amount":"88","team_name":"Enric","status_request":null,"status_process":"0","status_credit":"0","time":"21\/06\/2019,03:06:30 PM"}],"success":1,"message":"Transaction data get successfully"}'));
  }

  Future<NotificationRespo> notificationApiDataList() async {
    NotificationRespo responseData;

    responseData = NotificationRespo.fromJson(jsonDecode(
        '{"success": 1, "message": "Notification data get successfully","notification_data": [{"type": "REFUND","notification_detail": "Success! You are a create a team in the AUS vs IND match.","date": "17/08/2021"},{"type": "REFUND","notification_detail": "You Have Login successfully.","date": "18/08/2021"}]}'));
    return responseData;
  }

  Future<BankListResponseData> bankListApprovedResponseData() async {
    return BankListResponseData.fromJson(jsonDecode(
        '{"success":1,"message":"Data get successfully","account_detail":[{"bank_account_id":"5","account_no":"127579858908","account_name":"Enric","bank_image":"49aba629c12ebf9833f538986e787df2.png","ifsc_code":"57fhfh","branch_name":"SBI","address":"hello wold","user_id":"7","bank_request_id":"14","status":"2","created_time":"2019-06-24 13:01:28","updated_time":"0000-00-00 00:00:00"},{"bank_account_id":"6","account_no":"45236987","account_name":"hfggggggggg","bank_image":"b79ffa5df887b72b411bb46385c4e46e.png","ifsc_code":"Tyuirr","branch_name":"axix","address":"fhgddhbv","user_id":"7","bank_request_id":"15","status":"2","created_time":"2019-06-24 17:21:50","updated_time":"0000-00-00 00:00:00"}]}'));
  }

  Future<AppVersionResponce> appVersionResponce() async {
    AppVersionResponce responseData;

    responseData = AppVersionResponce.fromJson(jsonDecode(
        '{"setting":[{"v_id":"1","v_deatil":"1","site_url":"https:\/\/starsportsfantasy.com\/starsports.apk","updated_time":"0000-00-00 00:00:00"}],"success":1,"message":"Setting data get successfully"}'));

    return responseData;
  }

}