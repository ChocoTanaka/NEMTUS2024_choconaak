import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:symbol_sdk/index.dart';
import 'package:symbol_sdk/CryptoTypes.dart' as ct;
import 'package:symbol_sdk/symbol/index.dart';
import 'package:http/http.dart' as http;
import 'package:symbol_sdk/symbol/models.dart';
import 'Firebase_command.dart';
import 'SetConst.dart';
import 'Symbol_class.dart';

Future<String> GetDataFromAPI(String Address)async{
  // HTTPリクエストを送信してレスポンスを取得
  var response = await http.get(Uri.parse('$Node/accounts/$Address'));
  if (response.statusCode == 200) {
    // レスポンスの文字列を返す
    return response.body;
  } else {
    // レスポンスが失敗した場合はエラーをスローするなどの処理を行う
    print('APIからのデータの取得に失敗しました: ${response.statusCode}');
    return '';
  }
}

Future List_Check(String Address) async{
  const JsonDecoder decoder = JsonDecoder();
  String Datastring = await GetDataFromAPI(Address);
  if(Datastring == ''){
    print('Nothing');
  }else{
    Map<String,dynamic> Jdata = decoder.convert(Datastring);
    Account Ac = Account.fromJson(Jdata['account']);
      Ac.mosaics.forEach((element) {
        if(Address == Address_Untzi) {
          Menu.forEach((key, value) {
            String Name = key.SerchName(element.id);
            if(Name !=''){
              setMenuAmount(Name, element.amount);
            }
          });
        }else {
          if(element.id == XYMID){
            AmountXYM = (element.amount * 1E-6).toInt();
          }else{
            Menu.forEach((key, value) {
              String Name = key.SerchName(element.id);
              if(Name !=''){
                AccountingList[Name] = element.amount;
              }
            });
          }
        }
      });
      Menu.forEach((key, value) {
      });
    }
  }

void SetMosaic(Map<String, int> OrderList){
  OrderList.forEach((key1, value1) {
    Menu.forEach((key2,value2) {
      if(key1 == key2.Name){
        TxMosaic.add(key2.SendMosaic(value1));
      }
    });
  });
}

bool CheckAddress_PrivateKey(String Address, String PKey){
  bool Result =false;

  var PubKey = KeyPair(ct.PrivateKey(PKey)).publicKey;
  var Address_from_Key = addressToString(facade.network.publicKeyToAddress(ct.PublicKey(PubKey.bytes)));

  Result = (Address == Address_from_Key);
  return Result;
}


Future<String> Tx_Order(String Address_send) async {
  String Result = '';
  String Cookie = '';
  try{
    await GetCookie().then((value) => Cookie = value);

    var tx = TransferTransactionV1(
        network: NetworkType.TESTNET,
        deadline: Timestamp(facade.network.fromDatetime(DateTime.now().toUtc()).addHours(2).timestamp),
        recipientAddress: UnresolvedAddress(Address_send),
        signerPublicKey: PublicKey(pubKey_Untzi),
        mosaics: TxMosaic
    );
    tx.fee = Amount(tx.size * 100);
    tx.sort();

    var Payload = bytesToHex(tx.serialize());
    await Safety_Sign(Cookie,Payload).then((signedPayload) {
      signedPayload = '{"payload": "$signedPayload"}';
      http.put(
          Uri.parse('$Node/transactions'),
          headers: {'Content-Type': 'application/json'},
          body: signedPayload)
          .then((response) {
        print(response.body);
      });
    });
    Result = 'Success';
  }catch(e){
    print(e);
    Result = 'Transaction Error';
  }
  TxMosaic.clear();
  Cookie='';
  return Result;
}

Future<String> Tx_Payment(String Address_send, String priKey_send, int charge)async{
  String Cookie = '';
  String Result = '';
  try{
    await GetCookie().then((value) => Cookie = value);
    var keyPair_send = KeyPair(ct.PrivateKey(priKey_send));

    var AggTx = AggregateCompleteTransactionV2(
      network: NetworkType.TESTNET,
      signerPublicKey: PublicKey(pubKey_Untzi),
      deadline: Timestamp(facade.network.fromDatetime(DateTime.now().toUtc()).addHours(2).timestamp),
    );
    TxMosaic.forEach((element) {
      var tx1 = EmbeddedMosaicSupplyRevocationTransactionV1(
          signerPublicKey: PublicKey(pubKey_Untzi),
          network: NetworkType.TESTNET,
          sourceAddress: UnresolvedAddress(Address_send),
          mosaic: element
      );
      AggTx.transactions.add(tx1);
    });
    var tx2 = EmbeddedTransferTransactionV1(
      signerPublicKey: PublicKey(keyPair_send.publicKey.bytes),
      network: NetworkType.TESTNET,
      recipientAddress: UnresolvedAddress(Address_Untzi),
      mosaics: <UnresolvedMosaic>[
        UnresolvedMosaic(
            mosaicId: UnresolvedMosaicId(XYMID),
            amount: Amount(charge * pow(10,6))
        ),
      ],
    );
    AggTx.transactions.add(tx2);

    var markleHash = SymbolFacade.hashEmbeddedTransactions(AggTx.transactions);
    AggTx.fee = Amount((AggTx.size + 1 * 104) * 100);
    AggTx.transactionsHash = Hash256(markleHash.bytes);

    var Payload = bytesToHex(AggTx.serialize()); //このペイロードをAPIに送る

    //こっから後でAPI
    await Safety_Sign(Cookie,Payload).then((signedPayload) {
      //こっから内部処理
      var signedTx = TransactionFactory().deserialize(signedPayload);
      var hash = facade.hashTransaction(signedTx);
      var cosignature = Cosignature(
        signature: Signature(keyPair_send.sign(hash.bytes).bytes),
        signerPublicKey: PublicKey(keyPair_send.publicKey.bytes),
      );
      signedTx.cosignatures =[cosignature];

      var transactionBuffer = signedTx.serialize();
      var hexPayload = bytesToHex(transactionBuffer);
// putするためのjsonを作成
      var payload = '{"payload": "$hexPayload"}';

      http.put(
          Uri.parse('$Node/transactions'),
          headers: {'Content-Type': 'application/json'},
          body: payload)
          .then((response) {
        print(response.body);
      });
      Result = 'Success';

    });
  }catch(e){
    Result = 'Transaction Error';
    print(e);
  }
  TxMosaic.clear();
  Cookie = '';
  return Result;
}