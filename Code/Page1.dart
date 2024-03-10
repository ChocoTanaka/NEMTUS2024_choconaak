import 'dart:async';

import 'package:flutter/material.dart';
import 'package:untzi_box/Symbol_class.dart';
import 'SetConst.dart';
import 'symbol.dart';
import 'main.dart';


class Page1 extends StatefulWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  State<Page1> createState() => Untzi_Order();
}

class Untzi_Order extends State<Page1>{
  List<int> Ordernum = [];
  int limitnum=0;
  Timer _timer = Timer(Duration.zero, () {});

  void setOrder(String Name, int num){
    if (Orderlist.containsKey(Name) == false) {
      setState(() {
        Orderlist[Name] = num;
        limitnum =limitnum+num;
      });
    } else {
      setState(() {
        Orderlist[Name] = Orderlist[Name]! + num;
        limitnum =limitnum+num;
      });
    }
  }

  Widget NumButton(BuildContext context,String Name,int num, Function(int) onPressedCallback){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey, // background
            ),
            onPressed:(){
              if(num>0){
                setState(() {
                  onPressedCallback(num - 1);
                });
              }
            },
            child: const Text('▼')
        ),
        Text(num.toString()),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey, // background
            ),
            onPressed:(){
              setState(() {
                onPressedCallback(num + 1);
              });
            },
            child: const Text('▲')
        ),
        ElevatedButton(
            onPressed: (){
              if(num>0) {
                if(limitnum+num<6){
                  setOrder(Name, num);
                  setState(() {
                    onPressedCallback(0);
                  });
                }
                else{
                  return Alert_num(context, '多すぎです', '1回の注文は5個までです。');
                }
              }

            },
            child: const Text('追加')
        )
      ],
    );
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

  Widget Costpop(BuildContext context, String str) {
    return AlertDialog(
      title: Text('注文'),
      content: Text(str),
      actions: <Widget>[
        GestureDetector(
          child: Text('注文しない'),
          onTap: () {
            TxMosaic.clear();
            Navigator.pop(context);
          },
        ),
        GestureDetector(
          child: Text('注文する'),
          onTap: () async{
            SetMosaic(Orderlist);
            late String Result = '';
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AlertDialog(
                  title: Text('トランザクション処理中'),
                );
              },
            );
            await Tx_Order(Address_Customer).then((value) {
              Result = value;
            });
            print(Result);
            setState(() {
              Orderlist.clear();
              limitnum=0;
            });
            Navigator.pop(context);
            if(Result == 'Success'){
              Alert_num(context, Result, 'トランザクションが成功しました');
            }else{
              Alert_num(context, Result, 'トランザクションが失敗しました');
            }

          },
        )
      ],
    );
  }

  Widget payment(BuildContext context){
    if(Orderlist.length>0){
      return ElevatedButton(
        onPressed: () {
          String diagraph = '';
          Orderlist.forEach((key, value) {
            diagraph += '$key が$value 個 \n';
          });
            diagraph += 'です。';
          showDialog<void>(
              context: context,
              builder: (_) {
                return Costpop(context, diagraph);
              });
        },
        child: const Row(
          children: [
            Expanded(
                child: Text(
                    textAlign: TextAlign.center,
                    '注文'
                )
            )
          ],
        ),
      );
    }else{
      return const SizedBox.shrink();
    }
  }

  Future ListSetting() async{
    await List_Check(Address_Untzi);
    setState(() {});
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async{
      await List_Check(Address_Untzi);
      setState(() {});
    });
  }



  @override
  void initState() {
    super.initState();

    Orderlist.clear();
    for(int i = 0; i<Menu.length; i++){
      Ordernum.add(0);
    }
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
  void dispose() {
    super.dispose();
    // ウィジェットが破棄される際にタイマーをキャンセルする
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context){
    setState(() {
      List_Check(Address_Untzi);
    });
    return Scaffold(
        appBar: AppBar(
          title: const Text('Untzi支援募集'),
        ),
        body:Center(
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
                fit: FlexFit.tight,
                flex:3,
                child: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          Flexible(
                            child: GridView.count(
                              padding: EdgeInsets.all(4.0),
                              crossAxisCount: 2,
                              crossAxisSpacing: 0.4, // 縦
                              mainAxisSpacing: 0.4, // 横
                              childAspectRatio: 1.2, // 高さ
                              shrinkWrap: true,
                              children: List.generate(Menu.length, (index) {
                                final key = Menu.keys.elementAt(index);
                                final value = Menu[key];
                                return Card(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset('assets/images/${key.Imagename}.png',
                                            width: 80, height: 80,
                                          ),
                                          ListTile(
                                              title: Text(key.Name),
                                              subtitle: Column(
                                                children: <Widget>[
                                                  (value! > 0)?
                                                  Text(
                                                      ' ${key.Cost} XYM  在庫　$value 個'
                                                  )
                                                  :
                                                  Text(
                                                      ' ${key.Cost} XYM  売り切れ'
                                                  )
                                                  ,
                                                  const SizedBox(height: 15),
                                                  (value>0)?
                                                  NumButton(context,key.Name, Ordernum[index],(newNum){
                                                    setState(() {
                                                      Ordernum[index] = newNum;
                                                    });
                                                  })
                                                  :
                                                  const Text(
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.red
                                                    ),
                                                      '売り切れ'
                                                  )
                                                ],
                                              )
                                          )
                                        ]
                                    )
                                );
                              }),
                            ),
                          ),
                        ]),
                      )
            ),
            Flexible(
                fit: FlexFit.tight,
                flex:1,
                child:Column(
                  children: <Widget>[
                    Expanded(child:Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Flexible(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  crossAxisSpacing: 0.1, // 縦
                                  mainAxisSpacing: 0.1, // 横
                                  childAspectRatio: 1.6, // 高さ
                                ),
                                itemCount: Orderlist.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final keys = Orderlist.keys.toList();
                                  final values = Orderlist.values.toList();
                                  final key = keys[index];
                                  final value = values[index];
                                  return Card(
                                    child: ListTile(
                                        title: Text(textAlign: TextAlign.center,key),
                                        subtitle: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                  textAlign: TextAlign.center,
                                                  '$value 個'
                                              ),
                                            ),
                                            SizedBox(width: 30),
                                            ElevatedButton(
                                                onPressed: (){
                                                  setState(() {
                                                    limitnum = limitnum - Orderlist[key]!;
                                                    Orderlist.remove(key);
                                                  });
                                                },
                                                child: Text('取消'))
                                          ],
                                        )
                                    ),
                                  );
                                },
                              ),
                            ),
                            payment(context),
                          ]),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: (){
                          setState(() {

                          });
                        },
                        child: const Text("更新"))
                  ],
                )



                )
            ],
        ),
      )
    );
  }
}