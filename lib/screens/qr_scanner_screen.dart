
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;

  Future<void> _sendLendingRequest(String bookId) async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage("User not signed in");
      return;
    }

    try {
      setState(() => _isProcessing = true);

      final bookSnapshot = await firestore.collection('books').doc(bookId).get();

      if (!bookSnapshot.exists) {
        _showMessage("Book not found in database");
        return;
      }

      final isAvailable = bookSnapshot.data()?['isAvailable'] ?? true;
      if (!isAvailable) {
        _showMessage("Book is not available for lending");
        return;
      }

      await firestore.collection('lending_requests').add({
        'bookId': bookId,
        'userId': user.uid,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showMessage("Lending request sent for Book ID: $bookId");
    } catch (e) {
      _showMessage("Error: $e");
    } finally {
      setState(() => _isProcessing = false);
      Navigator.pop(context);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Book QR')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcodeCapture) async {
              final barcode = barcodeCapture.barcodes.first;
              final String? code = barcode.rawValue;

              if (!_isProcessing && code != null) {
                await _sendLendingRequest(code);
              }
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
