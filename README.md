
# FIB IRAQ Payment Flutter Package

The **FIB IRAQ Payment** package provides easy integration with the FIB Iraq payment gateway in your Flutter applications. It allows developers to create payments, check payment statuses, generate QR codes for payments, and more. This package simplifies the process of integrating the FIB Iraq payment system with a minimal setup required.

## Features

- **Create Payments**: Initiate payments by specifying the amount, description, and callback URL.
- **Check Payment Status**: Verify the status of a payment using its `paymentId`.
- **Generate QR Codes**: Generate QR codes for payments that can be scanned by the FIB app.
- **Refund Payments**: Issue refunds for specific payments.
- **Launch App Links**: Open personal or business FIB apps directly from the payment screen.

## Installation

Add `fib_iraq_payment` to your `pubspec.yaml` file as a dependency:

```yaml
dependencies:
  fib_iraq_payment: ^1.0.0
```

Then, run `flutter pub get` to install the package.

## Usage

### 1. Initialize the Payment Service

You need to initialize the `FIBService` by setting your `clientId` and `clientSecret`. These credentials are provided by FIB Iraq.

```dart
import 'package:fib_iraq_payment/fib_iraq_payment.dart';

final FIBService fibService = FIBService();

void main() {
  fibService.clientId = 'your-client-id';
  fibService.clientSecret = 'your-client-secret';
  runApp(const MyApp());
}
```

### 2. Create a Payment

To create a payment, you need to call the `createPayment` method and pass the amount, description, and callback URL. The callback URL is where the FIB system will send the payment status update.

```dart
Future<void> _createPayment() async {
  final payment = await fibService.createPayment(
    250, // Amount in IQD
    'Payment for services',
    'https://your-callback-url.com', // Payment status callback URL
  );

  setState(() {
    _paymentId = payment['paymentId'];
    _qrCodeImage = fibService.base64ToImage(payment['qrCode'].split(',')[1]);
    personalAppLink = payment['personalAppLink'];
    businessAppLink = payment['businessAppLink'];
  });
}
```

### 3. Check Payment Status

After creating a payment, you can check its status by using the `checkPaymentStatus` method. Pass the `paymentId` to retrieve the status.

```dart
void _checkPaymentStatus() async {
  final status = await fibService.checkPaymentStatus(_paymentId);
  setState(() {
    _status = status['status'];
  });
}
```

### 4. Refund a Payment

You can issue a refund for a specific payment by calling the `refundPayment` method and passing the `paymentId`:

```dart
void _refundPayment(String paymentId) async {
  final refundStatus = await fibService.refundPayment(paymentId);
  print('Refund Status: $refundStatus');
}
```

### 5. Launch Personal or Business App Link

Once the payment is created, the user can be redirected to the FIB personal or business app to complete the payment. You can use the `url_launcher` package to launch the app:

```dart
void _launchPersonalApp(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
```

### Full Example

Below is a full example that demonstrates the use of the FIB IRAQ Payment package:

```dart
import 'package:fib_iraq_payment/fib_iraq_payment.dart';
import 'package:flutter/material.dart';

final FIBService fibService = FIBService();

void main() {
  fibService.clientId = 'your-client-id';
  fibService.clientSecret = 'your-client-secret';
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

    setState(() {
      _paymentId = payment['paymentId'];
      _qrCodeImage = fibService.base64ToImage(payment['qrCode'].split(',')[1]);
      personalAppLink = payment['personalAppLink'];
      businessAppLink = payment['businessAppLink'];
    });

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
```

### Example Application

Check the `example/` directory for a full implementation example.

