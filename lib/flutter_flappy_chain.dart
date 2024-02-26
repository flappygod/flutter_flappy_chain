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
      ContractAbi.fromJson('[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_upgradedAddress","type":"address"}],"name":"deprecate","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"deprecated","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_evilUser","type":"address"}],"name":"addBlackList","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"upgradedAddress","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balances","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"maximumFee","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"_totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"unpause","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_maker","type":"address"}],"name":"getBlackListStatus","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowed","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"paused","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"who","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"pause","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getOwner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"newBasisPoints","type":"uint256"},{"name":"newMaxFee","type":"uint256"}],"name":"setParams","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"amount","type":"uint256"}],"name":"issue","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"amount","type":"uint256"}],"name":"redeem","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"basisPointsRate","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"isBlackListed","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_clearedUser","type":"address"}],"name":"removeBlackList","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"MAX_UINT","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_blackListedUser","type":"address"}],"name":"destroyBlackFunds","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[{"name":"_initialSupply","type":"uint256"},{"name":"_name","type":"string"},{"name":"_symbol","type":"string"},{"name":"_decimals","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"amount","type":"uint256"}],"name":"Issue","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"amount","type":"uint256"}],"name":"Redeem","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"newAddress","type":"address"}],"name":"Deprecate","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"feeBasisPoints","type":"uint256"},{"indexed":false,"name":"maxFee","type":"uint256"}],"name":"Params","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_blackListedUser","type":"address"},{"indexed":false,"name":"_balance","type":"uint256"}],"name":"DestroyedBlackFunds","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_user","type":"address"}],"name":"AddedBlackList","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_user","type":"address"}],"name":"RemovedBlackList","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[],"name":"Pause","type":"event"},{"anonymous":false,"inputs":[],"name":"Unpause","type":"event"}]', 'USDT'),
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
