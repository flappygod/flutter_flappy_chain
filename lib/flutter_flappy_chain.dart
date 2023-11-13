import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter_flappy_chain/keccak256.dart';
import 'package:wallet/wallet.dart' as wallet;
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class FlutterFlappyChain {
  ///channel
  static const MethodChannel _channel = MethodChannel('flutter_flappy_chain');

  ///create aide
  static Future<List<String>?> createAideMemory(strength) async {
    String seed = bip39.generateMnemonic(strength: strength);
    return seed.toString().split(" ");
  }

  ///get aide wallet
  static Future<String?> createWalletPrivateByAide(List<String> aide, String path) async {
    //seed
    String seed = bip39.mnemonicToSeedHex(aide.join(" "));
    //chain
    Chain chain = Chain.seed(seed);
    //key
    ExtendedKey key = chain.forPath(path);
    //get private key
    return "0x" + key.privateKeyHex().substring(2, key.privateKeyHex().length);
  }

  ///get aide wallet
  static Future<String?> createWalletTronPrivate(List<String> aide) async {
    //seed
    String seed = bip39.mnemonicToSeedHex(aide.join(" "));

    //create private key
    wallet.PrivateKey privateKey = const wallet.Tron().createPrivateKey(Uint8List.fromList(seed.codeUnits));

    //get private key
    return privateKey.toString();
  }

  ///get wallet address(ETH)
  static Future<String?> getEthWalletAddress(String privateKey) async {
    //get private key
    EthPrivateKey private = EthPrivateKey.fromHex(privateKey);
    //address
    EthereumAddress address = private.address;
    //Keccak256 EIP55 address
    return Keccak256.ethEIP55Address(address.hex);
  }

  ///get wallet address(TRX)
  static String getTrxWalletAddress(String privateKey) {
    wallet.PrivateKey private = wallet.PrivateKey(
      privateKey.toLowerCase().startsWith("0x") ? BigInt.parse(privateKey) : BigInt.parse("0x$privateKey"),
    );
    wallet.PublicKey publicKey = const wallet.Tron().createPublicKey(private);
    return const wallet.Tron().createAddress(publicKey);
  }
}
