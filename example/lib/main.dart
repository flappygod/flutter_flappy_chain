import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_flappy_chain/flutter_flappy_chain.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

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
      List<String>? data = await FlutterFlappyChain.ethCreateAideMemory(256);
      print(data!.join(" ").toString());

      data="toward lecture miss crowd begin cup post razor remain object story spring secret private addict wisdom draw pumpkin order "
          "mixed glimpse volume all talk".split(" ");

      //助记词转成私钥
      //波场币
      //"m/44'/195'/0'/0/0"
      //以太坊
      //"m/44'/60'/0'/0/0"
      //私钥计算
      String? privateKey = await FlutterFlappyChain.ethCreateWalletByAide(data, "m/44'/195'/0'/0/0");
      print(privateKey!);

      //地址计算
      String? address = await FlutterFlappyChain.ethGetWalletAddress(privateKey);
      print(address!);

      print(data);
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
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
