import 'package:bkash/bkash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final bkash = Bkash(
    bkashCredentials: BkashCredentials(
      username: dotenv.env['bkash_username']!,
      password: dotenv.env['bkash_password']!,
      appKey: dotenv.env['bkash_api_key']!,
      appSecret: dotenv.env['bkash_secret_key']!,
    ),
    logResponse: true);
