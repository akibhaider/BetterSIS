//import 'package:bettersis/utils/bkash_helper.dart';
import 'package:bkash/bkash.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void bkashAddMoney(BuildContext context, double amount) async {
  try {
    final bkash = Bkash(
        bkashCredentials: BkashCredentials(
          username: dotenv.env['bkash_username']!,
          password: dotenv.env['bkash_password']!,
          appKey: dotenv.env['bkash_api_key']!,
          appSecret: dotenv.env['bkash_secret_key']!,
        ),
        logResponse: true);

    final response = await bkash.pay(
      context: context,
      amount: amount,
      merchantInvoiceNumber: 'test12345',
    );

    print(response);
  } on BkashFailure catch (err) {
    print('bkash error: ' + err.message);
  }
}
