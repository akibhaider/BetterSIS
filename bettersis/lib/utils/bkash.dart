import 'package:bettersis/utils/bkash_helper.dart';
import 'package:bkash/bkash.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void bkashAddMoney(BuildContext context, double amount) async {
  try {
    if (context == null) {
      print("Error: Context is null");
      return;
    }

    final response = await bkash.pay(
      context: context,
      amount: amount,
      merchantInvoiceNumber: dotenv.env['invoice']!,
    );

    print(response);
  } on BkashFailure catch (err) {
    print(err.message);
  }
}
