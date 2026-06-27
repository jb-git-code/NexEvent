import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nexevent/services/firestore_service.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool scanned = false;

  Future<void> verifyQR(String registrationId) async {
    final doc = await FirebaseFirestore.instance
        .collection("registrations")
        .doc(registrationId)
        .get();

    if (!doc.exists) {
      return;
    }

    if (doc["attended"] == true) {
      return;
    }
  }

  Future<void> markAttendance(String id) async {
    await FirebaseFirestore.instance.collection('registrations').doc(id).update(
      {"attended": true},
    );
    final snack = SnackBar(content: Text('Attendance Marked'));
    ScaffoldMessenger.of(context).showSnackBar(snack);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> handleScan(String registrationId) async {
    final doc = await FirebaseFirestore.instance
        .collection("registrations")
        .doc(registrationId)
        .get();

    if (!doc.exists) {
      _showMessage("Invalid QR Code");
      return;
    }

    if (doc["attended"] == true) {
      _showMessage("Attendance already marked");
      return;
    }

    await FirebaseFirestore.instance
        .collection("registrations")
        .doc(registrationId)
        .update({"attended": true});

    _showMessage("Attendance Marked");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: MobileScanner(
        onDetect: (capture) async {
          if (scanned) return;

          final barcode = capture.barcodes.first;

          final code = barcode.rawValue;

          if (code == null) {
            _showMessage("Invalid QR Code");

            return;
          }

          await handleScan(code);

          // markAttendance(code!);

          // showDialog(
          //   context: context,
          //   builder: (_) {
          //     return AlertDialog(
          //       title: const Text("Success"),
          //       content: const Text("Attendance Marked"),
          //     );
          //   },
          // );

          scanned = true;

          // print("QR => $code");
        },
      ),
    );
  }
}
