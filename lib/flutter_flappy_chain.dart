import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:wallet/wallet.dart' as wallet;
import 'package:web_socket_channel/io.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart';
import 'dart:async';
import 'dart:math';

class TrxBalance {
  ///this is balance
  Decimal balance = Decimal.fromInt(0);

  ///this is contract balance
  Map<String, Decimal> contractBalance = {};

  ///get balance
  Decimal getContractBalance(String contactAddress, {int wei = 6}) {
    return ((contractBalance[contactAddress] ?? Decimal.fromInt(0)) / Decimal.fromInt(pow(10, 6).toInt())).toDecimal();
  }
}

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
  static Future<TrxBalance> getTrxBalance(String address) async {
    TrxBalance trxBalance = TrxBalance();

    ///use dio
    dio.Dio dioRequest = dio.Dio();
    dioRequest.options.responseType = dio.ResponseType.json;
    String urlPath = "https://api.trongrid.io/v1/accounts/$address";
    dio.Response response = await dioRequest.get(urlPath);

    ///return data
    if (response.data['data'] != null && response.data['data'] is List && response.data['data'].isNotEmpty) {
      ///set data
      Decimal decimal = Decimal.fromInt(response.data['data'][0]['balance']);
      Decimal divisor = Decimal.parse('1000000');
      trxBalance.balance = (decimal / divisor).toDecimal();
    }

    ///set trc20 data list
    if (response.data['data'] != null && response.data['data'] is List && response.data['data'].isNotEmpty) {
      List trc20List = response.data['data'][0]['trc20'];
      Map<String, Decimal> balanceList = {};
      for (Map item in trc20List) {
        String key = item.keys.first;
        String value = item[key];
        balanceList[key] = Decimal.parse(value);
      }
      trxBalance.contractBalance = balanceList;
    }
    return trxBalance;
  }

  ///get eth Balance
  static Future<Decimal> getEthBalance(String address) async {
    String rpcUrl = 'https://eth-mainnet.token.im';
    String wsUrl = 'ws://eth-mainnet.token.im';
    Client httpClient = Client();
    Web3Client web3client = Web3Client(rpcUrl, httpClient, socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    EtherAmount amount = await web3client.getBalance(EthereumAddress.fromHex(address));
    Decimal decimal = Decimal.fromBigInt(amount.getInWei);
    Decimal divisor = Decimal.parse('1000000000000000000');
    return (decimal / divisor).toDecimal();
  }

  ///get eth Balance
  static Future<Decimal> getEthTokenBalance(String contractAddress, String address) async {
    String rpcUrl = 'https://eth-mainnet.token.im';
    String wsUrl = 'ws://eth-mainnet.token.im';
    Client httpClient = Client();
    Web3Client web3client = Web3Client(rpcUrl, httpClient, socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(
          '[{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"}]',
          'USDT'),
      EthereumAddress.fromHex(contractAddress),
    );
    ContractFunction balanceFunction = contract.function('balanceOf');
    List<dynamic> balance = await web3client.call(
      contract: contract,
      function: balanceFunction,
      params: [EthereumAddress.fromHex(address)],
    );
    Decimal decimal = Decimal.fromBigInt(balance.first);
    Decimal divisor = Decimal.parse('1000000');
    return (decimal / divisor).toDecimal();
  }
}
