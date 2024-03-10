import 'package:flutter/material.dart';
import 'SetConst.dart';
import 'symbol.dart';
import 'main.dart';
import 'package:symbol_sdk/index.dart';
import 'package:symbol_sdk/CryptoTypes.dart' as ct;
import 'package:symbol_sdk/symbol/index.dart';


class Page3 extends StatefulWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  State<Page3> createState() => Untzi_Pay();
}

class Untzi_Pay extends State<Page3>{
  int charge = 0;

  void calcCharge(){
    charge = 0;
    AccountingList.forEach((key1, value1) {
      int basecost = 0;
      Menu.forEach((key2, value2) {
        basecost +=key2.GetCost(key1);
      });
      charge += basecost * value1;

    });
    setState(() {

    });
  }

  void Alert_num(BuildContext context , String title, String content){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
          title:Text(title),
          content: Text(content),
          actions: <Widget>[
            GestureDetector(
              child: const Text('分かりました'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ]
      );
    },
    );
  }

  Future ListSetting() async{
    setState(() async{
      await List_Check(Address_Customer);
      calcCharge();
    });
  }

  @override
  void initState() {
    super.initState();
    if(Address_Customer.isEmpty || priKey_Customer.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Untzi_Rayoutの状態にアクセスするためにGlobalKeyを使用
        final untziRayoutState = Untzi_Rayout.of(context);
        untziRayoutState.Alert_key(context, '入力エラー', 'アドレスと秘密鍵が入力されていません');
      });
    }else{
      ListSetting();
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('お会計'),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  fit: FlexFit.tight,
                  flex:1,
                  child: Text('手持ち：　$AmountXYM　XYM')
              ),
              Flexible(
                  fit: FlexFit.tight,
                  flex:7,
                  child: ListView.builder(
                    itemCount: AccountingList.length,
                    itemBuilder: (context,index){
                      String name = AccountingList.keys.elementAt(index);
                      int value = AccountingList[name]!;
                      int basecost = 0;
                      Menu.forEach((key, value) {
                        basecost +=key.GetCost(name);
                      });
                      int cost = basecost * value;

                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(),
                          ),
                        ),
                        child: ListTile(
                          title:  Text('$name　:'),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text('$basecost　XYM'),
                              Text('$value　個'),
                              Text('$cost XYM')
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ),
              const Padding(
                  padding: EdgeInsets.all(20),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex:1,
                child: Text('お支払い　$charge　XYM'),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex:1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () async{
                          if(charge>0){
                            SetMosaic(AccountingList);
                            String result = '';
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AlertDialog(
                                  title: Text('トランザクション処理中'),
                                );
                              },
                            );
                            await Tx_Payment(Address_Customer,priKey_Customer,charge).then((value) {
                              result = value;
                            });
                            Navigator.pop(context);
                            if(result == 'Success'){
                              Alert_num(context, result, 'トランザクションが成功しました');
                              setState(() {
                                AccountingList.clear();
                              });
                            }
                            else{
                              Alert_num(context, result, 'トランザクションが失敗しました');
                            }
                          }else{
                            Alert_num(context, '会計エラー', 'お支払いはありません');
                          }
                        },
                        //後で書く
                        child: const Text('お会計')
                    ),
                    ElevatedButton(
                        onPressed: (){
                          setState(() {
                            List_Check(Address_Customer);
                            calcCharge();
                          });
                        },
                        //後で書く
                        child: const Text('更新')
                    ),
                  ],
                )

              )
            ]
        ),
      ),
    );
  }
}