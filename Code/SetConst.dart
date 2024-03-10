import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:symbol_sdk/index.dart';
import 'package:symbol_sdk/symbol/index.dart';

Map<String, int> Orderlist = {};

Map<String, int> AccountingList = {};

late int AmountXYM = 0;

class Untzi_Data{
  late String Name;
  late String Ns;
  late String Id;
  late int Cost;
  late String Imagename;

  Untzi_Data(this.Name,this.Ns,this.Id,this.Cost, this.Imagename);

  int GetCost(String name){
    if(name == this.Name){
      return this.Cost;
    }else{
      return 0;
    }
  }

  String SerchName(String Id){
    if(Id == this.Id){
      return this.Name;
    }
    else{
      return '';
    }
  }

  Map<String, int> Paymentbase(){
    Map<String, int> Data = {
      this.Name : this.Cost
    };
    return Data;
  }

  UnresolvedMosaic SendMosaic(int amount){
    return UnresolvedMosaic(
        mosaicId: UnresolvedMosaicId(this.Id),
        amount: Amount(amount)
    );
  }
}

Map<Untzi_Data,int> Menu = {};

int getMenuAmount(String name){
  int val = 0;
  Menu.forEach((key, value) {
    if(name == key.Name){
      val = Menu[key]!;
    }
  });
  return val;
}

void setMenuAmount(String name, int amount){
  Menu.forEach((key, value) {
    if(name == key.Name){
      Menu[key] = amount;
    }
  });
}


String name_untzi = 'untzi-club';

String Address_Customer = '';
String priKey_Customer = '';

var facade = SymbolFacade(Network.TESTNET);
String XYMID = '72C0212E67A08BCE';
String Address_Untzi = 'TAMMK4ZZYPDFYD55L4BOP4MVUHNYWOBMX256UKQ';
String pubKey_Untzi = 'C4ABF367B5BEC22862FE46FC59FA70D09694307802E51868D1D8C1D281336B65';


FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFunctions func = FirebaseFunctions.instanceFor(app: Firebase.app(), region: 'asia-northeast1');