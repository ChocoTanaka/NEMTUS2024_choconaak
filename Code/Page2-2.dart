import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untzi_box/SetConst.dart';
import 'package:symbol_sdk/index.dart';
import 'package:symbol_sdk/CryptoTypes.dart' as ct;
import 'package:symbol_sdk/symbol/index.dart';
import 'package:untzi_box/symbol.dart';

class Page2_2 extends StatefulWidget {
  const Page2_2({Key? key}) : super(key: key);

  @override
  State<Page2_2> createState() => Share_PubKey2();
}


class Share_PubKey2 extends State<Page2_2>{
  final myController1 = TextEditingController();
  final myController2 = TextEditingController();
  var Address1 = '';
  var prikey1 = '';
  String Setting = 'Write your Information.';


  void Save(String Address, String priKey){
    Address_Customer = Address;
    priKey_Customer = priKey;
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('ウォレット登録 ※テストネット限定です'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(Setting),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:<Widget>[
                  const Text('Address:'),
                  const Padding(padding: EdgeInsets.all(10)),
                  Flexible(
                    child: TextField(
                      controller: myController1,
                      onChanged: (text) => setState(() {
                        Address1 = myController1.text;
                      }),
                    ),
                  )
                ]
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:<Widget>[
                  const Text('Private Key:'),
                  const Padding(padding: EdgeInsets.all(10)),
                  Flexible(
                    child: TextField(
                      controller: myController2,
                      onChanged: (text) => setState(() {
                        prikey1 = myController2.text;
                      }),
                    ),
                  )

                ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                    onPressed: () {

                      bool CheckAddress = CheckAddress_PrivateKey(Address1, prikey1);
                      if(!CheckAddress){
                        showDialog(context: context, builder: (BuildContext context){
                          return AlertDialog(
                              title:Text('照合エラー'),
                              content: Text('秘密鍵がアドレスと対応していません'),
                              actions: <Widget>[
                                GestureDetector(
                                  child: const Text('分かりました'),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ]
                          );
                        });
                      }else{
                        setState(() {
                          Address_Customer = '';
                          priKey_Customer = '';
                          myController1.clear();
                          myController2.clear();
                          Save(Address1, prikey1);
                          Setting ='Address: $Address_Customer';
                        });
                      }
                    },
                    child: const Text("Save")
                ),
                const Padding(padding: EdgeInsets.all(10)),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Address_Customer = '';
                        priKey_Customer = '';
                        Setting ='Rested.';
                      });
                    },
                    child: const Text("Reset")
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}