import 'package:flutter_flappy_chain/flutter_flappy_chain.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      //助记词
      List<String>? data = await FlutterFlappyChain.createAideMemory(256);
      print(data!.join(" ").toString());

      //助记词转成私钥
      //波场币
      //"m/44'/195'/0'/0/0"
      //以太坊
      //"m/44'/60'/0'/0/0"
      //私钥计算

      //0x6f8103fb82b1e60ebc143a7ba1568ef7137e4adefc7a6f8638fa80cc79f28b38

      // String? privateKey = await FlutterFlappyChain.createWalletPrivateByAide(data, "m/44'/60'/0'/0/0");
      // print(privateKey!);
      // String? address = await FlutterFlappyChain.getEthWalletAddress(privateKey);
      // print(address!);

      String? privateKey = await FlutterFlappyChain.createWalletPrivateByAide(data, "m/44'/195'/0'/0/0");
      print(privateKey!);
      String? address =  FlutterFlappyChain.getTrxWalletAddress(privateKey);
      print(address!);

    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      // _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
      ),
    );
  }
}
