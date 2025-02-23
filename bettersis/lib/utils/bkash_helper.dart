import 'package:bkash/bkash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final bkash = Bkash(
    bkashCredentials: BkashCredentials(
      username: 'sandboxTokenizedUser02',
      password: 'sandboxTokenizedUser02@12345',
      appKey: '4f6o0cjiki2rfm34kfdadl1eqq',
      appSecret: '2is7hdktrekvrbljjh44ll3d9l1dtjo4pasmjvs5vl5qr3fug4b',
    ),
    logResponse: true);
