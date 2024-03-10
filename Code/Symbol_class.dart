import 'package:symbol_sdk/index.dart';
import 'package:symbol_sdk/CryptoTypes.dart' as ct;
import 'package:symbol_sdk/symbol/index.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

List<String> NodeList = ['testnet1.symbol-mikun.net', 'sym-test-03.opening-line.jp','pequod.cola-potatochips.net','2.dusanjp.com'];
late String Node = '';

Future<void> Setnode() async{
  final client = http.Client();
  do {
    int num = math.Random().nextInt(NodeList.length);
    Node = 'https://${NodeList[num]}:3001';
    String url = '$Node/node/health';
    try{
      final response = await client.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        break;
      }else{
        NodeList.removeAt(num);
        if (NodeList.isEmpty) {
          Node = '';
        }
      }
    }catch(e){
      NodeList.removeAt(num);
      if (NodeList.isEmpty) {
        Node = '';
      }
    }
  }while(Node != '');
}

List<UnresolvedMosaic> TxMosaic = [];

class TxStatus{
  late String Group;
  late String Code;
}



class Account{
  late List<Mosaics> mosaics = [];

  Account({required this.mosaics});

  Account.fromJson(Map<String,dynamic> json){
    json['mosaics']?.forEach((element) {
      mosaics.add(Mosaics.fromJson(element));
    });
  }
}

class Mosaics{
  late String id;
  late int amount;
  Mosaics({required this.id, required this.amount});

  Mosaics.fromJson(Map<String,dynamic> json){
    id = json['id'];
    amount = int.parse(json['amount']);
  }

}