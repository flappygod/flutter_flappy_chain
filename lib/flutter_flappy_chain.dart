import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter_flappy_chain/keccak256.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class FlutterFlappyChain {
  //channel
  static const MethodChannel _channel = MethodChannel('flutter_flappy_chain');

  //cerate aide
  static Future<List<String>?> ethCreateAideMemory(strength) async {
    String seed = bip39.generateMnemonic(strength: strength);
    return seed.toString().split(" ");
  }

  //get aide wallet
  static Future<String?> ethCreateWalletByAide(List<String> aide, String path) async {
    //seed
    String seed = bip39.mnemonicToSeedHex(aide.join(" "));
    //chain
    Chain chain = Chain.seed(seed);
    //key
    ExtendedKey key = chain.forPath(path);
    //get private key
    return "0x" + key.privateKeyHex().substring(2, key.privateKeyHex().length);
  }

  //create wallet
  static Future<String?> ethCreateWallet(String path) async {
    //get aides
    List<String>? data = await ethCreateAideMemory(256);
    //get privateKey
    String? privateKey = await ethCreateWalletByAide(data!, path);
    //privateKey
    return privateKey;
  }

  //get wallet address
  static Future<String?> ethGetWalletAddress(String privateKey) async {
    //get private key
    EthPrivateKey private = EthPrivateKey.fromHex(privateKey);
    //address
    EthereumAddress address = await private.extractAddress();
    //Keccak256 EIP55 address
    return Keccak256.ethEIP55Address(address.hex);
  }

  //private key
  static Future<String?> ethGetWalletPrivateKey(String path) async {
    final String? key = await _channel.invokeMethod('ethGetWalletPrivateKey', {"path": path});
    return key;
  }
}
