import 'package:convert/convert.dart' show hex;
import 'package:pointycastle/pointycastle.dart';
import "dart:convert" show utf8;
import 'package:hex/hex.dart';
import 'dart:typed_data';
import 'dart:math';

enum Endian {
  be,
// FIXME: le
}

class Keccak256 {
  //转换为EIP55
  static String ethEIP55Address(String str) {
    String address = str.toLowerCase().replaceAll('0x', '');
    String hash = HEX.encode(Keccak256.keccak256(address));
    String ret = '0x';
    for (var i = 0; i < address.length; i++) {
      if (int.parse(hash[i], radix: 16) >= 8) {
        ret += address[i].toUpperCase();
      } else {
        ret += address[i];
      }
    }
    return ret;
  }

  static Uint8List keccak256(dynamic a) {
    a = toBuffer(a);
    Digest sha3 = Digest("Keccak/256");
    return sha3.process(a);
  }

  /// Is the string a hex string.
  static bool isHexString(String value, {int length = 0}) {
    ArgumentError.checkNotNull(value);
    if (!RegExp('^0x[0-9A-Fa-f]*\$').hasMatch(value)) {
      return false;
    }
    if (length > 0 && value.length != 2 + 2 * length) {
      return false;
    }
    return true;
  }

  static bool isHexPrefixed(String str) {
    ArgumentError.checkNotNull(str);
    return str.substring(0, 2) == '0x';
  }

  static String stripHexPrefix(String str) {
    ArgumentError.checkNotNull(str);
    return isHexPrefixed(str) ? str.substring(2) : str;
  }

  /// Pads a [String] to have an even length
  static String padToEven(String value) {
    ArgumentError.checkNotNull(value);
    var a = value;
    if (a.length % 2 == 1) {
      a = "0$a";
    }
    return a;
  }

  /// Converts an [int] to a [Uint8List]
  static Uint8List intToBuffer(int i) {
    ArgumentError.checkNotNull(i);
    return Uint8List.fromList(hex.decode(padToEven(intToHex(i).substring(2))));
  }

  static String intToHex(int i) {
    ArgumentError.checkNotNull(i);
    return "0x${i.toRadixString(16)}";
  }

  /// Attempts to turn a value into a [Uint8List]. As input it supports [Uint8List], [String], [int], [null], [BigInt] method.
  static Uint8List toBuffer(v) {
    if (v is! Uint8List) {
      if (v is List) {
        v = Uint8List.fromList(v.map<int>((e) {
          return e;
        }).toList());
      } else if (v is String) {
        if (isHexString(v)) {
          v = Uint8List.fromList(hex.decode(padToEven(stripHexPrefix(v))));
        } else {
          v = Uint8List.fromList(utf8.encode(v));
        }
      } else if (v is int) {
        v = intToBuffer(v);
      } else if (v == null) {
        v = Uint8List(0);
      } else if (v is BigInt) {
        v = Uint8List.fromList(encodeBigInt(v));
      } else {
        throw 'invalid type';
      }
    }
    return v;
  }

  static final BigInt _byteMask = BigInt.from(0xff);

  static BigInt decodeBigInt(List<int> bytes) {
    BigInt result = BigInt.from(0);
    for (int i = 0; i < bytes.length; i++) {
      result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
    }
    return result;
  }

  static Uint8List encodeBigInt(BigInt input, {Endian endian = Endian.be, int length = 0}) {
    int byteLength = (input.bitLength + 7) >> 3;
    int reqLength = length > 0 ? length : max(1, byteLength);
    assert(byteLength <= reqLength, 'byte array longer than desired length');
    assert(reqLength > 0, 'Requested array length <= 0');
    var res = Uint8List(reqLength);
    res.fillRange(0, reqLength - byteLength, 0);
    var q = input;
    if (endian == Endian.be) {
      for (int i = 0; i < byteLength; i++) {
        res[reqLength - i - 1] = (q & _byteMask).toInt();
        q = q >> 8;
      }
      return res;
    } else {
      // FIXME: le
      throw UnimplementedError('little-endian is not supported');
    }
  }
}
