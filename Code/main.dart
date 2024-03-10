import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Firebase_command.dart';
import 'Page1.dart';
import 'Page2-2.dart';
import 'Page3.dart';
import 'SetConst.dart';
import'Symbol_class.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const Untzi_System());
}

class Untzi_System extends StatelessWidget {
  const Untzi_System({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Untzi_System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Untzi(title: 'Untzi支援会計システム'),
    );
  }
}

class Untzi extends StatefulWidget {
  const Untzi({super.key, required this.title});
  final String title;

  @override
  State<Untzi> createState() => Untzi_Rayout();
}

class Untzi_Rayout extends State<Untzi>{
  static const _screens = [
    Page2_2(),
    Page1(),
    Page3()
  ];
  GlobalKey<State> _dialogKey = GlobalKey<State>();
  int _selectedIndex = 0;

  static Untzi_Rayout of(BuildContext context) {
    final state = context.findAncestorStateOfType<Untzi_Rayout>();
    if (state == null) {
      throw FlutterError(
          'Untzi_Rayout.of() called with a context that does not contain a _Untzi_RayoutState.');
    }
    return state;
  }

  void _ChangeScreen(int num){
    setState(() {
      _selectedIndex = num;
    });
  }

  void Alert_key(BuildContext context , String title, String content){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
          key: _dialogKey,
          title:Text(title),
          content: Text(content),
          actions: <Widget>[
            GestureDetector(
              child: const Text('分かりました'),
              onTap: () {
                _ChangeScreen(0);
                Navigator.pop(context);
              },
            ),
          ]
      );
    },
    );
  }

  Widget Buttons(String name, int num){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
      ),
      onPressed: (){
          _ChangeScreen(num);
        },

        child: Text(
          name,
          style: const TextStyle(
          color: Colors.black,
          )
      ),
    );
  }

  @override
  initState() {
    super.initState();
    Setnode();
    if(Node == ''){
      _showDialogAfterDelay();
    }
    Auth_signin();
    _ReadCSV();
  }

  Future _ReadCSV() async {
    final String data = await rootBundle.loadString('assets/Data/data.csv');
    final lines = LineSplitter.split(data);
    for (String line in lines) {
      print(line);
      List rows = line.split(',');
      Untzi_Data UD = Untzi_Data(rows[0], rows[1], rows[2], int.parse(rows[3]), rows[4]);
      Menu[UD] = 0;
    }
  }

  Future<void> _showDialogAfterDelay() async {
    await Future.delayed(Duration.zero); // ウィジェットが初期化された後に非同期でダイアログを表示するための遅延
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("接続エラー"),
          content: Text("ノードが接続されていません"),
          actions: <Widget>[
            GestureDetector(
              child: const Text('分かりました'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
                fit: FlexFit.tight,
                flex: 10,
                child: _screens[_selectedIndex]
            ),
            const Padding(padding: EdgeInsets.all(2)),
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Row(
                mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(child:Buttons('鍵共有',0)),
                  Expanded(child: Buttons('注文リスト',1)),
                  Expanded(child:Buttons('お会計',2)),
                  ]
              ),
            )
          ],
        ),
      ),
    );
  }
}
