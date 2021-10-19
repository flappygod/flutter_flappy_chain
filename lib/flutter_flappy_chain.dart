import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter_flappy_chain/keccak256.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class FlutterFlappyChain {
  //channel
  static const MethodChannel _channel = MethodChannel('flutter_flappy_chain');

  //生成一个助记词
  static Future<List<String>?> ethCreateAideMemory(strength) async {
    String seed = bip39.generateMnemonic(strength: strength);
    return seed.toString().split(" ");
  }

  //拿到私钥
  static Future<String?> ethCreateWalletByAide(List<String> aide, String path) async {
    //转换为Seed
    String seed = bip39.mnemonicToSeedHex(aide.join(" "));
    //转换为chain
    Chain chain = Chain.seed(seed);
    //地址
    ExtendedKey key = chain.forPath(path);
    //获得私钥
    return "0x" + key.privateKeyHex().substring(2, key.privateKeyHex().length);
  }

  //创建钱包
  static Future<String?> ethCreateWallet(String path) async {
    //随机生成助记词
    List<String>? data = await ethCreateAideMemory(256);
    //生成私钥
    String? privateKey = await ethCreateWalletByAide(data!, path);
    //私钥
    return privateKey;
  }

  //获取以太坊千百的地址
  static Future<String?> ethGetWalletAddress(String privateKey) async {
    //通过私钥拿到地址信息
    EthPrivateKey private = EthPrivateKey.fromHex(privateKey);
    //地址
    EthereumAddress address = await private.extractAddress();
    //返回
    return Keccak256.ethEIP55Address(address.hex);
  }

  //获取钱包的私钥
  static Future<String?> ethGetWalletPrivateKey(String path) async {
    final String? key = await _channel.invokeMethod('ethGetWalletPrivateKey', {"path": path});
    return key;
  }
}
