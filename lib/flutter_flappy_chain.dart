import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:wallet/wallet.dart' as wallet;
import 'package:web_socket_channel/io.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'dart:async';

class FlutterFlappyChain {
  ///channel
  static const MethodChannel _channel = MethodChannel('flutter_flappy_chain');

  ///get trx balance
  static String trxBalance(String address) {
    return "https://api.trongrid.io/v1/accounts/$address";
  }

  ///create aide
  static Future<List<String>?> createAideMemory(strength) async {
    String seed = bip39.generateMnemonic(strength: strength);
    return seed.toString().split(" ");
  }

  ///get aide wallet
  static Future<String?> createWalletPrivateByAide(List<String> aide, String path) async {
    String seed = bip39.mnemonicToSeedHex(aide.join(" "));
    Chain chain = Chain.seed(seed);
    ExtendedKey key = chain.forPath(path);
    return "0x${key.privateKeyHex().substring(2, key.privateKeyHex().length)}";
  }

  ///get wallet address(ETH)
  static Future<String?> getEthWalletAddress(String privateKey) async {
    wallet.PrivateKey private = wallet.PrivateKey(
      privateKey.toLowerCase().startsWith("0x") ? BigInt.parse(privateKey) : BigInt.parse("0x$privateKey"),
    );
    wallet.PublicKey publicKey = const wallet.Ethereum().createPublicKey(private);
    return const wallet.Ethereum().createAddress(publicKey);
  }

  ///get wallet address(TRX)
  static String getTrxWalletAddress(String privateKey) {
    wallet.PrivateKey private = wallet.PrivateKey(
      privateKey.toLowerCase().startsWith("0x") ? BigInt.parse(privateKey) : BigInt.parse("0x$privateKey"),
    );
    wallet.PublicKey publicKey = const wallet.Tron().createPublicKey(private);
    return const wallet.Tron().createAddress(publicKey);
  }

  ///check is private key or not
  static bool isPrivateKey(String privateKey) {
    try {
      wallet.PrivateKey(
        privateKey.toLowerCase().startsWith("0x") ? BigInt.parse(privateKey) : BigInt.parse("0x$privateKey"),
      );
      return true;
    } catch (error) {
      return false;
    }
  }

  ///get trx balance
  static getTrxBalance(String address) {}

  ///get eth Balance
  static Future<EtherAmount> getEthBalance(String address) async {
    String rpcUrl = 'https://eth-mainnet.token.im';
    String wsUrl = 'ws://eth-mainnet.token.im';
    Client httpClient = Client();
    Web3Client web3client = Web3Client(rpcUrl, httpClient, socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    return await web3client.getBalance(EthereumAddress.fromHex(address));
  }

  ///get eth Balance
  static Future<dynamic> getEthTokenBalance(String contractAddress, String address) async {
    String rpcUrl = 'https://eth-mainnet.token.im';
    String wsUrl = 'ws://eth-mainnet.token.im';
    Client httpClient = Client();
    Web3Client web3client = Web3Client(rpcUrl, httpClient, socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson('CONTRACT_ABI', 'USDT'),
      EthereumAddress.fromHex(contractAddress),
    );
    ContractFunction balanceFunction = contract.function('balanceOf');
    List<dynamic> balance = await web3client.call(
      contract: contract,
      function: balanceFunction,
      params: [EthereumAddress.fromHex(address)],
    );
    return balance.first;
  }
}
