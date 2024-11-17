import 'dart:typed_data';

import 'package:fib_iraq_payment/fib_iraq_payment.dart';
import 'package:flutter/material.dart';

final FIBService fibService = FIBService();

void main() {
  // You can easily get your client ID and client secret by contacting the FIB company.
  fibService.clientId = 'your client id';
  fibService.clientSecret = 'your client secret';
  fibService.mode = 'stage'; // stage - dev - prod or any other mode
  runApp(const FIBPaymentApp());
}

class FIBPaymentApp extends StatelessWidget {
  const FIBPaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIB Payment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FIBService fibService = FIBService();
  String _paymentId = '';
  String _status = 'No Payment Yet';
  Uint8List? _qrCodeImage;
  String personalAppLink = '';
  String businessAppLink = '';

  Future _createPayment() async {
    final payment = await fibService.createPayment(
      250,
      'Pay with FIB',
      'https://your-callback-url.com',
    );

    // callback url is the url that FIB will send the payment status when the payment is done

    setState(() {
      _paymentId = payment['paymentId'];
      _qrCodeImage = fibService.base64ToImage(payment['qrCode'].split(',')[1]);
      personalAppLink = payment['personalAppLink'];
      businessAppLink = payment['businessAppLink'];
    });

    // you can add url_launcher package to open the link in the browser or in the app

    return payment;
  }

  void _checkPaymentStatus() async {
    if (_paymentId.isEmpty) return;
    final status = await fibService.checkPaymentStatus(_paymentId);
    setState(() {
      _status = status['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () {
      _checkPaymentStatus();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('FIB Payment App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _qrCodeImage != null
                ? Image.memory(_qrCodeImage!)
                : const Text('No QR Code Generated'),
            const SizedBox(height: 10),
            Text('Payment ID: $_paymentId'),
            const SizedBox(height: 10),
            Text('Payment Status: $_status'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createPayment,
              child: const Text('Pay with personal app'),
            ),
          ],
        ),
      ),
    );
  }
}
